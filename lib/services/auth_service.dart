import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userPointsKey = 'user_points';
  static const String _completedQuizzesKey = 'completed_quizzes';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Authentication
  Future<void> login(String email, String userId, String? name) async {
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userEmailKey, email);
    await _prefs.setString(_userIdKey, userId);
    if (name != null) {
      await _prefs.setString(_userNameKey, name);
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Ignore if no Google session exists.
    }

    await _prefs.setBool(_isLoggedInKey, false);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userPointsKey);
    await _prefs.remove(_completedQuizzesKey);
  }

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  String? get userEmail => _prefs.getString(_userEmailKey);

  String? get userId => _prefs.getString(_userIdKey);

  String? get userName => _prefs.getString(_userNameKey);

  // Quiz data persistence
  Future<void> addCompletedQuiz(String quizId, int pointsEarned) async {
    final completedList = _prefs.getStringList(_completedQuizzesKey) ?? [];
    if (!completedList.contains(quizId)) {
      completedList.add(quizId);
      await _prefs.setStringList(_completedQuizzesKey, completedList);
    }

    // Update points
    int currentPoints = _prefs.getInt(_userPointsKey) ?? 0;
    await _prefs.setInt(_userPointsKey, currentPoints + pointsEarned);
  }

  List<String> get completedQuizzes =>
      _prefs.getStringList(_completedQuizzesKey) ?? [];

  int get userPoints => _prefs.getInt(_userPointsKey) ?? 0;

  Future<void> resetProgress() async {
    await _prefs.remove(_userPointsKey);
    await _prefs.remove(_completedQuizzesKey);
  }

  Future<void> updateUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  Future<UserCredential> signInWithGoogle() async {
    final firebaseAuth = FirebaseAuth.instance;
    late UserCredential credential;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      credential = await firebaseAuth.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      credential = await firebaseAuth.signInWithCredential(authCredential);
    }

    final user = credential.user;
    if (user == null) {
      throw Exception('Google sign-in failed');
    }

    if (credential.additionalUserInfo?.isNewUser ?? false) {
      await FirestoreService().initializeUserProfile(user);
    }

    await login(user.email ?? '', user.uid, user.displayName);
    return credential;
  }
}

final authService = AuthService();
