import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/config/trust_app_client.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/result.dart';
import '../domain/entities/device_token.dart';
import '../domain/repositories/device_auth_repository.dart';

class DeviceAuthRepositoryImpl implements DeviceAuthRepository {
  @override
  Future<Result<DeviceToken>> authenticate() async {
    try {
      final response = await http
          .post(
            Uri.parse('${TrustAppClient.apiBaseUrl}/device/auth'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'client_id': TrustAppClient.clientId,
              'client_secret': TrustAppClient.clientSecret,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 || body['success'] != true) {
        final message = (body['error'] as Map<String, dynamic>?)?['message'] as String? ?? 'Device authentication failed.';
        return Failure(NetworkException(message));
      }

      final data = body['data'] as Map<String, dynamic>;
      return Success(DeviceToken(
        token: data['device_token'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      ));
    } on SocketException {
      return const Failure(NetworkException('Could not reach the Trust Management server. Is it running?'));
    } on TimeoutException {
      return const Failure(NetworkException('Timed out contacting the Trust Management server.'));
    } catch (e) {
      return Failure(NetworkException('Unexpected error contacting the Trust Management server: $e'));
    }
  }
}
