import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/notes_home_page.dart';
import 'screens/locked_notes_page.dart';
import 'screens/security_setup_page.dart';
import 'screens/batch_notes_page.dart'; // Ensure this import is present

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const NotepadApp());
}

class NotepadApp extends StatelessWidget {
  const NotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notepad',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const NotesHomePage(),
      routes: {
        '/locked-notes': (context) => const LockedNotesPage(),
        '/security-setup': (context) => const SecuritySetupPage()
      },
    );
  }
}