import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static BoundAccount? _cachedBoundAccount;

  /// Retrieves the currently bound account on this device, or null if none is bound yet.
  Future<BoundAccount?> getBoundAccount() async {
    if (_cachedBoundAccount != null) {
      return _cachedBoundAccount;
    }

    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(_prefBoundUserId);
    var username = prefs.getString(_prefBoundUsername);
    var email = prefs.getString(_prefBoundEmail);

    // On Windows, also check disk file if SharedPreferences is empty
    if (userId == null && (username == null || username.isEmpty) && (email == null || email.isEmpty)) {
      final diskData = await _readDiskBinding();
      if (diskData != null) {
        userId = diskData['user_id'] as int?;
        username = diskData['username'] as String?;
        email = diskData['email'] as String?;
        if (userId != null) await prefs.setInt(_prefBoundUserId, userId);
        if (username != null) await prefs.setString(_prefBoundUsername, username);
        if (email != null) await prefs.setString(_prefBoundEmail, email);
      }
    }

    if (userId != null || (username != null && username.isNotEmpty) || (email != null && email.isNotEmpty)) {
      _cachedBoundAccount = BoundAccount(
        userId: userId ?? 0,
        username: username ?? '',
        email: email ?? '',
      );
      return _cachedBoundAccount;
    }
    return null;
  }

  /// Permanently binds this device installation to the specified account.
  Future<void> bindAccount({
    required int userId,
    required String username,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefBoundUserId, userId);
    await prefs.setString(_prefBoundUsername, username);
    await prefs.setString(_prefBoundEmail, email);

    _cachedBoundAccount = BoundAccount(
      userId: userId,
      username: username,
      email: email,
    );

    // Also persist to disk so it lives and dies with the desktop installation
    await _writeDiskBinding(userId, username, email);
  }

  /// Checks whether an identifier (username or email) matches the bound account.
  /// Returns true if no account is bound yet, or if it matches the bound account.
  Future<bool> isIdentifierAllowed(String identifier) async {
    final bound = await getBoundAccount();
    if (bound == null) return true;

    final clean = identifier.trim().toLowerCase();
    if (clean.isEmpty) return false;

    final boundUser = bound.username.trim().toLowerCase();
    final boundEmail = bound.email.trim().toLowerCase();

    return clean == boundUser || clean == boundEmail;
  }

  /// Validates whether a logged in session belongs to the bound account.
  Future<bool> isSessionAllowed({int? userId, String? username, String? email}) async {
    final bound = await getBoundAccount();
    if (bound == null) return true;

    if (userId != null && bound.userId > 0 && userId == bound.userId) {
      return true;
    }
    final cleanUser = (username ?? '').trim().toLowerCase();
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

  Future<void> _writeDiskBinding(int userId, String username, String email) async {
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
          'bound_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }
}

final deviceAccountBindingServiceProvider = Provider<DeviceAccountBindingService>(
  (ref) => DeviceAccountBindingService(),
);
