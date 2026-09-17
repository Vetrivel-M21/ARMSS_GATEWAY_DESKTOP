import 'package:drift/drift.dart';

import 'title_groups_table.dart';

class SubTitleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get titleGroupId => integer().references(TitleGroups, #id)();
  TextColumn get subTitleName => text()();
}
