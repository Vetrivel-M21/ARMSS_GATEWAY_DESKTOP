class AdminDevice {
  final String deviceId;
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final String machineFingerprint;
  final String tokenStatus;
  final int tokenVersion;
  final DateTime lastOtpVerifiedAt;
  final bool isOtpExpired;
  final DateTime createdAt;

  const AdminDevice({
    required this.deviceId,
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.machineFingerprint,
    required this.tokenStatus,
    required this.tokenVersion,
    required this.lastOtpVerifiedAt,
    required this.isOtpExpired,
    required this.createdAt,
  });
}
