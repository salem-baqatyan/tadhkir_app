import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:tadhkir_app/core/pp/pp.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:provider/provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 🔹 **تهيئة خدمة الإشعارات**
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  /// 🔹 **جدولة إشعار جديد**
  static Future<void> scheduleNotification(
    int groupId,
    int hour,
    int minute,
    BuildContext context,
  ) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    final int notificationId = groupId;
    String formattedTime = DateFormat('hh:mm a').format(scheduledDate);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      '🔔 تذكير المجموعة',
      '⏰ حان وقت تذكير مجموعة الساعة $formattedTime',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm Notifications',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: groupId.toString(), // ✅ تمرير ID المجموعة كـ payload
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    /// 🔹 **تحديث حالة المجموعة عند وصول الإشعار**
    Future.delayed(tzScheduledDate.difference(now), () {
      Provider.of<AlarmGroupProvider>(
        context,
        listen: false,
      ).updateGroupState(groupId);
    });
  }

  /// 🔹 **إلغاء إشعار معين عند تعديل أو حذف مجموعة**
  static Future<void> cancelNotification(int groupId) async {
    await flutterLocalNotificationsPlugin.cancel(groupId);
  }
}
