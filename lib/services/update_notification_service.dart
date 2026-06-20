import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reminder_service.dart';

const playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app';
const updateTopic = 'app_updates';
const productionSettingsPath = 'app_settings/production';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await ReminderService.instance.init();
  await _showUpdateFromMessage(message);
}

Future<void> _showUpdateFromMessage(RemoteMessage message) async {
  final title = message.notification?.title ??
      message.data['title'] ??
      'New version available';
  final body = message.notification?.body ??
      message.data['body'] ??
      'Update Simple Notepad from Google Play Store';

  await ReminderService.instance.showAppUpdateNotification(
    title: title,
    body: body,
  );
}

class UpdateNotificationService {
  UpdateNotificationService._();
  static final UpdateNotificationService instance = UpdateNotificationService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialized = false;

  static void handleNotificationResponse(NotificationResponse response) {
    if (response.payload == 'app_update') {
      instance._openPlayStore();
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic(updateTopic);

    FirebaseMessaging.onMessage.listen(_showUpdateFromMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _showUpdateFromMessage(message);
      _openPlayStore();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _showUpdateFromMessage(initialMessage);
    }

    await checkForProductionUpdate();
    _initialized = true;
  }

  /// Checks Firestore production config and notifies users on older versions.
  Future<void> checkForProductionUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      final doc = await FirebaseFirestore.instance
          .doc(productionSettingsPath)
          .get();
      if (!doc.exists) return;

      final data = doc.data();
      if (data == null) return;

      final latestVersionCode = data['latestVersionCode'] as int? ?? 0;
      if (latestVersionCode <= currentVersionCode) return;

      final lastNotified = await _storage.read(key: 'last_notified_update');
      if (lastNotified == '$latestVersionCode') return;

      final title = data['updateTitle'] as String? ?? 'New version available';
      final versionName =
          data['latestVersionName'] as String? ?? packageInfo.version;
      final body = data['updateMessage'] as String? ??
          'Version $versionName is now on Google Play. Tap to update.';

      await ReminderService.instance.showAppUpdateNotification(
        title: title,
        body: body,
      );
      await _storage.write(
        key: 'last_notified_update',
        value: '$latestVersionCode',
      );
    } catch (e) {
      debugPrint('Production update check failed: $e');
    }
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
