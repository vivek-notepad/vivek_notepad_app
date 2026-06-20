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

  int notificationIdForBatchTask(String noteId, int taskIndex) =>
      '$noteId-task-$taskIndex'.hashCode.abs() % 2147483647;

  Future<void> cancelBatchTaskReminder(String noteId, int taskIndex) async {
    await init();
    await _plugin.cancel(notificationIdForBatchTask(noteId, taskIndex));
  }

  Future<void> cancelAllBatchTaskReminders(String noteId, {int maxTasks = 50}) async {
    await init();
    for (var i = 0; i < maxTasks; i++) {
      await _plugin.cancel(notificationIdForBatchTask(noteId, i));
    }
  }

  Future<bool> scheduleBatchTaskReminder({
    required String noteId,
    required int taskIndex,
    required String batchTitle,
    required String taskText,
    required DateTime scheduledAt,
    String? repeat,
  }) async {
    return scheduleReminder(
      noteId: '$noteId-task-$taskIndex',
      title: batchTitle.isNotEmpty ? batchTitle : 'Task Reminder',
      body: taskText.isNotEmpty ? taskText : 'You have a task reminder',
      scheduledAt: scheduledAt,
      repeat: repeat,
    );
  }

  Timestamp? _taskReminderTimestamp(Map<String, dynamic> task) {
    final value = task['reminderAt'];
    if (value is Timestamp) return value;
    return null;
  }

  Future<void> syncBatchTaskReminders(
    String noteId,
    Map<String, dynamic> data,
  ) async {
    await cancelAllBatchTaskReminders(noteId);
    final tasks = data['tasks'] as List<dynamic>?;
    if (tasks == null) return;

    final batchTitle = data['title']?.toString() ?? 'Task Reminder';
    final now = DateTime.now();

    for (var i = 0; i < tasks.length; i++) {
      final task = Map<String, dynamic>.from(tasks[i] as Map);
      final reminderAt = _taskReminderTimestamp(task);
      if (reminderAt == null) continue;

      final repeat = task['reminderRepeat'] as String?;
      final scheduledAt = reminderAt.toDate();
      if (!_isRecurring(repeat) && !scheduledAt.isAfter(now)) continue;

      await scheduleBatchTaskReminder(
        noteId: noteId,
        taskIndex: i,
        batchTitle: batchTitle,
        taskText: task['text']?.toString() ?? '',
        scheduledAt: scheduledAt,
        repeat: repeat,
      );
    }
  }

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

  bool _isRecurring(String? repeat) =>
      repeat != null && repeat.isNotEmpty && repeat != 'none';

  DateTimeComponents? _repeatComponents(String? repeat) {
    switch (repeat) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return null;
    }
  }

  tz.TZDateTime _nextOccurrence(DateTime dateTime, String? repeat) {
    var scheduled = _toScheduledTz(dateTime);
    final now = tz.TZDateTime.now(tz.local);

    if (!_isRecurring(repeat)) {
      return scheduled;
    }

    while (!scheduled.isAfter(now)) {
      switch (repeat) {
        case 'daily':
          scheduled = scheduled.add(const Duration(days: 1));
          break;
        case 'weekly':
          scheduled = scheduled.add(const Duration(days: 7));
          break;
        case 'monthly':
          scheduled = tz.TZDateTime(
            tz.local,
            scheduled.year,
            scheduled.month + 1,
            scheduled.day,
            scheduled.hour,
            scheduled.minute,
          );
          break;
      }
    }
    return scheduled;
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
    String? repeat,
  }) async {
    await ensurePermissions();

    final recurring = _isRecurring(repeat);
    final scheduledTz = _nextOccurrence(scheduledAt, repeat);
    if (!recurring && !scheduledTz.isAfter(tz.TZDateTime.now(tz.local))) {
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
    final components = _repeatComponents(repeat);

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
        matchDateTimeComponents: components,
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
          matchDateTimeComponents: components,
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

  Future<bool> showAppUpdateNotification({
    required String title,
    required String body,
  }) async {
    await init();
    final granted = await _androidPlugin?.requestNotificationsPermission();
    if (granted == false) {
      return false;
    }

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
    return true;
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
      if (data['isBatch'] == true) {
        await syncBatchTaskReminders(doc.id, data);
        continue;
      }

      final reminderAt = data['reminderAt'] as Timestamp?;
      if (reminderAt == null) continue;

      final repeat = data['reminderRepeat'] as String?;
      final scheduledAt = reminderAt.toDate();
      if (!_isRecurring(repeat) && !scheduledAt.isAfter(now)) continue;

      await scheduleReminder(
        noteId: doc.id,
        title: data['title']?.toString() ?? 'Note Reminder',
        body: _noteBody(data),
        scheduledAt: scheduledAt,
        repeat: repeat,
      );
    }
  }
}
