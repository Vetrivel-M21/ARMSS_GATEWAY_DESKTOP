import 'package:drift/drift.dart';

import 'main_titles_table.dart';

/// Cross-department correlation anchor. Created lazily, only the first time
/// "apply to all departments" is used on a title (matching the old app's
/// opt-in checkbox) — titles created without that flag stay ungrouped and
/// behave independently, exactly as in the old app.
class TitleGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mainTitleId => integer().references(MainTitles, #id)();
  TextColumn get titleName => text()();
  TextColumn get vfNo => text().nullable()();
}
