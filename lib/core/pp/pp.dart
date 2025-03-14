import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tadhkir_app/notification_service.dart';
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

  /// ✅ **تحديث وقت المجموعة مع إعادة جدولة الإشعار**
  Future<void> updateData(
    TimeOfDay newTime,
    int id,
    BuildContext context,
  ) async {
    DateTime now = DateTime.now();
    String selectedTime = DateFormat('hh:mm a').format(
      DateTime(now.year, now.month, now.day, newTime.hour, newTime.minute),
    );

    // 🔹 إلغاء الإشعار القديم قبل التحديث
    await NotificationService.cancelNotification(id);

    // 🔹 تحديث وقت التذكير في قاعدة البيانات
    int response = await sqlDb.updateData('''
      UPDATE Groups SET
      time = "$selectedTime",
      active = 1
      WHERE id = $id
  ''');

    if (response > 0) {
      debugPrint("✅ تم تعديل مجموعة التذكير بنجاح: $selectedTime");

      // 🔹 جدولة إشعار جديد بالوقت المعدل
      NotificationService.scheduleNotification(
        id,
        newTime.hour,
        newTime.minute,
        context,
      );

      // 🔹 تحديث القائمة
      loadGroups();
    }
  }

  /// ✅ **حذف المجموعة وجميع جهات الاتصال المرتبطة بها**
  Future<void> deleteData(int id) async {
    // حذف جهات الاتصال المرتبطة بالمجموعة
    await sqlDb.deleteData("DELETE FROM Contacts WHERE group_id = $id");

    // حذف المجموعة
    int responseGroup = await sqlDb.deleteData(
      "DELETE FROM Groups WHERE id = $id",
    );

    if (responseGroup > 0) {
      debugPrint("🗑️ تم حذف مجموعة التذكير بنجاح: ID = $id");
      loadGroups();
    }
  }
}
