import 'package:drift/drift.dart';

class Permissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get module => text()();
  TextColumn get action => text()();
  TextColumn get description => text().nullable()();
}
