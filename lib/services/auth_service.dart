import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  User? _user;

  User? get user => _user;
  String? get userId => _user?.uid;

  Future<void> ensureSignedIn() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) return;

    try {
      final credential = await FirebaseAuth.instance
          .signInAnonymously()
          .timeout(const Duration(seconds: 8));
      _user = credential.user;
    } catch (e) {
      debugPrint('Anonymous sign-in failed: $e');
      try {
        _user = await FirebaseAuth.instance
            .authStateChanges()
            .firstWhere((user) => user != null)
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        _user = FirebaseAuth.instance.currentUser;
      }
    }
  }
}
