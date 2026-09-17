// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_dao.dart';

// ignore_for_file: type=lint
mixin _$ExportDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExportPasswordHistoryTable get exportPasswordHistory =>
      attachedDatabase.exportPasswordHistory;
  ExportDaoManager get managers => ExportDaoManager(this);
}

class ExportDaoManager {
  final _$ExportDaoMixin _db;
  ExportDaoManager(this._db);
  $$ExportPasswordHistoryTableTableManager get exportPasswordHistory =>
      $$ExportPasswordHistoryTableTableManager(
        _db.attachedDatabase,
        _db.exportPasswordHistory,
      );
}
