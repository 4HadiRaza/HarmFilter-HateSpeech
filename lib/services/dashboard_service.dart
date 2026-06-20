import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:harmfilter_flutter/models/post_model.dart';
import 'package:harmfilter_flutter/models/daily_analytics.dart';
import 'package:harmfilter_flutter/models/user_profile.dart';
import 'package:intl/intl.dart';

/// Holds all the data the dashboard screen needs in one object.
class DashboardData {
  final UserProfile userProfile;
  final int totalPostsAnalyzed;
  final int totalWarnings;
  final int totalSafePosts;
  final int safeCount;
  final int offensiveCount;
  final int hatefulCount;
  final List<DailyAnalytics> weeklyAnalytics; // last 7 days
  final List<PostModel> recentFlaggedPosts;
  final bool needsProfileSync;

  const DashboardData({
    required this.userProfile,
    required this.totalPostsAnalyzed,
    required this.totalWarnings,
    required this.totalSafePosts,
    required this.safeCount,
    required this.offensiveCount,
    required this.hatefulCount,
    required this.weeklyAnalytics,
    required this.recentFlaggedPosts,
    this.needsProfileSync = false,
  });
}

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Fetches all data needed by the dashboard screen.
  Future<DashboardData> getDashboardData() async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    // Run all queries in parallel for speed
    final results = await Future.wait([
      _getUserProfile(uid),
      _getUserPosts(uid),
      _getWeeklyAnalytics(uid),
      _getRecentFlaggedPosts(uid),
    ]);

    final userProfileResult = results[0] as UserProfile?;
    final allPosts = results[1] as List<PostModel>;
    final weeklyAnalytics = results[2] as List<DailyAnalytics>;
    final recentFlaggedPosts = results[3] as List<PostModel>;

    final needsProfileSync = userProfileResult == null;
    final user = _auth.currentUser;
    final userProfile =
        userProfileResult ??
        UserProfile(
          uid: uid,
          displayName:
              user?.displayName ?? user?.email?.split('@').first ?? 'User',
          email: user?.email ?? '',
          points: 0,
          joinedAt: DateTime.now(),
        );

    // Calculate totals from posts
    final safeCount = allPosts.where((p) => p.label == 'normal').length;
    final offensiveCount = allPosts.where((p) => p.label == 'offensive').length;
    final hatefulCount = allPosts.where((p) => p.label == 'hateful').length;

    return DashboardData(
      userProfile: userProfile,
      totalPostsAnalyzed: allPosts.length,
      totalWarnings: offensiveCount + hatefulCount,
      totalSafePosts: safeCount,
      safeCount: safeCount,
      offensiveCount: offensiveCount,
      hatefulCount: hatefulCount,
      weeklyAnalytics: weeklyAnalytics,
      recentFlaggedPosts: recentFlaggedPosts,
      needsProfileSync: needsProfileSync,
    );
  }

  /// Gets the user's profile, returns null if it doesn't exist.
  Future<UserProfile?> _getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  /// Gets all posts analyzed by this user.
  Future<List<PostModel>> _getUserPosts(String uid) async {
    try {
      final snapshot = await _db
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching user posts: $e');
      return [];
    }
  }

  /// Gets the last 7 days of analytics for the line chart.
  Future<List<DailyAnalytics>> _getWeeklyAnalytics(String uid) async {
    try {
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final List<DailyAnalytics> analytics = [];

      // Fetch last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = dateFormat.format(date);

        final doc = await _db
            .collection('analytics')
            .doc(uid)
            .collection('daily')
            .doc(dateStr)
            .get();

        if (doc.exists) {
          analytics.add(DailyAnalytics.fromFirestore(doc));
        } else {
          // No data for this day — add a zero entry
          analytics.add(DailyAnalytics(date: dateStr));
        }
      }

      return analytics;
    } catch (e) {
      debugPrint('Error fetching weekly analytics: $e');
      // Return 7 empty days
      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');
      return List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        return DailyAnalytics(date: dateFormat.format(date));
      });
    }
  }

  /// Gets the 5 most recent flagged (offensive/hateful) posts by this user.
  Future<List<PostModel>> _getRecentFlaggedPosts(String uid) async {
    try {
      final snapshot = await _db
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .where('label', whereIn: ['offensive', 'hateful'])
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching flagged posts: $e');
      return [];
    }
  }

  /// Records that a post was analyzed — updates daily analytics counters.
  /// Call this from the Analyze screen when a post is submitted.
  Future<void> recordAnalysis(String label) async {
    final uid = _uid;
    if (uid == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = _db
        .collection('analytics')
        .doc(uid)
        .collection('daily')
        .doc(dateStr);

    try {
      await docRef.set({
        'totalAnalyzed': FieldValue.increment(1),
        'safeCount': FieldValue.increment(label == 'normal' ? 1 : 0),
        'offensiveCount': FieldValue.increment(label == 'offensive' ? 1 : 0),
        'hatefulCount': FieldValue.increment(label == 'hateful' ? 1 : 0),
        'warningsIssued': FieldValue.increment(
          (label == 'offensive' || label == 'hateful') ? 1 : 0,
        ),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error recording analytics: $e');
    }
  }

  /// Increments the user's points.
  Future<void> addPoints(int amount) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _db.collection('users').doc(uid).set({
        'points': FieldValue.increment(amount),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding points: $e');
    }
  }

  /// Manually synchronizes the user profile to Firestore
  Future<void> syncProfile() async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');

    final user = _auth.currentUser!;
    final profile = UserProfile(
      uid: uid,
      displayName: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      points: 0,
      joinedAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(profile.toFirestore());
  }
}
