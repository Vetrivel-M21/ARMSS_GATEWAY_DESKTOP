import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/gateway_api_client.dart';

class DeviceIdentity {
  final String deviceId;
  final String token;

  const DeviceIdentity({required this.deviceId, required this.token});
}

/// Manages local persistence for per-device identity and gating token.
/// Checks the installer-generated credentials file in %LOCALAPPDATA%
/// as well as SharedPreferences.
class DeviceIdentityService {
  static const _prefDeviceId = 'armss_device_id';
  static const _prefDeviceToken = 'armss_device_token';

  static String? _cachedDeviceId;
  static String? _cachedDeviceToken;

  /// Retrieves the current DeviceIdentity or null if not registered yet.
  Future<DeviceIdentity?> getIdentity() async {
    if (_cachedDeviceId != null && _cachedDeviceToken != null) {
      return DeviceIdentity(
        deviceId: _cachedDeviceId!,
        token: _cachedDeviceToken!,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_prefDeviceId);
    String? token = prefs.getString(_prefDeviceToken);

    // Always check installer file on Windows as the authoritative source.
    // If the installer was re-run, disk file will have the new credentials.
    final fileData = await _readInstallerConfigFile();
    if (fileData != null) {
      final fileDeviceId = fileData['device_id'] as String?;
      final fileToken = fileData['device_token'] as String?;
      if (fileDeviceId != null && fileToken != null && fileToken.isNotEmpty) {
        if (fileDeviceId != deviceId || fileToken != token) {
          deviceId = fileDeviceId;
          token = fileToken;
          await prefs.setString(_prefDeviceId, deviceId);
          await prefs.setString(_prefDeviceToken, token);
        }
      }
    }

    if (deviceId == null) {
      deviceId = _generateDeviceId();
      await prefs.setString(_prefDeviceId, deviceId);
    }

    _cachedDeviceId = deviceId;
    _cachedDeviceToken = token;

    if (token == null) {
      return null;
    }

    return DeviceIdentity(deviceId: deviceId, token: token);
  }

  /// Returns the current Device ID (generating one if not existing).
  Future<String> getDeviceId() async {
    final identity = await getIdentity();
    if (identity != null) {
      return identity.deviceId;
    }
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_prefDeviceId);
    if (id == null) {
      id = _generateDeviceId();
      await prefs.setString(_prefDeviceId, id);
    }
    _cachedDeviceId = id;
    return id;
  }

  /// Persists a new or rotated device token.
  Future<void> saveToken(String token, {String? deviceId}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveDeviceId = deviceId ?? await getDeviceId();

    await prefs.setString(_prefDeviceId, effectiveDeviceId);
    await prefs.setString(_prefDeviceToken, token);

    _cachedDeviceId = effectiveDeviceId;
    _cachedDeviceToken = token;

    await _writeInstallerConfigFile(effectiveDeviceId, token);
  }

  /// Clears stored device token upon revocation.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefDeviceToken);
    _cachedDeviceToken = null;
  }

  /// Clears stored device ID and token locally and on disk.
  Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefDeviceId);
    await prefs.remove(_prefDeviceToken);
    _cachedDeviceId = null;
    _cachedDeviceToken = null;
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        final f1 = File('$localAppData\\ARMSS Gateway\\device_auth.json');
        if (await f1.exists()) await f1.delete();
        final f2 = File('$localAppData\\Programs\\ARMSS Gateway\\device_auth.json');
        if (await f2.exists()) await f2.delete();
      }
    }
  }

  /// Automatically self-registers this machine on the production backend
  /// and saves the newly issued credentials.
  /// If [deviceId] is not specified, uses the persistent local device ID.
  Future<DeviceIdentity?> registerDeviceOnServer({int? userId, String? deviceId}) async {
    try {
      final effectiveDeviceId = deviceId ?? await getDeviceId();
      final machineName = Platform.localHostname;
      final uri = Uri.parse('${GatewayApiClient.apiBaseUrl}/devices/register');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'X-Installer-Secret': GatewayApiClient.installerApiSecret,
            },
            body: jsonEncode({
              'user_id': userId ?? 0,
              'device_id': effectiveDeviceId,
              'machine_fingerprint': machineName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final token = body['data']['token'] as String;
        await saveToken(token, deviceId: effectiveDeviceId);
        return DeviceIdentity(deviceId: effectiveDeviceId, token: token);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _readInstallerConfigFile() async {
    if (!Platform.isWindows) return null;
    try {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return null;

      final paths = [
        '$localAppData\\ARMSS Gateway\\device_auth.json',
        '$localAppData\\Programs\\ARMSS Gateway\\device_auth.json',
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

  Future<void> _writeInstallerConfigFile(String deviceId, String token) async {
    if (!Platform.isWindows) return;
    try {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData == null) return;

      final dir = Directory('$localAppData\\ARMSS Gateway');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}\\device_auth.json');
      await file.writeAsString(
        jsonEncode({
          'device_id': deviceId,
          'device_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {}
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'dev_$hex';
  }
}
