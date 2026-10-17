import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../config/gateway_api_client.dart';
import '../theme/app_theme.dart';

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
      _cachedAppVersion = info.version.split('+').first.trim();
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

  return '1.1.13';
}

/// For synchronous compatibility where currentAppVersion is referenced
String get currentAppVersion => _cachedAppVersion ?? '1.1.13';

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
    try {
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
    } catch (_) {
      return null;
    }
  }

  Future<void> install(
    AppUpdateInfo update, {
    void Function(String status)? onStatus,
    void Function(double progress, int receivedBytes, int totalBytes)? onProgress,
  }) async {
    final client = http.Client();
    File? installer;
    try {
      onStatus?.call('Connecting to update server...');
      final request = http.Request('GET', Uri.parse(update.url));
      final response = await client.send(request).timeout(const Duration(minutes: 5));
      if (response.statusCode != 200) {
        throw HttpException('Unable to download update (HTTP ${response.statusCode}).');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final directory = await getTemporaryDirectory();
      installer = File(
        '${directory.path}\\ARMSS_Gateway_Setup_${update.version}.exe',
      );
      if (await installer.exists()) {
        try {
          await installer.delete();
        } catch (_) {}
      }

      final sink = installer.openWrite();
      onStatus?.call('Downloading update package...');

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          final progress = receivedBytes / totalBytes;
          onProgress?.call(progress.clamp(0.0, 1.0), receivedBytes, totalBytes);
        } else {
          onProgress?.call(-1.0, receivedBytes, 0);
        }
      }
      await sink.flush();
      await sink.close();

      if (update.sha256.isNotEmpty) {
        onStatus?.call('Verifying package integrity...');
        final fileDigest = await sha256.bind(installer.openRead()).first;
        if (fileDigest.toString().toLowerCase() != update.sha256.toLowerCase()) {
          try {
            await installer.delete();
          } catch (_) {}
          throw const HttpException('The downloaded update failed its integrity checksum.');
        }
      }

      onStatus?.call('Launching update installer...');
      await Process.start(installer.path, [
        '/UPDATE',
      ], mode: ProcessStartMode.detached);
      exit(0);
    } finally {
      client.close();
    }
  }
}

bool _isNewer(String candidate, String current) {
  String clean(String v) => v.split('+').first.trim();
  List<int> parts(String value) =>
      clean(value).split('.').map((part) => int.tryParse(part) ?? 0).toList();
  final next = parts(candidate);
  final installed = parts(current);
  for (var index = 0; index < 3; index++) {
    final nextPart = index < next.length ? next[index] : 0;
    final installedPart = index < installed.length ? installed[index] : 0;
    if (nextPart != installedPart) return nextPart > installedPart;
  }
  return false;
}

/// Displays an interactive update dialog with downloading feedback and installation
Future<void> showDesktopUpdateDialog(
  BuildContext context, {
  required AppUpdateInfo updateInfo,
  String? currentVersion,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _DesktopUpdateDialog(
      updateInfo: updateInfo,
      currentVersion: currentVersion,
    ),
  );
}

class _DesktopUpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final String? currentVersion;

  const _DesktopUpdateDialog({
    required this.updateInfo,
    this.currentVersion,
  });

  @override
  State<_DesktopUpdateDialog> createState() => _DesktopUpdateDialogState();
}

class _DesktopUpdateDialogState extends State<_DesktopUpdateDialog> {
  bool _isInstalling = false;
  String _statusText = '';
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String? _error;

  Future<void> _startInstall() async {
    setState(() {
      _isInstalling = true;
      _error = null;
      _statusText = 'Connecting to server...';
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = 0;
    });
    try {
      await AppUpdateService().install(
        widget.updateInfo,
        onStatus: (status) {
          if (mounted) setState(() => _statusText = status);
        },
        onProgress: (progress, received, total) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _receivedBytes = received;
              _totalBytes = total;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInstalling = false;
          _error = e.toString().replaceFirst('Exception: ', '').replaceFirst('HttpException: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isInstalling,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'New Update Available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceCanvas,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lineHairline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Installed Version',
                        style: TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${widget.currentVersion ?? '1.1.9'}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.inkSecondary),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Latest Version',
                        style: TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'v${widget.updateInfo.version}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!_isInstalling && _error == null)
              const Text(
                'A new version of ARMSS Gateway is ready to install. The update will download and apply seamlessly without affecting your accounts or settings.',
                style: TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.4),
              ),
            if (_isInstalling) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusText,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkPrimary),
                      ),
                    ],
                  ),
                  if (_totalBytes > 0 && _progress >= 0)
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.monoWith(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.accentLedger),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progress >= 0 && _totalBytes > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: AppColors.lineHairline,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentLedger),
                ),
              ),
              if (_totalBytes > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_receivedBytes / (1024 * 1024)).toStringAsFixed(1)} MB / ${(_totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                      style: AppTextStyles.monoWith(fontSize: 11, color: AppColors.inkSecondary),
                    ),
                    const Text(
                      'Please keep the app open',
                      style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!_isInstalling)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentLedger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isInstalling ? null : _startInstall,
            icon: _isInstalling
                ? const SizedBox.shrink()
                : const Icon(Icons.download_rounded, size: 16),
            label: Text(_isInstalling ? 'Downloading...' : (_error != null ? 'Retry' : 'Update Now')),
          ),
        ],
      ),
    );
  }
}

