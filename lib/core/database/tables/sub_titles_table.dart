import 'package:drift/drift.dart';

import 'sub_title_groups_table.dart';
import 'titles_table.dart';
import 'users_table.dart';

/// The actual tracked item under a title; carries the opening balance that
/// [BalanceEntries] rows accumulate against.
class SubTitles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get titleId =>
      integer().references(Titles, #id, onDelete: KeyAction.cascade)();
  IntColumn get subTitleGroupId =>
      integer().nullable().references(SubTitleGroups, #id)();
  TextColumn get subTitleName => text()();
  RealColumn get openingBalance =>
      real().withDefault(const Constant(0))();
  IntColumn get createdBy => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
