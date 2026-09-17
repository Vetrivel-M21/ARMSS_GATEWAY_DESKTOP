import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/gateway_api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../domain/entities/admin_activation_request.dart';
import '../domain/entities/admin_audit_log.dart';
import '../domain/entities/admin_device.dart';
import '../domain/entities/admin_portal_user.dart';
import '../domain/entities/admin_portal_link.dart';
import '../domain/repositories/portal_admin_repository.dart';

class PortalAdminRepositoryImpl implements PortalAdminRepository {
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Admin-Secret': GatewayApiClient.adminApiSecret,
  };

  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final base = Uri.parse('${GatewayApiClient.apiBaseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return base.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return base;
  }

  @override
  Future<Result<List<AdminPortalLink>>> listLinks() async {
    try {
      final response = await http.get(
        _uri('/portal/admin/links'),
        headers: _headers,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true)
        return const Failure(NetworkException('Unable to load portal links.'));
      return Success([
        for (final raw in (body['data'] as List).cast<Map<String, dynamic>>())
          AdminPortalLink(
            key: raw['key'] as String,
            tabName: raw['tab_name'] as String,
            name: raw['name'] as String,
            url: raw['url'] as String,
            icon: raw['icon'] as String? ?? 'apps_outlined',
            color: raw['color'] as String? ?? '#0284C7',
            imagePath: raw['image_path'] as String?,
            sortOrder: raw['sort_order'] as int? ?? 0,
            isActive: raw['is_active'] as bool? ?? true,
          ),
      ]);
    } catch (e) {
      return Failure(NetworkException('Failed to load portal links: $e'));
    }
  }

  @override
  Future<Result<AdminPortalLink>> saveLink({
    String? key,
    required String tabName,
    required String name,
    required String url,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    try {
      final response = await http.post(
        _uri('/portal/admin/links'),
        headers: _headers,
        body: jsonEncode({
          'key': key,
          'tab_name': tabName,
          'name': name,
          'url': url,
          'sort_order': sortOrder,
          'is_active': isActive,
        }),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true)
        return const Failure(NetworkException('Unable to save portal link.'));
      final raw = body['data'] as Map<String, dynamic>;
      return Success(
        AdminPortalLink(
          key: raw['key'],
          tabName: raw['tab_name'],
          name: raw['name'],
          url: raw['url'],
          icon: raw['icon'],
          color: raw['color'],
          imagePath: raw['image_path'],
          sortOrder: raw['sort_order'],
          isActive: raw['is_active'],
        ),
      );
    } catch (e) {
      return Failure(NetworkException('Failed to save portal link: $e'));
    }
  }

  @override
  Future<Result<void>> deleteLink(String key) async {
    try {
      final response = await http.delete(
        _uri('/portal/admin/links/$key'),
        headers: _headers,
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['success'] == true
          ? const Success(null)
          : const Failure(
              NetworkException('Unable to deactivate portal link.'),
            );
    } catch (e) {
      return Failure(NetworkException('Failed to deactivate portal link: $e'));
    }
  }

  @override
  Future<Result<String>> uploadLinkImage({
    required String key,
    required File image,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        _uri('/portal/admin/links/$key/image'),
      );
      request.headers.addAll({
        'X-Admin-Secret': GatewayApiClient.adminApiSecret,
      });
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      final response = await request.send();
      final body = jsonDecode(
        await response.stream.bytesToString(),
      ) as Map<String, dynamic>;
      if (body['success'] != true)
        return const Failure(
          NetworkException('Unable to upload portal image.'),
        );
      return Success(
        (body['data'] as Map<String, dynamic>)['image_path'] as String,
      );
    } catch (e) {
      return Failure(NetworkException('Failed to upload portal image: $e'));
    }
  }

  @override
  Future<Result<List<AdminPortalUser>>> listUsers() async {
    try {
      final response = await http
          .get(_uri('/portal/admin/users'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to load portal users.'));
      }
      final data = (body['data'] as List).cast<Map<String, dynamic>>();
      return Success([
        for (final u in data)
          AdminPortalUser(
            id: u['id'] as int,
            username: u['username'] as String,
            email: u['email'] as String,
            fullName: u['full_name'] as String,
            department: u['department'] as String? ?? '',
            branch: u['branch'] as String? ?? '',
            role: u['role'] as String? ?? 'user',
            isActive: u['is_active'] as bool,
            grantedLinkKeys: (u['granted_link_keys'] as List? ?? [])
                .cast<String>(),
          ),
      ]);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> setActive({
    required int userId,
    required bool isActive,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/users/$userId/approve'),
            headers: _headers,
            body: jsonEncode({'is_active': isActive}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to update account status.'),
        );
      }
      return const Success(null);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> setRole({
    required int userId,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/users/$userId/role'),
            headers: _headers,
            body: jsonEncode({'role': role}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to update user role.'),
        );
      }
      return const Success(null);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<String>> revealPassword(int userId) async {
    try {
      final response = await http
          .get(_uri('/portal/admin/users/$userId/password'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to load password.'));
      }
      return Success(
        (body['data'] as Map<String, dynamic>)['password'] as String,
      );
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> setPassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/users/$userId/password'),
            headers: _headers,
            body: jsonEncode({'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to update password.'));
      }
      return const Success(null);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> setGrants({
    required int userId,
    required List<String> linkKeys,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/users/$userId/grants'),
            headers: _headers,
            body: jsonEncode({'link_keys': linkKeys}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to save access grants.'));
      }
      return const Success(null);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUser(int userId) async {
    try {
      final response = await http
          .delete(_uri('/portal/admin/users/$userId'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        final msg =
            body['error']?['message'] as String? ?? 'Unable to delete user.';
        return Failure(NetworkException(msg));
      }
      return const Success(null);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<AdminDevice>>> listDevices() async {
    try {
      final response = await http
          .get(_uri('/admin/devices'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to load devices.'));
      }
      final data = (body['data'] as List).cast<Map<String, dynamic>>();
      return Success([
        for (final d in data)
          AdminDevice(
            deviceId: d['device_id'] as String,
            userId: d['user_id'] as int,
            username: d['username'] as String? ?? '',
            email: d['email'] as String? ?? '',
            fullName: d['full_name'] as String? ?? '',
            machineFingerprint: d['machine_fingerprint'] as String? ?? '',
            tokenStatus: d['token_status'] as String? ?? 'none',
            tokenVersion: d['token_version'] as int? ?? 1,
            lastOtpVerifiedAt:
                DateTime.tryParse(d['last_otp_verified_at'] as String? ?? '') ??
                DateTime.now(),
            isOtpExpired: d['is_otp_expired'] as bool? ?? false,
            createdAt:
                DateTime.tryParse(d['created_at'] as String? ?? '') ??
                DateTime.now(),
          ),
      ]);
    } on SocketException {
      return const Failure(
        NetworkException('Could not reach the ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Timed out contacting the ARMSS Gateway server.'),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> revokeDevice(String deviceId) async {
    try {
      final response = await http
          .post(_uri('/admin/devices/$deviceId/revoke'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to revoke device token.'),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Failed to revoke device: $e'));
    }
  }

  @override
  Future<Result<void>> assignDeviceUser({
    required String deviceId,
    required int userId,
    String? machineFingerprint,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/devices/register'),
            headers: {
              'Content-Type': 'application/json',
              'X-Installer-Secret': GatewayApiClient.installerApiSecret,
            },
            body: jsonEncode({
              'user_id': userId,
              'device_id': deviceId,
              'machine_fingerprint': machineFingerprint ?? 'Windows PC',
            }),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to assign user to device.'),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Failed to assign user: $e'));
    }
  }

  @override
  Future<Result<List<AdminActivationRequest>>> listActivationRequests([
    String? status,
  ]) async {
    try {
      final query = status != null ? {'status': status} : null;
      final response = await http
          .get(_uri('/admin/requests', query), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to load activation requests.'),
        );
      }
      final data = (body['data'] as List).cast<Map<String, dynamic>>();
      return Success([
        for (final r in data)
          AdminActivationRequest(
            requestId: r['request_id'] as String,
            userId: r['user_id'] as int,
            username: r['username'] as String? ?? '',
            email: r['email'] as String? ?? '',
            fullName: r['full_name'] as String? ?? '',
            deviceId: r['device_id'] as String,
            domainRequested: r['domain_requested'] as String,
            status: r['status'] as String,
            requestedAt:
                DateTime.tryParse(r['requested_at'] as String? ?? '') ??
                DateTime.now(),
            approvedAt: r['approved_at'] != null
                ? DateTime.tryParse(r['approved_at'] as String)
                : null,
            rejectionReason: r['rejection_reason'] as String?,
          ),
      ]);
    } catch (e) {
      return Failure(
        NetworkException('Failed to load activation requests: $e'),
      );
    }
  }

  @override
  Future<Result<void>> approveActivationRequest(String requestId) async {
    try {
      final response = await http
          .post(_uri('/admin/requests/$requestId/approve'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to approve activation request.'),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Failed to approve request: $e'));
    }
  }

  @override
  Future<Result<void>> rejectActivationRequest(
    String requestId, {
    String? reason,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/admin/requests/$requestId/reject'),
            headers: _headers,
            body: jsonEncode({'reason': reason ?? ''}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to reject activation request.'),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Failed to reject request: $e'));
    }
  }

  @override
  Future<Result<List<AdminAuditLog>>> listAuditLogs({int limit = 100}) async {
    try {
      final response = await http
          .get(
            _uri('/admin/audit-logs', {'limit': '$limit'}),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(NetworkException('Unable to load audit logs.'));
      }
      final data = (body['data'] as List).cast<Map<String, dynamic>>();
      return Success([
        for (final item in data)
          AdminAuditLog(
            id: item['id'] as int,
            eventType: item['event_type'] as String? ?? '',
            userId: item['user_id'] as int?,
            deviceId: item['device_id'] as String?,
            actor: item['actor'] as String? ?? 'system',
            metadata: item['metadata'] as String? ?? '',
            createdAt:
                DateTime.tryParse(item['created_at'] as String? ?? '') ??
                DateTime.now(),
          ),
      ]);
    } catch (e) {
      return Failure(NetworkException('Failed to load audit logs: $e'));
    }
  }

  @override
  Future<Result<String>> getInstallerPassword() async {
    try {
      final response = await http
          .get(_uri('/portal/admin/installer-password'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 404) {
        return const Failure(
          NetworkException(
            'Installer password endpoint not found (404). Please deploy the updated backend on the server.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return Failure(
          NetworkException('Server returned HTTP ${response.statusCode}.'),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to load installer password.'),
        );
      }
      final data = body['data'] as Map<String, dynamic>?;
      final pwd = data?['password'] as String? ?? '';
      return Success(pwd);
    } catch (e) {
      return Failure(NetworkException('Failed to load installer password: $e'));
    }
  }

  @override
  Future<Result<void>> setInstallerPassword(String newPassword) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/installer-password'),
            headers: _headers,
            body: jsonEncode({'password': newPassword}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 404) {
        return const Failure(
          NetworkException(
            'Installer password endpoint not found (404). Please deploy the updated backend on the server.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return Failure(
          NetworkException('Server returned HTTP ${response.statusCode}.'),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        final err = body['error'] as Map<String, dynamic>?;
        return Failure(
          NetworkException(
            err?['message'] as String? ??
                'Unable to update installer password.',
          ),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(
        NetworkException('Failed to update installer password: $e'),
      );
    }
  }

  @override
  Future<Result<String>> getAdminPassword() async {
    try {
      final response = await http
          .get(_uri('/portal/admin/admin-password'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return Failure(
          NetworkException('Server returned HTTP ${response.statusCode}.'),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to load admin password.'),
        );
      }
      final data = body['data'] as Map<String, dynamic>?;
      final pwd = data?['password'] as String? ?? '';
      return Success(pwd);
    } catch (e) {
      return Failure(NetworkException('Failed to load admin password: $e'));
    }
  }

  @override
  Future<Result<void>> setAdminPassword(String newPassword) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/admin-password'),
            headers: _headers,
            body: jsonEncode({'password': newPassword}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        return Failure(
          NetworkException('Server returned HTTP ${response.statusCode}.'),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        final err = body['error'] as Map<String, dynamic>?;
        return Failure(
          NetworkException(
            err?['message'] as String? ?? 'Unable to update admin password.',
          ),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Failed to update admin password: $e'));
    }
  }

  @override
  Future<Result<bool>> getTokenRestrictionEnabled() async {
    try {
      final response = await http
          .get(_uri('/portal/admin/token-restriction'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true)
        return const Failure(
          NetworkException('Unable to load token restriction.'),
        );
      return Success(
        ((body['data'] as Map<String, dynamic>)['enabled'] as bool?) ?? true,
      );
    } catch (e) {
      return Failure(NetworkException('Failed to load token restriction: $e'));
    }
  }

  @override
  Future<Result<void>> setTokenRestrictionEnabled(bool enabled) async {
    try {
      final response = await http
          .post(
            _uri('/portal/admin/token-restriction'),
            headers: _headers,
            body: jsonEncode({'enabled': enabled}),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true)
        return const Failure(
          NetworkException('Unable to update token restriction.'),
        );
      return const Success(null);
    } catch (e) {
      return Failure(
        NetworkException('Failed to update token restriction: $e'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getActiveInstallerOtp() async {
    try {
      final response = await http
          .get(_uri('/portal/admin/installer-otp'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 404) {
        return const Failure(
          NetworkException(
            'Installer OTP endpoint not found (404). Please deploy the updated backend on the server.',
          ),
        );
      }
      if (response.statusCode != 200) {
        return Failure(
          NetworkException('Server returned HTTP ${response.statusCode}.'),
        );
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return const Failure(
          NetworkException('Unable to load active installer OTP.'),
        );
      }
      final data = body['data'] as Map<String, dynamic>? ?? {};
      return Success(data);
    } catch (e) {
      return Failure(NetworkException('Failed to load active OTP: $e'));
    }
  }
}
