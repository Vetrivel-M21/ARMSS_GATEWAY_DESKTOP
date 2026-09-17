import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/gateway_api_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../domain/entities/portal_session.dart';
import '../domain/repositories/portal_auth_repository.dart';

class PortalAuthRepositoryImpl implements PortalAuthRepository {
  Uri _uri(String path) => Uri.parse('${GatewayApiClient.apiBaseUrl}$path');

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final response = await http
        .post(
          _uri(path),
          headers: {'Content-Type': 'application/json', ...?headers},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _errorMessage(Map<String, dynamic> body, String fallback) =>
      (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
      fallback;

  @override
  Future<Result<int>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String department,
    required String branch,
  }) async {
    try {
      final body = await _post('/portal/register', {
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'department': department,
        'branch': branch,
      });
      if (body['success'] != true) {
        return Failure(
          NetworkException(_errorMessage(body, 'Registration failed.')),
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      return Success((data['user_id'] as num).toInt());
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

  int? _extractUserIdFromJwt(String jwtToken) {
    try {
      final parts = jwtToken.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;
      return (payload['user_id'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<PortalSession>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final body = await _post('/portal/login', {
        'identifier': identifier,
        'password': password,
      });
      if (body['success'] != true) {
        return Failure(
          NetworkException(
            _errorMessage(body, 'Invalid username/email or password.'),
          ),
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userId =
          (data['user_id'] as num?)?.toInt() ?? _extractUserIdFromJwt(token);
      return Success(
        PortalSession(
          userId: userId,
          token: token,
          username: data['username'] as String,
          email: data['email'] as String,
          fullName: data['full_name'] as String,
          department: data['department'] as String? ?? '',
          branch: data['branch'] as String? ?? '',
          role: data['role'] as String? ?? 'user',
          grantedLinkKeys: (data['granted_link_keys'] as List).cast<String>(),
        ),
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
  Future<Result<PortalSession>> me(String token) async {
    try {
      final response = await http
          .get(_uri('/portal/me'), headers: {'X-Portal-Token': token})
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return Failure(
          NetworkException(_errorMessage(body, 'Session expired.')),
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      final userId =
          (data['user_id'] as num?)?.toInt() ?? _extractUserIdFromJwt(token);
      return Success(
        PortalSession(
          userId: userId,
          token: token,
          username: data['username'] as String,
          email: data['email'] as String,
          fullName: data['full_name'] as String,
          department: data['department'] as String? ?? '',
          branch: data['branch'] as String? ?? '',
          role: data['role'] as String? ?? 'user',
          grantedLinkKeys: (data['granted_link_keys'] as List).cast<String>(),
        ),
      );
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> forgotPasswordRequest(String email) async {
    try {
      await _post('/portal/forgot-password/request', {'email': email});
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final body = await _post('/portal/forgot-password/reset', {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      });
      final reset =
          body['success'] == true &&
          (body['data'] as Map<String, dynamic>?)?['reset'] == true;
      if (!reset) {
        return const Failure(
          NetworkException('That OTP is incorrect or has expired.'),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(NetworkException('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateProfile({
    required String token,
    String? email,
    required String fullName,
    required String department,
    required String branch,
  }) async {
    try {
      final bodyMap = <String, dynamic>{
        'full_name': fullName,
        'department': department,
        'branch': branch,
      };
      if (email != null && email.trim().isNotEmpty) {
        bodyMap['email'] = email.trim();
      }
      final response = await http
          .put(
            _uri('/portal/me'),
            headers: {
              'Content-Type': 'application/json',
              'X-Portal-Token': token,
            },
            body: jsonEncode(bodyMap),
          )
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        return Failure(
          NetworkException(_errorMessage(body, 'Failed to update profile.')),
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
  Future<Result<void>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final body = await _post(
        '/portal/change-password',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        headers: {'X-Portal-Token': token},
      );
      if (body['success'] != true) {
        return Failure(
          NetworkException(_errorMessage(body, 'Failed to change password.')),
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
}
