import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../config/gateway_api_client.dart';

// const currentAppVersion = '1.1.2';
String? _cachedAppVersion;

/// Retrieves the current application version dynamically from pubspec.yaml
/// (via PackageInfo with fallback to asset pubspec.yaml parsing).
Future<String> getCurrentAppVersion() async {
  if (_cachedAppVersion != null && _cachedAppVersion!.isNotEmpty) {
    return _cachedAppVersion!;
  }

  // 1. Primary: PackageInfo from platform (Flutter's standard version reader)
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) {
      _cachedAppVersion = info.version;
      return _cachedAppVersion!;
    }
  } catch (_) {}

  // 2. Fallback: Parse pubspec.yaml from asset bundle
  try {
    final yamlString = await rootBundle.loadString('pubspec.yaml');
    final match = RegExp(
      r'^version:\s*([^\s+]+)',
      multiLine: true,
    ).firstMatch(yamlString);
    if (match != null && match.group(1) != null) {
      _cachedAppVersion = match.group(1)!.trim();
      return _cachedAppVersion!;
    }
  } catch (_) {}

  // 3. Fallback: Parse local pubspec.yaml file if accessible
  try {
    final file = File('pubspec.yaml');
    if (await file.exists()) {
      final content = await file.readAsString();
      final match = RegExp(
        r'^version:\s*([^\s+]+)',
        multiLine: true,
      ).firstMatch(content);
      if (match != null && match.group(1) != null) {
        _cachedAppVersion = match.group(1)!.trim();
        return _cachedAppVersion!;
      }
    }
  } catch (_) {}

  return '1.1.2';
}

/// For synchronous compatibility where currentAppVersion is referenced
String get currentAppVersion => _cachedAppVersion ?? '1.1.2';

class AppUpdateInfo {
  final String version;
  final String url;
  final String sha256;

  const AppUpdateInfo({
    required this.version,
    required this.url,
    required this.sha256,
  });
}

class AppUpdateService {
  Future<AppUpdateInfo?> check() async {
    if (!Platform.isWindows) return null;
    final currentVersion = await getCurrentAppVersion();
    final response = await http
        .get(Uri.parse('${GatewayApiClient.apiBaseUrl}/app/update'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    final envelope = jsonDecode(response.body) as Map<String, dynamic>;
    final data = envelope['data'] as Map<String, dynamic>?;
    if (envelope['success'] != true || data?['available'] != true) return null;
    final version = data?['version'] as String?;
    final url = data?['url'] as String?;
    if (version == null || url == null || !_isNewer(version, currentVersion)) {
      return null;
    }
    return AppUpdateInfo(
      version: version,
      url: url,
      sha256: data?['sha256'] as String? ?? '',
    );
  }

  Future<void> install(AppUpdateInfo update) async {
    final response = await http
        .get(Uri.parse(update.url))
        .timeout(const Duration(minutes: 5));
    if (response.statusCode != 200) {
      throw const HttpException('Unable to download the update.');
    }
    final bytes = response.bodyBytes;
    if (update.sha256.isNotEmpty &&
        sha256.convert(bytes).toString().toLowerCase() !=
            update.sha256.toLowerCase()) {
      throw const HttpException(
        'The downloaded update failed its integrity check.',
      );
    }
    final directory = await getTemporaryDirectory();
    final installer = File(
      '${directory.path}\\ARMSS_Gateway_Setup_${update.version}.exe',
    );
    await installer.writeAsBytes(bytes, flush: true);
    await Process.start(installer.path, [
      '/UPDATE',
    ], mode: ProcessStartMode.detached);
    exit(0);
  }
}

bool _isNewer(String candidate, String current) {
  List<int> parts(String value) =>
      value.split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final next = parts(candidate);
  final installed = parts(current);
  for (var index = 0; index < 3; index++) {
    final nextPart = index < next.length ? next[index] : 0;
    final installedPart = index < installed.length ? installed[index] : 0;
    if (nextPart != installedPart) return nextPart > installedPart;
  }
  return false;
}
