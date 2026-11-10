import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:campusfix/models/app_user.dart';
import 'package:campusfix/services/auth_service.dart';

enum SessionStatus { loading, signedOut, unverified, ready, error }

class SessionProvider extends ChangeNotifier {
  SessionProvider(this._auth) {
    _authSub = _auth.authStateChanges().listen(_handleAuthUser);
  }

  final AuthService _auth;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  SessionStatus _status = SessionStatus.loading;
  AppUser? _user;
  User? _firebaseUser;
  bool _busy = false;
  String? _error;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;
  String? get pendingEmail => _firebaseUser?.email;
  bool get isStaff => _user?.isStaff ?? false;

  void _handleAuthUser(User? firebaseUser) {
    _profileSub?.cancel();
    _profileSub = null;
    _firebaseUser = firebaseUser;
    _user = null;

    if (firebaseUser == null) {
      _setStatus(SessionStatus.signedOut);
      return;
    }
    if (!firebaseUser.emailVerified) {
      _setStatus(SessionStatus.unverified);
      return;
    }

    _setStatus(SessionStatus.loading);
    _profileSub = _auth.watchProfile(firebaseUser.uid).listen(
      (profile) async {
        if (profile == null) {
          try {
            await _auth.createProfile(firebaseUser);
          } catch (_) {
            _error = 'We could not set up your profile. Please try again.';
            _setStatus(SessionStatus.error);
          }
          return;
        }
        _user = profile;
        _error = null;
        _setStatus(SessionStatus.ready);
      },
      onError: (Object _) {
        _error = 'We could not load your profile. Check your connection.';
        _setStatus(SessionStatus.error);
      },
    );
  }

  void _setStatus(SessionStatus status) {
    _status = status;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = AuthService.messageFor(e);
      return false;
    } on FirebaseException catch (e) {
      _error = e.message ?? 'Something went wrong. Please try again.';
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) => _run(
        () => _auth.signIn(email: email.trim(), password: password),
      );

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(
        () => _auth.register(
          name: name.trim(),
          email: email.trim(),
          password: password,
        ),
      );

  Future<bool> sendPasswordReset(String email) =>
      _run(() => _auth.sendPasswordReset(email.trim()));

  Future<bool> resendVerification() =>
      _run(() => _auth.sendEmailVerification());

  Future<bool> checkVerification() async {
    try {
      final verified = await _auth.reloadAndCheckVerified();
      if (verified) _handleAuthUser(_auth.currentUser);
      return verified;
    } catch (_) {
      return false;
    }
  }

  void retry() => _handleAuthUser(_auth.currentUser);

  Future<void> signOut() => _auth.signOut();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
