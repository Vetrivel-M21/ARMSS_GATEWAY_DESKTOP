// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  AuditDaoManager get managers => AuditDaoManager(this);
}

class AuditDaoManager {
  final _$AuditDaoMixin _db;
  AuditDaoManager(this._db);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
