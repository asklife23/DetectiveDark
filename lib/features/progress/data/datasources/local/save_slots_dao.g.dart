// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_slots_dao.dart';

// ignore_for_file: type=lint
mixin _$SaveSlotsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SaveSlotsTable get saveSlots => attachedDatabase.saveSlots;
  $SaveBackupsTable get saveBackups => attachedDatabase.saveBackups;
  SaveSlotsDaoManager get managers => SaveSlotsDaoManager(this);
}

class SaveSlotsDaoManager {
  final _$SaveSlotsDaoMixin _db;
  SaveSlotsDaoManager(this._db);
  $$SaveSlotsTableTableManager get saveSlots =>
      $$SaveSlotsTableTableManager(_db.attachedDatabase, _db.saveSlots);
  $$SaveBackupsTableTableManager get saveBackups =>
      $$SaveBackupsTableTableManager(_db.attachedDatabase, _db.saveBackups);
}
