import '../../../../core/errors/result.dart';
import 'dart:io';
import '../entities/admin_activation_request.dart';
import '../entities/admin_audit_log.dart';
import '../entities/admin_device.dart';
import '../entities/admin_portal_user.dart';
import '../entities/admin_portal_link.dart';

abstract class PortalAdminRepository {
  Future<Result<List<AdminPortalLink>>> listLinks();
  Future<Result<AdminPortalLink>> saveLink({
    String? key,
    required String tabName,
    required String name,
    required String url,
    int sortOrder,
    bool isActive,
  });
  Future<Result<void>> deleteLink(String key);
  Future<Result<String>> uploadLinkImage({required String key, required File image});
  Future<Result<List<AdminPortalUser>>> listUsers();
  Future<Result<void>> setActive({required int userId, required bool isActive});
  Future<Result<void>> setRole({required int userId, required String role});
  Future<Result<String>> revealPassword(int userId);
  Future<Result<void>> setPassword({
    required int userId,
    required String newPassword,
  });
  Future<Result<void>> setGrants({
    required int userId,
    required List<String> linkKeys,
  });
  Future<Result<void>> deleteUser(int userId);

  Future<Result<List<AdminDevice>>> listDevices();
  Future<Result<void>> revokeDevice(String deviceId);
  Future<Result<void>> assignDeviceUser({
    required String deviceId,
    required int userId,
    String? machineFingerprint,
  });
  Future<Result<List<AdminActivationRequest>>> listActivationRequests([
    String? status,
  ]);
  Future<Result<void>> approveActivationRequest(String requestId);
  Future<Result<void>> rejectActivationRequest(
    String requestId, {
    String? reason,
  });
  Future<Result<List<AdminAuditLog>>> listAuditLogs({int limit = 100});
  Future<Result<String>> getInstallerPassword();
  Future<Result<void>> setInstallerPassword(String newPassword);
  Future<Result<String>> getAdminPassword();
  Future<Result<void>> setAdminPassword(String newPassword);
  Future<Result<bool>> getTokenRestrictionEnabled();
  Future<Result<void>> setTokenRestrictionEnabled(bool enabled);
  Future<Result<Map<String, dynamic>>> getActiveInstallerOtp();
}
