import 'package:flutter/material.dart';
import 'package:tadhkir_app/sqldb.dart';

class AlarmGroupProvider extends ChangeNotifier {
  SqlDb sqlDb = SqlDb();
  List<Map> groups = [];
  bool isLoading = true;

  AlarmGroupProvider() {
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading = true;
    notifyListeners();
    groups = await sqlDb.readData("SELECT * FROM Groups");
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateGroupState(int groupId) async {
    await sqlDb.updateData('UPDATE Groups SET active = 0 WHERE id = $groupId');
    loadGroups();
  }
}
