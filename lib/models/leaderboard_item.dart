import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardItem {
  final String uid;
  final String displayName;
  final String avatarUrl;
  final int points;
  final int rank;
  final DateTime lastActivityDate;

  const LeaderboardItem({
    required this.uid,
    required this.displayName,
    required this.avatarUrl,
    required this.points,
    required this.rank,
    required this.lastActivityDate,
  });

  factory LeaderboardItem.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardItem(
      uid: doc.id,
      displayName: data['displayName'] ?? 'User',
      avatarUrl: data['avatarUrl'] ?? '',
      points: (data['points'] ?? 0).toInt(),
      rank: rank,
      lastActivityDate: data['lastActivityDate'] != null
          ? (data['lastActivityDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'points': points,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
    };
  }
}
