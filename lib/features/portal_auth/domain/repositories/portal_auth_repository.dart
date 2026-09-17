import '../../../../core/errors/result.dart';
import '../entities/portal_session.dart';

abstract class PortalAuthRepository {
  Future<Result<int>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String department,
    required String branch,
  });
  Future<Result<PortalSession>> login({
    required String identifier,
    required String password,
  });
  Future<Result<PortalSession>> me(String token);
  Future<Result<void>> forgotPasswordRequest(String email);
  Future<Result<void>> forgotPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  });
  Future<Result<void>> updateProfile({
    required String token,
    String? email,
    required String fullName,
    required String department,
    required String branch,
  });
  Future<Result<void>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  });
}
