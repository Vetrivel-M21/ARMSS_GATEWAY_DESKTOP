import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/device_auth/device_identity_service.dart';
import '../../../../core/device_auth/device_token_repository.dart';

class DeviceAccessState {
  final bool isRevoked;
  final bool isLoading;
  final String? reason;
  final String deviceId;
  final String requestStatus; // 'none', 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? message;
  final DateTime? lastCheckedAt;

  const DeviceAccessState({
    this.isRevoked = false,
    this.isLoading = false,
    this.reason,
    this.deviceId = '',
    this.requestStatus = 'none',
    this.rejectionReason,
    this.message,
    this.lastCheckedAt,
  });

  DeviceAccessState copyWith({
    bool? isRevoked,
    bool? isLoading,
    String? reason,
    String? deviceId,
    String? requestStatus,
    String? rejectionReason,
    String? message,
    DateTime? lastCheckedAt,
  }) {
    return DeviceAccessState(
      isRevoked: isRevoked ?? this.isRevoked,
      isLoading: isLoading ?? this.isLoading,
      reason: reason ?? this.reason,
      deviceId: deviceId ?? this.deviceId,
      requestStatus: requestStatus ?? this.requestStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      message: message ?? this.message,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

class DeviceAccessController extends Notifier<DeviceAccessState> {
  final _identityService = DeviceIdentityService();
  final _repository = DeviceTokenRepository();

  @override
  DeviceAccessState build() {
    _initAndCheck();
    return const DeviceAccessState();
  }

  Future<void> _initAndCheck() async {
    final devId = await _identityService.getDeviceId();
    state = state.copyWith(deviceId: devId);
    await checkStatus();
  }

  /// Validates the device token against the backend and updates revocation state.
  Future<void> checkStatus() async {
    final identity = await _identityService.getIdentity();
    final deviceId = await _identityService.getDeviceId();

    if (identity == null || identity.token.isEmpty) {
      state = state.copyWith(
        isRevoked: true,
        reason: 'no_token',
        deviceId: deviceId,
        lastCheckedAt: DateTime.now(),
      );
      await _checkPendingActivation(deviceId);
      return;
    }

    var result = await _repository.validateToken(
      deviceId: identity.deviceId,
      token: identity.token,
    );

    if (result.isSuccess &&
        !result.valueOrNull!.isValid &&
        result.valueOrNull!.reason == 'device_not_found') {
      final newIdentity = await _identityService.registerDeviceOnServer();
      if (newIdentity != null) {
        result = await _repository.validateToken(
          deviceId: newIdentity.deviceId,
          token: newIdentity.token,
        );
      }
    }

    if (result.isSuccess) {
      final val = result.valueOrNull!;
      if (val.isValid) {
        state = state.copyWith(
          isRevoked: false,
          reason: null,
          deviceId: identity.deviceId,
          requestStatus: 'none',
          rejectionReason: null,
          message: null,
          lastCheckedAt: DateTime.now(),
        );
        return;
      }

      state = state.copyWith(
        isRevoked: true,
        reason: val.reason ?? 'revoked_by_admin',
        deviceId: identity.deviceId,
        lastCheckedAt: DateTime.now(),
      );
      await _checkPendingActivation(identity.deviceId);
    }
  }

  Future<void> _checkPendingActivation(String deviceId) async {
    final actResult = await _repository.checkActivation(deviceId: deviceId);
    if (actResult.isSuccess) {
      final actData = actResult.valueOrNull!;
      if (actData.status == 'approved' &&
          actData.token != null &&
          actData.token!.isNotEmpty) {
        // Validate this token before unmarking revocation!
        final val = await _repository.validateToken(
          deviceId: deviceId,
          token: actData.token!,
        );
        if (val.isSuccess && val.valueOrNull!.isValid) {
          await _identityService.saveToken(actData.token!, deviceId: deviceId);
          state = state.copyWith(
            isRevoked: false,
            requestStatus: 'approved',
            reason: null,
            message: 'Access has been approved and restored.',
          );
          return;
        } else {
          // Token is revoked or invalid on server - remain revoked!
          state = state.copyWith(
            isRevoked: true,
            requestStatus: 'none',
            reason: 'revoked_by_admin',
          );
          return;
        }
      } else if (actData.status == 'pending') {
        state = state.copyWith(
          isRevoked: true,
          requestStatus: 'pending',
          message: 'Activation request is pending administrator approval.',
        );
        return;
      } else if (actData.status == 'rejected') {
        state = state.copyWith(
          isRevoked: true,
          requestStatus: 'rejected',
          rejectionReason: actData.reason,
          message: actData.reason != null
              ? 'Request rejected: ${actData.reason}'
              : 'Activation request was rejected.',
        );
        return;
      } else {
        state = state.copyWith(requestStatus: 'none');
      }
    }
  }

  /// Submits an activation request to unblock this device.
  Future<bool> requestActivation({String? domain}) async {
    state = state.copyWith(isLoading: true, message: null);
    final devId = state.deviceId.isNotEmpty
        ? state.deviceId
        : await _identityService.getDeviceId();

    final result = await _repository.requestActivation(
      deviceId: devId,
      domainRequested: domain ?? 'Desktop Portal Launcher',
    );

    if (result.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        isRevoked: true,
        requestStatus: 'pending',
        message: 'Activation request submitted! Waiting for admin approval.',
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        message: result.errorOrNull?.message ?? 'Failed to submit activation request.',
      );
      return false;
    }
  }

  /// Checks if an administrator has approved the pending request.
  Future<bool> pollApproval() async {
    state = state.copyWith(isLoading: true);
    final devId = state.deviceId.isNotEmpty
        ? state.deviceId
        : await _identityService.getDeviceId();

    final actResult = await _repository.checkActivation(deviceId: devId);
    state = state.copyWith(isLoading: false);

    if (actResult.isSuccess) {
      final actData = actResult.valueOrNull!;
      if (actData.status == 'approved' &&
          actData.token != null &&
          actData.token!.isNotEmpty) {
        final val = await _repository.validateToken(
          deviceId: devId,
          token: actData.token!,
        );
        if (val.isSuccess && val.valueOrNull!.isValid) {
          await _identityService.saveToken(actData.token!, deviceId: devId);
          state = state.copyWith(
            isRevoked: false,
            requestStatus: 'approved',
            reason: null,
            message: 'Access approved! You can now access all portal apps.',
          );
          return true;
        } else {
          state = state.copyWith(
            isRevoked: true,
            requestStatus: 'none',
            message: 'Access is still revoked by administrator.',
          );
          return false;
        }
      } else if (actData.status == 'rejected') {
        state = state.copyWith(
          isRevoked: true,
          requestStatus: 'rejected',
          rejectionReason: actData.reason,
          message: 'Request was rejected: ${actData.reason ?? "No reason given."}',
        );
      } else if (actData.status == 'pending') {
        state = state.copyWith(
          isRevoked: true,
          requestStatus: 'pending',
          message: 'Still pending. Admin has not approved this request yet.',
        );
      }
    }
    return false;
  }

  /// Directly mark access revoked (e.g. from link launcher rejection).
  void markRevoked({required String reason, required String deviceId}) {
    state = state.copyWith(
      isRevoked: true,
      reason: reason,
      deviceId: deviceId,
    );
    _checkPendingActivation(deviceId);
  }
}

final deviceAccessControllerProvider =
    NotifierProvider<DeviceAccessController, DeviceAccessState>(
  DeviceAccessController.new,
);
