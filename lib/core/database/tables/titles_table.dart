import 'package:drift/drift.dart';

import 'departments_table.dart';
import 'main_titles_table.dart';
import 'title_groups_table.dart';
import 'users_table.dart';

/// Chart-of-accounts line item; belongs to exactly one department. Kept as
/// the old app's generic hierarchy across all 4 main-title categories rather
/// than type-specific asset/liability/expense tables — see the implementation
/// plan's "Key Behavioral Reconciliations" section for why.
class Titles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mainTitleId => integer().references(MainTitles, #id)();
  IntColumn get departmentId => integer().references(Departments, #id)();
  IntColumn get titleGroupId =>
      integer().nullable().references(TitleGroups, #id)();
  TextColumn get titleName => text()();
  TextColumn get vfNo => text().nullable()();
  IntColumn get createdBy => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
