class AdminActivationRequest {
  final String requestId;
  final int userId;
  final String username;
  final String email;
  final String fullName;
  final String deviceId;
  final String domainRequested;
  final String status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const AdminActivationRequest({
    required this.requestId,
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
    required this.deviceId,
    required this.domainRequested,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.rejectionReason,
  });
}
