import 'package:cloud_firestore/cloud_firestore.dart';

class DailyAnalytics {
  final String date; // Format: YYYY-MM-DD
  final int totalAnalyzed;
  final int safeCount;
  final int offensiveCount;
  final int hatefulCount;
  final int warningsIssued;

  const DailyAnalytics({
    required this.date,
    this.totalAnalyzed = 0,
    this.safeCount = 0,
    this.offensiveCount = 0,
    this.hatefulCount = 0,
    this.warningsIssued = 0,
  });

  factory DailyAnalytics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyAnalytics(
      date: doc.id,
      totalAnalyzed: (data['totalAnalyzed'] ?? 0).toInt(),
      safeCount: (data['safeCount'] ?? 0).toInt(),
      offensiveCount: (data['offensiveCount'] ?? 0).toInt(),
      hatefulCount: (data['hatefulCount'] ?? 0).toInt(),
      warningsIssued: (data['warningsIssued'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalAnalyzed': totalAnalyzed,
      'safeCount': safeCount,
      'offensiveCount': offensiveCount,
      'hatefulCount': hatefulCount,
      'warningsIssued': warningsIssued,
    };
  }

  /// Returns the total flagged count (offensive + hateful)
  int get flaggedCount => offensiveCount + hatefulCount;
}
