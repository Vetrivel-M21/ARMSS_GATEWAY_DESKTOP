// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_book_dao.dart';

// ignore_for_file: type=lint
mixin _$DayBookDaoMixin on DatabaseAccessor<AppDatabase> {
  $DayBooksTable get dayBooks => attachedDatabase.dayBooks;
  $ClosingBalanceChecksTable get closingBalanceChecks =>
      attachedDatabase.closingBalanceChecks;
  DayBookDaoManager get managers => DayBookDaoManager(this);
}

class DayBookDaoManager {
  final _$DayBookDaoMixin _db;
  DayBookDaoManager(this._db);
  $$DayBooksTableTableManager get dayBooks =>
      $$DayBooksTableTableManager(_db.attachedDatabase, _db.dayBooks);
  $$ClosingBalanceChecksTableTableManager get closingBalanceChecks =>
      $$ClosingBalanceChecksTableTableManager(
        _db.attachedDatabase,
        _db.closingBalanceChecks,
      );
}
