import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String avatarUrl;
  final String? bio;
  final int points;
  final DateTime joinedAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl = '',
    this.bio,
    this.points = 0,
    required this.joinedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] ?? 'User',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bio: data['bio']?.toString(),
      points: (data['points'] ?? 0).toInt(),
      joinedAt: data['joinedAt'] != null
          ? (data['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio ?? '',
      'points': points,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}
