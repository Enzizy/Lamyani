import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  AuthService._();

  static bool get _hasFirebaseApp => Firebase.apps.isNotEmpty;

  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User? get currentUser => _hasFirebaseApp ? _auth.currentUser : null;

  static bool get isAvailable => !kIsWeb;

  static Stream<User?> authStateChanges() {
    if (!_hasFirebaseApp) {
      return const Stream.empty();
    }

    return _auth.authStateChanges();
  }

  static Future<UserCredential> signUp({
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required String email,
    required String mobileNumber,
    required String password,
    required bool emailUpdates,
  }) async {
    if (!_hasFirebaseApp) {
      throw StateError('Firebase is not initialized.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      await credential.user?.updateDisplayName(firstName.trim());

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'fullName': '${firstName.trim()} ${lastName.trim()}'.trim(),
        'birthDate': Timestamp.fromDate(birthDate),
        'email': email.trim(),
        'mobileNumber': mobileNumber.trim(),
        'emailUpdates': emailUpdates,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      // Avoid leaving behind an auth account with no matching profile doc.
      await credential.user?.delete();
      rethrow;
    }

    return credential;
  }

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    if (!_hasFirebaseApp) {
      throw StateError('Firebase is not initialized.');
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final userRef = _firestore.collection('users').doc(credential.user!.uid);
    final profileSnapshot = await userRef.get();

    if (profileSnapshot.exists) {
      await userRef.update({'lastLoginAt': FieldValue.serverTimestamp()});
    }

    return credential;
  }

  static Future<void> signOut() async {
    if (!_hasFirebaseApp) {
      return;
    }

    await _auth.signOut();
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    if (!_hasFirebaseApp) {
      throw StateError('Firebase is not initialized.');
    }

    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<bool> hasAccountForEmail(String email) async {
    if (!_hasFirebaseApp) {
      throw StateError('Firebase is not initialized.');
    }

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream() {
    if (!_hasFirebaseApp) {
      return const Stream.empty();
    }

    final user = currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'That email is already registered.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a stronger password with at least 6 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'network-request-failed':
          return 'Check your internet connection and try again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Your account request was blocked by Firestore rules. Deploy the latest rules and try again.';
      }
      return error.message ?? 'Firebase request failed.';
    }

    if (error is StateError) {
      return 'Firebase is not initialized for this platform.';
    }

    return 'Something went wrong. Please try again.';
  }
}
