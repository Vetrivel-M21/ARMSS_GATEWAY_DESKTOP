class AdminAuditLog {
  final int id;
  final String eventType;
  final int? userId;
  final String? deviceId;
  final String actor;
  final String metadata;
  final DateTime createdAt;

  const AdminAuditLog({
    required this.id,
    required this.eventType,
    this.userId,
    this.deviceId,
    required this.actor,
    required this.metadata,
    required this.createdAt,
  });
}
