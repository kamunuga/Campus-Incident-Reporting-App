import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:campusfix/core/constants/app_constants.dart';
import 'package:campusfix/models/app_user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(AppConstants.usersCollection);

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<AppUser?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromMap(doc.id, doc.data()!) : null;
  }

  Future<void> createProfile(User user, {String? name}) {
    final email = user.email ?? '';
    final displayName = (name ?? user.displayName ?? '').trim();
    final profile = AppUser(
      uid: user.uid,
      name: displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
      role: UserRole.student,
    );
    return _users.doc(user.uid).set(profile.toCreateMap());
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    await createProfile(user, name: name);
    await user.sendEmailVerification();
  }

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<bool> reloadAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshed = _auth.currentUser;
    final verified = refreshed?.emailVerified ?? false;
    if (verified) await refreshed!.getIdToken(true);
    return verified;
  }

  static String messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact campus support.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
