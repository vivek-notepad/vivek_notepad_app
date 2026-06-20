import 'package:flutter/material.dart';
import 'package:simple_notepad/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/notes_home_page.dart';
import 'screens/locked_notes_page.dart';
import 'screens/security_setup_page.dart';
import 'screens/our_apps_page.dart';
import 'screens/widget_setup_page.dart';
import 'screens/language_settings_page.dart';
import 'services/reminder_service.dart';
import 'services/update_notification_service.dart';
import 'services/widget_service.dart';
import 'services/locale_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  await LocaleService.instance.init();
  await WidgetService.instance.init();
  await ReminderService.instance.init(
    onNotificationTap: UpdateNotificationService.handleNotificationResponse,
  );
  await UpdateNotificationService.instance.init();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    await ReminderService.instance.syncRemindersFromFirestore(userId);
    await WidgetService.instance.syncFromFirestore(userId);
  }
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          locale: LocaleService.instance.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
          ),
          home: const NotesHomePage(),
          routes: {
            '/locked-notes': (context) => const LockedNotesPage(),
            '/security-setup': (context) => const SecuritySetupPage(),
            '/our-apps': (context) => const OurAppsPage(),
            '/widget-setup': (context) => const WidgetSetupPage(),
            '/language': (context) => const LanguageSettingsPage(),
          },
        );
      },
    );
  }
}
