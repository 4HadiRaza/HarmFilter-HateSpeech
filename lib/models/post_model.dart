import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String avatar;
  final String text;
  final String label; // "normal", "offensive", "hateful"
  final double fusedScore;
  final double textScore;
  final double? imageScore;
  final String explanation;
  final List<String> problematicSpans;
  final List<String> suggestions;
  final String language;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.text,
    required this.label,
    required this.fusedScore,
    required this.createdAt,
    this.textScore = 0.0,
    this.imageScore,
    this.explanation = '',
    this.problematicSpans = const [],
    this.suggestions = const [],
    this.language = 'en',
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      avatar: data['avatar'] ?? '',
      text: data['text'] ?? '',
      label: data['label'] ?? 'normal',
      fusedScore: (data['fusedScore'] ?? 0.0).toDouble(),
      textScore: (data['textScore'] ?? 0.0).toDouble(),
      imageScore: data['imageScore'] != null
          ? (data['imageScore'] as num).toDouble()
          : null,
      explanation: data['explanation'] ?? '',
      problematicSpans: List<String>.from(data['problematicSpans'] ?? []),
      suggestions: List<String>.from(data['suggestions'] ?? []),
      language: data['language'] ?? 'en',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'text': text,
      'label': label,
      'fusedScore': fusedScore,
      'textScore': textScore,
      'imageScore': imageScore,
      'explanation': explanation,
      'problematicSpans': problematicSpans,
      'suggestions': suggestions,
      'language': language,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
