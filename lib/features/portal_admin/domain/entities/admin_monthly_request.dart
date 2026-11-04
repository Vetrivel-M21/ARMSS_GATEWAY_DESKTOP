class AdminMonthlyRequest {
  final String id;
  final int userId;
  final String username;
  final String fullName;
  final String email;
  final String department;
  final String branch;
  final String deviceId;
  final String machineFingerprint;
  final bool otpVerified;
  final DateTime? otpVerifiedAt;
  final String status; // 'pending_otp', 'pending_approval', 'approved', 'rejected'
  final int? approvedBy;
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime requestedAt;
  final DateTime createdAt;

  const AdminMonthlyRequest({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.email,
    required this.department,
    required this.branch,
    required this.deviceId,
    required this.machineFingerprint,
    required this.otpVerified,
    this.otpVerifiedAt,
    required this.status,
    this.approvedBy,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
    required this.requestedAt,
    required this.createdAt,
  });
}

