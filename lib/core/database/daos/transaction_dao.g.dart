// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $BalanceEntriesTable get balanceEntries => attachedDatabase.balanceEntries;
  $SubTitlesTable get subTitles => attachedDatabase.subTitles;
  $TitlesTable get titles => attachedDatabase.titles;
  TransactionDaoManager get managers => TransactionDaoManager(this);
}

class TransactionDaoManager {
  final _$TransactionDaoMixin _db;
  TransactionDaoManager(this._db);
  $$BalanceEntriesTableTableManager get balanceEntries =>
      $$BalanceEntriesTableTableManager(
        _db.attachedDatabase,
        _db.balanceEntries,
      );
  $$SubTitlesTableTableManager get subTitles =>
      $$SubTitlesTableTableManager(_db.attachedDatabase, _db.subTitles);
  $$TitlesTableTableManager get titles =>
      $$TitlesTableTableManager(_db.attachedDatabase, _db.titles);
}
