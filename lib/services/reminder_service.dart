import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> init({
    void Function(NotificationResponse)? onNotificationTap,
  }) async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Timezone fallback used: $e');
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    const reminderChannel = AndroidNotificationChannel(
      'note_reminders',
      'Note Reminders',
      description: 'Reminders for your saved notes',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    const updateChannel = AndroidNotificationChannel(
      'app_updates',
      'App Updates',
      description: 'Notifications about new app versions',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    await _androidPlugin?.createNotificationChannel(reminderChannel);
    await _androidPlugin?.createNotificationChannel(updateChannel);

    _initialized = true;
  }

  Future<void> ensurePermissions() async {
    await init();
    await _androidPlugin?.requestNotificationsPermission();
    await _androidPlugin?.requestExactAlarmsPermission();
  }

  int notificationIdForNote(String noteId) =>
      noteId.hashCode.abs() % 2147483647;

  tz.TZDateTime _toScheduledTz(DateTime dateTime) {
    return tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  String _noteBody(Map<String, dynamic> data) {
    final content = data['content'] as String?;
    if (content != null && content.isNotEmpty) return content;

    final tasks = data['tasks'] as List<dynamic>?;
    if (tasks != null && tasks.isNotEmpty) {
      return tasks
          .map((task) => task['text']?.toString() ?? '')
          .where((text) => text.isNotEmpty)
          .join('\n');
    }
    return 'You have a note reminder';
  }

  Future<bool> scheduleReminder({
    required String noteId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await ensurePermissions();

    final scheduledTz = _toScheduledTz(scheduledAt);
    if (!scheduledTz.isAfter(tz.TZDateTime.now(tz.local))) {
      return false;
    }

    await cancelReminder(noteId);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'note_reminders',
        'Note Reminders',
        channelDescription: 'Reminders for your saved notes',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
    );

    final notificationTitle =
        title.isNotEmpty ? title : 'Note Reminder';
    final notificationBody =
        body.isNotEmpty ? body : 'You have a note reminder';

    try {
      await _plugin.zonedSchedule(
        notificationIdForNote(noteId),
        notificationTitle,
        notificationBody,
        scheduledTz,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (e) {
      debugPrint('Exact reminder schedule failed: $e');
      try {
        await _plugin.zonedSchedule(
          notificationIdForNote(noteId),
          notificationTitle,
          notificationBody,
          scheduledTz,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        return true;
      } catch (e2) {
        debugPrint('Reminder schedule failed: $e2');
        return false;
      }
    }
  }

  Future<void> cancelReminder(String noteId) async {
    await init();
    await _plugin.cancel(notificationIdForNote(noteId));
  }

  static const int appUpdateNotificationId = 900001;

  Future<void> showAppUpdateNotification({
    required String title,
    required String body,
  }) async {
    await ensurePermissions();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'app_updates',
        'App Updates',
        channelDescription: 'Notifications about new app versions',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await _plugin.show(
      appUpdateNotificationId,
      title,
      body,
      details,
      payload: 'app_update',
    );
  }

  Future<void> syncRemindersFromFirestore(String userId) async {
    await ensurePermissions();

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .get();

    final now = DateTime.now();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final reminderAt = data['reminderAt'] as Timestamp?;
      if (reminderAt == null) continue;

      final scheduledAt = reminderAt.toDate();
      if (!scheduledAt.isAfter(now)) continue;

      await scheduleReminder(
        noteId: doc.id,
        title: data['title']?.toString() ?? 'Note Reminder',
        body: _noteBody(data),
        scheduledAt: scheduledAt,
      );
    }
  }
}
