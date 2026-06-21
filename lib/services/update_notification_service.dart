import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reminder_service.dart';

const playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.viveksingh.notepad_app';
const updateTopic = 'app_updates';
const productionSettingsPath = 'app_settings/production';
const productionConfigUrl =
    'https://raw.githubusercontent.com/vivek-notepad/vivek_notepad_app/main/config/production_version.json';
const bundledProductionConfigAsset = 'config/production_version.json';
const _lastNotifiedKey = 'last_notified_update_v3';

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

  bool _initialized = false;

  static void handleNotificationResponse(NotificationResponse response) {
    if (response.payload == 'app_update') {
      instance.openPlayStore();
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    try {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance
          .subscribeToTopic(updateTopic)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      _log('FCM setup failed: $e');
    }

    FirebaseMessaging.onMessage.listen(_showUpdateFromMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _showUpdateFromMessage(message);
      openPlayStore();
    });

    try {
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        await _showUpdateFromMessage(initialMessage);
      }
    } catch (e) {
      _log('Initial FCM message check failed: $e');
    }

    _initialized = true;
  }

  void _log(String message) {
    debugPrint('UpdateNotification: $message');
  }

  int _readVersionCode(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) return value != 0;
    return false;
  }

  int _readLatestVersionCode(Map<String, dynamic> data) {
    return _readVersionCode(
      data['latestVersionCode'] ??
          data['latest_version_code'] ??
          data['versionCode'] ??
          data['version_code'],
    );
  }

  Map<String, dynamic>? _parseSettingsJson(String body, String source) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        _log('Loaded production settings from $source');
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      _log('Parse $source failed: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchFromFirestore() async {
    final ref = FirebaseFirestore.instance.doc(productionSettingsPath);

    for (final source in [Source.server, Source.cache, Source.serverAndCache]) {
      try {
        final doc = await ref.get(GetOptions(source: source));
        if (doc.exists && doc.data() != null) {
          _log('Loaded production settings from Firestore (${source.name})');
          return doc.data();
        }
      } catch (e) {
        _log('Firestore ${source.name} failed: $e');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchRemoteJson() async {
    if (kIsWeb) return null;

    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(productionConfigUrl));
      final response = await request.close();
      if (response.statusCode != 200) {
        _log('Remote JSON HTTP ${response.statusCode}');
        return null;
      }
      final body = await response.transform(utf8.decoder).join();
      return _parseSettingsJson(body, 'GitHub config');
    } catch (e) {
      _log('Remote JSON fetch failed: $e');
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  Future<Map<String, dynamic>?> _fetchBundledConfig() async {
    try {
      final body = await rootBundle.loadString(bundledProductionConfigAsset);
      return _parseSettingsJson(body, 'bundled asset');
    } catch (e) {
      _log('Bundled config load failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchProductionSettings() async {
    final firestore = await _fetchFromFirestore();
    if (firestore != null) return firestore;

    final remote = await _fetchRemoteJson();
    if (remote != null) return remote;

    return _fetchBundledConfig();
  }

  /// Checks production config (Firestore → GitHub → bundled file) and prompts
  /// users on older versions. Call after the first frame.
  Future<void> checkForProductionUpdate({
    AppUpdatePromptCallback? onInAppPrompt,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = _readVersionCode(packageInfo.buildNumber);

      _log(
        'Installed versionCode=$currentVersionCode '
        'versionName=${packageInfo.version}',
      );

      final data = await _fetchProductionSettings();
      if (data == null) {
        _log('No production settings found from any source');
        return;
      }

      final latestVersionCode = _readLatestVersionCode(data);
      _log('Resolved latestVersionCode=$latestVersionCode');

      if (latestVersionCode <= 0) {
        _log('Skipped: latestVersionCode is missing or invalid');
        return;
      }

      if (latestVersionCode <= currentVersionCode) {
        _log(
          'Skipped: app is up to date '
          '(installed=$currentVersionCode, latest=$latestVersionCode)',
        );
        return;
      }

      final forceNotify = _readBool(data['forceNotify']);
      if (!forceNotify) {
        final prefs = await SharedPreferences.getInstance();
        final lastNotified = prefs.getString(_lastNotifiedKey);
        if (lastNotified == '$latestVersionCode') {
          _log('Skipped: already prompted for version $latestVersionCode');
          return;
        }
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

      _log('Update available — showing prompt for v$latestVersionCode');

      if (onInAppPrompt != null) {
        onInAppPrompt(info);
      } else {
        await ReminderService.instance.showAppUpdateNotification(
          title: title,
          body: body,
        );
      }

      if (onInAppPrompt != null) {
        await ReminderService.instance.showAppUpdateNotification(
          title: title,
          body: body,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNotifiedKey, '$latestVersionCode');
    } catch (e, stack) {
      _log('Check failed: $e');
      _log('$stack');
    }
  }

  Future<void> openPlayStore() async {
    final uri = Uri.parse(playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
