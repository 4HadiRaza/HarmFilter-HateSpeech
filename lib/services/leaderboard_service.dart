import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:harmfilter_flutter/models/leaderboard_item.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get top 100 users by points
  Future<List<LeaderboardItem>> getTopLeaderboard({int limit = 100}) async {
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      final items = <LeaderboardItem>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        items.add(LeaderboardItem.fromFirestore(snapshot.docs[i], i + 1));
      }
      return items;
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Get current user's rank
  Future<int?> getCurrentUserRank() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc =
          await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userPoints = (userDoc['points'] ?? 0).toInt();

      // Count how many users have more points
      final higherCountSnapshot = await _db
          .collection('users')
          .where('points', isGreaterThan: userPoints)
          .count()
          .get();

      final count = higherCountSnapshot.count ?? 0;
      return count + 1;
    } catch (e) {
      debugPrint('Error fetching user rank: $e');
      return null;
    }
  }

  // Get current user's leaderboard item
  Future<LeaderboardItem?> getCurrentUserLeaderboardItem() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _db.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final rank = await getCurrentUserRank();
      if (rank == null) return null;

      return LeaderboardItem.fromFirestore(userDoc, rank);
    } catch (e) {
      debugPrint('Error fetching user leaderboard item: $e');
      return null;
    }
  }

  // Get total number of users
  Future<int> getTotalUserCount() async {
    try {
      final snapshot = await _db.collection('users').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error fetching user count: $e');
      return 0;
    }
  }

  // Stream leaderboard for real-time updates
  Stream<List<LeaderboardItem>> getLeaderboardStream({int limit = 100}) {
    return _db
        .collection('users')
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final items = <LeaderboardItem>[];
      for (int i = 0; i < snapshot.docs.length; i++) {
        items.add(LeaderboardItem.fromFirestore(snapshot.docs[i], i + 1));
      }
      return items;
    });
  }
}
