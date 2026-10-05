import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_identity_service.dart';

class BoundAccount {
  final int userId;
  final String username;
  final String email;

  const BoundAccount({
    required this.userId,
    required this.username,
    required this.email,
  });

  String get displayName => username.isNotEmpty ? username : email;
}

/// Service that enforces single-account device binding on Desktop.
/// Once any account (user or admin) logs into this installation,
/// the installation is permanently bound to that account.
/// The only way to switch accounts is by uninstalling and reinstalling the app.
class DeviceAccountBindingService {
  static const _prefBoundUserId = 'armss_bound_user_id';
  static const _prefBoundUsername = 'armss_bound_username';
  static const _prefBoundEmail = 'armss_bound_email';
  static const _prefBoundDeviceId = 'armss_bound_device_id';

  static BoundAccount? _cachedBoundAccount;

  /// Retrieves the currently bound account on this device, or null if none is bound yet.
  Future<BoundAccount?> getBoundAccount() async {
    if (_cachedBoundAccount != null) {
      return _cachedBoundAccount;
    }

    final currentDeviceId = await DeviceIdentityService().getDeviceId();
    final prefs = await SharedPreferences.getInstance();
    final savedBoundDeviceId = prefs.getString(_prefBoundDeviceId);

    // If device was reinstalled (new deviceId generated) or uninstalled previously,
    // clear stale binding automatically so reinstall allows new login.
    if (savedBoundDeviceId != null &&
        savedBoundDeviceId.isNotEmpty &&
        savedBoundDeviceId != currentDeviceId) {
      await clearBinding();
      return null;
    }

    // On Windows, inspect disk file for auto-purge rules
    if (Platform.isWindows) {
      final diskData = await _readDiskBinding();
      if (diskData != null) {
        final diskUser = (diskData['username'] as String? ?? '').trim().toLowerCase();
        final diskDeviceId = diskData['device_id'] as String?;

        // 1. Auto-purge: If disk file was locked to 'admin', purge it automatically
        if (diskUser == 'admin') {
          await clearBinding();
          return null;
        }

        // 2. Auto-purge: If disk deviceId does not match current hardware ID, purge it
        if (diskDeviceId != null && diskDeviceId.isNotEmpty && diskDeviceId != currentDeviceId) {
          await clearBinding();
          return null;
        }
      } else if (prefs.getInt(_prefBoundUserId) != null) {
        // Disk file was deleted (e.g. uninstaller or manual cleanup), clear stale SharedPreferences
        await clearBinding();
        return null;
      }
    }

    var userId = prefs.getInt(_prefBoundUserId);
    var username = prefs.getString(_prefBoundUsername);
    var email = prefs.getString(_prefBoundEmail);

    // On Windows, load from disk file if SharedPreferences was empty
    if (userId == null && (username == null || username.isEmpty) && (email == null || email.isEmpty)) {
      final diskData = await _readDiskBinding();
      if (diskData != null) {
        userId = diskData['user_id'] as int?;
        username = diskData['username'] as String?;
        email = diskData['email'] as String?;
        final diskDeviceId = diskData['device_id'] as String?;
        if (diskDeviceId != null && diskDeviceId != currentDeviceId) {
          await clearBinding();
          return null;
        }
        if (userId != null) await prefs.setInt(_prefBoundUserId, userId);
        if (username != null) await prefs.setString(_prefBoundUsername, username);
        if (email != null) await prefs.setString(_prefBoundEmail, email);
        if (diskDeviceId != null) await prefs.setString(_prefBoundDeviceId, diskDeviceId);
      }
    }

    if (userId != null || (username != null && username.isNotEmpty) || (email != null && email.isNotEmpty)) {
      final boundUser = (username ?? '').trim().toLowerCase();
      // Auto-purge: Administrator accounts must never be locked to any machine
      if (boundUser == 'admin') {
        await clearBinding();
        return null;
      }

      _cachedBoundAccount = BoundAccount(
        userId: userId ?? 0,
        username: username ?? '',
        email: email ?? '',
      );
      return _cachedBoundAccount;
    }
    return null;
  }

  /// Clears stored device binding both in memory, SharedPreferences, and on disk.
  Future<void> clearBinding() async {
    _cachedBoundAccount = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefBoundUserId);
    await prefs.remove(_prefBoundUsername);
    await prefs.remove(_prefBoundEmail);
    await prefs.remove(_prefBoundDeviceId);

    if (Platform.isWindows) {
      try {
        final localAppData = Platform.environment['LOCALAPPDATA'];
        if (localAppData != null) {
          final paths = [
            '$localAppData\\ARMSS Gateway\\device_binding.json',
            '$localAppData\\Programs\\ARMSS Gateway\\device_binding.json',
          ];
          for (final p in paths) {
            final f = File(p);
            if (await f.exists()) await f.delete();
          }
        }
      } catch (_) {}
    }
  }

  /// Permanently binds this device installation to the specified account.
  /// Administrator accounts are never bound to devices.
  Future<void> bindAccount({
    required int userId,
    required String username,
    required String email,
  }) async {
    if (username.trim().toLowerCase() == 'admin') {
      return; // Do not lock device to administrator
    }

    final currentDeviceId = await DeviceIdentityService().getDeviceId();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefBoundUserId, userId);
    await prefs.setString(_prefBoundUsername, username);
    await prefs.setString(_prefBoundEmail, email);
    await prefs.setString(_prefBoundDeviceId, currentDeviceId);

    _cachedBoundAccount = BoundAccount(
      userId: userId,
      username: username,
      email: email,
    );

    // Also persist to disk so it lives and dies with the desktop installation
    await _writeDiskBinding(userId, username, email, currentDeviceId);
  }

  /// Checks whether an identifier (username or email) matches the bound account.
  /// Returns true if no account is bound yet, or if it matches the bound account.
  /// System Administrator is always allowed to log in on any device.
  Future<bool> isIdentifierAllowed(String identifier) async {
    final clean = identifier.trim().toLowerCase();
    if (clean == 'admin') return true;

    final bound = await getBoundAccount();
    if (bound == null) return true;
    if (clean.isEmpty) return false;

    final boundUser = bound.username.trim().toLowerCase();
    final boundEmail = bound.email.trim().toLowerCase();

    return clean == boundUser || clean == boundEmail;
  }

  /// Validates whether a logged in session belongs to the bound account.
  /// Administrator sessions are always allowed.
  Future<bool> isSessionAllowed({int? userId, String? username, String? email}) async {
    final cleanUser = (username ?? '').trim().toLowerCase();
    if (cleanUser == 'admin') return true;

    final bound = await getBoundAccount();
    if (bound == null) return true;

    if (userId != null && bound.userId > 0 && userId == bound.userId) {
      return true;
    }
    if (cleanUser.isNotEmpty && cleanUser == bound.username.trim().toLowerCase()) {
      return true;
    }
    final cleanEmail = (email ?? '').trim().toLowerCase();
    if (cleanEmail.isNotEmpty && cleanEmail == bound.email.trim().toLowerCase()) {
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> _readDiskBinding() async {
    if (!Platform.isWindows) return null;
    try {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return null;

      final paths = [
        '$localAppData\\ARMSS Gateway\\device_binding.json',
        '$localAppData\\Programs\\ARMSS Gateway\\device_binding.json',
      ];

      for (final p in paths) {
        final f = File(p);
        if (await f.exists()) {
          final text = await f.readAsString();
          return jsonDecode(text) as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _writeDiskBinding(int userId, String username, String email, String deviceId) async {
    if (!Platform.isWindows) return;
    try {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return;

      final dir = Directory('$localAppData\\ARMSS Gateway');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}\\device_binding.json');
      await file.writeAsString(
        jsonEncode({
          'user_id': userId,
          'username': username,
          'email': email,
          'device_id': deviceId,
          'bound_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }
}

final deviceAccountBindingServiceProvider = Provider<DeviceAccountBindingService>(
  (ref) => DeviceAccountBindingService(),
);
