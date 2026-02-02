import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Holds current Firebase user and notifies when auth state changes.
/// Used by GoRouter's refreshListenable for redirects.
class AuthState extends ChangeNotifier {
  AuthState() {
    _subscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (_user != user) {
        _user = user;
        notifyListeners();
      }
    });
  }

  late final StreamSubscription<User?> _subscription;
  User? _user;

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
