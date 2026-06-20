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
const _lastNotifiedKey = 'last_notified_update_v2';

class AppUpdateInfo {
  final String title;
  final String body;
  final int latestVersionCode;

  const AppUpdateInfo({
    required this.title,
    required this.body,
    required this.latestVersionCode,
  });
}

typedef AppUpdatePromptCallback = void Function(AppUpdateInfo info);

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
      instance.openPlayStore();
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.subscribeToTopic(updateTopic);

    FirebaseMessaging.onMessage.listen(_showUpdateFromMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _showUpdateFromMessage(message);
      openPlayStore();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _showUpdateFromMessage(initialMessage);
    }

    _initialized = true;
  }

  int _readVersionCode(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  /// Checks Firestore production config and notifies users on older versions.
  /// Call after the first frame so Android notification permission can be requested.
  Future<void> checkForProductionUpdate({
    AppUpdatePromptCallback? onInAppPrompt,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = _readVersionCode(packageInfo.buildNumber);

      if (kDebugMode) {
        debugPrint(
          'Update check: installed versionCode=$currentVersionCode '
          '(${packageInfo.version})',
        );
      }

      final doc = await FirebaseFirestore.instance
          .doc(productionSettingsPath)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        if (kDebugMode) {
          debugPrint('Update check: $productionSettingsPath not found in Firestore');
        }
        return;
      }

      final data = doc.data();
      if (data == null) return;

      final latestVersionCode = _readVersionCode(data['latestVersionCode']);
      if (kDebugMode) {
        debugPrint('Update check: Firestore latestVersionCode=$latestVersionCode');
      }

      if (latestVersionCode <= 0 || latestVersionCode <= currentVersionCode) {
        return;
      }

      final lastNotified = await _storage.read(key: _lastNotifiedKey);
      if (lastNotified == '$latestVersionCode') {
        return;
      }

      final title = data['updateTitle']?.toString() ?? 'New version available';
      final versionName =
          data['latestVersionName']?.toString() ?? packageInfo.version;
      final body = data['updateMessage']?.toString() ??
          'Version $versionName is now on Google Play. Tap to update.';

      final info = AppUpdateInfo(
        title: title,
        body: body,
        latestVersionCode: latestVersionCode,
      );

      final notified = await ReminderService.instance.showAppUpdateNotification(
        title: title,
        body: body,
      );

      if (notified) {
        await _markNotified(latestVersionCode);
        return;
      }

      if (kDebugMode) {
        debugPrint(
          'Update check: notification not shown (permission denied or blocked). '
          'Trying in-app prompt.',
        );
      }

      if (onInAppPrompt != null) {
        onInAppPrompt(info);
        await _markNotified(latestVersionCode);
      }
    } catch (e, stack) {
      debugPrint('Production update check failed: $e');
      if (kDebugMode) {
        debugPrint('$stack');
      }
    }
  }

  Future<void> _markNotified(int latestVersionCode) async {
    await _storage.write(
      key: _lastNotifiedKey,
      value: '$latestVersionCode',
    );
  }

  Future<void> openPlayStore() async {
    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
