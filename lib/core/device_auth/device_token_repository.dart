import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/gateway_api_client.dart';
import '../errors/app_exception.dart';
import '../errors/result.dart';

class TokenValidationResult {
  final bool isValid;
  final String?
  reason; // 'otp_reverification_required', 'revoked_by_admin', 'invalid_token'
  final int? userId;
  final String? username;

  const TokenValidationResult({
    required this.isValid,
    this.reason,
    this.userId,
    this.username,
  });
}

class ActivationCheckResult {
  final String status; // 'pending', 'approved', 'rejected', 'not_found'
  final String? token;
  final String? reason;

  const ActivationCheckResult({required this.status, this.token, this.reason});
}

class MonthlyOtpRequestResult {
  final String requestId;
  final String sentTo;

  const MonthlyOtpRequestResult({
    required this.requestId,
    required this.sentTo,
  });
}

class DeviceTokenRepository {
  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final base = Uri.parse('${GatewayApiClient.apiBaseUrl}$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return base.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return base;
  }

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

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
  }) async {
    final response = await http
        .get(
          _uri(path, queryParams),
          headers: {'Content-Type': 'application/json', ...?headers},
        )
        .timeout(const Duration(seconds: 10));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Result<TokenValidationResult>> validateToken({
    required String deviceId,
    required String token,
  }) async {
    try {
      final body = await _post('/auth/validate-token', {
        'device_id': deviceId,
        'token': token,
      });

      if (body['success'] != true) {
        return const Success(
          TokenValidationResult(isValid: false, reason: 'server_error'),
        );
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      final valid = data['valid'] == true;
      final reason = data['reason'] as String?;
      final userId = data['user_id'] as int?;
      final username = data['username'] as String?;

      return Success(
        TokenValidationResult(
          isValid: valid,
          reason: reason,
          userId: userId,
          username: username,
        ),
      );
    } on SocketException {
      return const Failure(
        NetworkException('Could not connect to ARMSS Gateway server.'),
      );
    } on TimeoutException {
      return const Failure(
        NetworkException('Connection to ARMSS Gateway server timed out.'),
      );
    } catch (e) {
      return Failure(NetworkException('Token validation failed: $e'));
    }
  }

  Future<Result<String>> requestActivation({
    required String deviceId,
    required String domainRequested,
  }) async {
    try {
      final body = await _post('/auth/request-activation', {
        'device_id': deviceId,
        'domain_requested': domainRequested,
      });

      if (body['success'] != true) {
        final err =
            (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
            'Activation request failed.';
        return Failure(NetworkException(err));
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return Success(data['request_id'] as String? ?? '');
    } catch (e) {
      return Failure(NetworkException('Failed to request activation: $e'));
    }
  }

  Future<Result<ActivationCheckResult>> checkActivation({
    required String deviceId,
  }) async {
    try {
      final body = await _get(
        '/auth/check-activation',
        queryParams: {'device_id': deviceId},
      );
      if (body['success'] != true) {
        return const Success(ActivationCheckResult(status: 'not_found'));
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return Success(
        ActivationCheckResult(
          status: data['status'] as String? ?? 'not_found',
          token: data['token'] as String?,
          reason: data['reason'] as String?,
        ),
      );
    } catch (e) {
      return Failure(NetworkException('Failed to check activation status: $e'));
    }
  }

  Future<Result<MonthlyOtpRequestResult>> requestMonthlyOtp({
    required String deviceId,
  }) async {
    try {
      final body = await _post('/auth/monthly-reverify/request-otp', {
        'device_id': deviceId,
      });
      if (body['success'] != true) {
        final err =
            (body['error'] as Map<String, dynamic>?)?['message'] as String? ??
            'Failed to send OTP.';
        return Failure(NetworkException(err));
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return Success(
        MonthlyOtpRequestResult(
          requestId: data['request_id'] as String? ?? '',
          sentTo: data['sent_to'] as String? ?? 'registered email',
        ),
      );
    } catch (e) {
      return Failure(NetworkException('Failed to send verification OTP: $e'));
    }
  }

  Future<Result<bool>> verifyMonthlyOtp({
    required String deviceId,
    required String requestId,
    required String otp,
  }) async {
    try {
      final body = await _post('/auth/monthly-reverify/verify-otp', {
        'device_id': deviceId,
        'request_id': requestId,
        'otp': otp,
      });

      if (body['success'] != true) {
        return const Success(false);
      }

      final data = body['data'] as Map<String, dynamic>? ?? {};
      return Success(data['verified'] == true);
    } catch (e) {
      return Failure(NetworkException('Failed to verify OTP: $e'));
    }
  }
}
