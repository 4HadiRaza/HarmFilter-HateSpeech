// File: lib/data/mock_data.dart

class Post {
  final String id;
  final String username;
  final String avatar;
  final String text;
  final String label;
  final double fusedScore;
  final String timestamp;
  final double textScore;
  final double? imageScore;
  final String explanation;
  final List<String> problematicSpans;
  final List<String> suggestions;
  final String language;
  final String? image;

  const Post({
    required this.id,
    required this.username,
    required this.avatar,
    required this.text,
    required this.label,
    required this.fusedScore,
    required this.timestamp,
    this.textScore = 0.0,
    this.imageScore,
    this.explanation = "",
    this.problematicSpans = const [],
    this.suggestions = const [],
    this.language = "en",
    this.image,
  });
}

class LessonContent {
  final String type; // 'text' or 'quiz'
  final String? text;
  final String? question;
  final List<String>? options;
  final int? correctAnswer;

  const LessonContent({
    required this.type,
    this.text,
    this.question,
    this.options,
    this.correctAnswer,
  });
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String duration;
  final int points;
  final List<LessonContent> content;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.points,
    required this.content,
  });
}

const List<Post> mockPosts = [
  Post(
    id: "1",
    username: "ahmed_khan",
    avatar: "",
    text: "I really hate how those people always ruin everything for us.",
    label: "hateful",
    fusedScore: 0.89,
    timestamp: "2024-03-10T10:30:00Z",
    textScore: 0.92,
    explanation:
        "The text contains generalized hate speech targeting a group of people.",
    problematicSpans: ["hate how those people", "ruin everything"],
    suggestions: ["I am frustrated by the actions of some individuals."],
  ),
  Post(
    id: "2",
    username: "fatima_ali",
    avatar: "",
    text: "Just had a great day at the park! The weather was perfect.",
    label: "normal",
    fusedScore: 0.02,
    timestamp: "2024-03-10T09:15:00Z",
    textScore: 0.01,
    explanation: "The content is positive and contains no harmful elements.",
  ),
  Post(
    id: "3",
    username: "usman_malik",
    avatar: "",
    text: "You're so stupid, I can't believe you actually think that.",
    label: "hateful",
    fusedScore: 0.92,
    timestamp: "2024-03-09T18:45:00Z",
    textScore: 0.95,
    explanation: "Personal attack and insult directed at another user.",
    problematicSpans: ["You're so stupid"],
    suggestions: ["I disagree with your perspective."],
  ),
  Post(
    id: "4",
    username: "ayesha_ahmed",
    avatar: "",
    text:
        "I disagree with your opinion, but I understand where you're coming from.",
    label: "normal",
    fusedScore: 0.15,
    timestamp: "2024-03-09T14:20:00Z",
    textScore: 0.12,
    explanation: "Respectful disagreement without insults.",
  ),
  Post(
    id: "5",
    username: "bilal_hassan",
    avatar: "",
    text: "Why don't you just go away? Nobody wants you here.",
    label: "offensive",
    fusedScore: 0.65,
    timestamp: "2024-03-08T20:10:00Z",
    textScore: 0.68,
    explanation: "Exclusionary language that borders on harassment.",
    problematicSpans: ["Nobody wants you here"],
    suggestions: ["I think it would be best if we stopped this conversation."],
  ),
];

const List<Lesson> mockLessons = [
  Lesson(
    id: "1",
    title: "Understanding Empathy",
    description: "Learn the basics of digital empathy and why it matters.",
    duration: "5 min",
    points: 50,
    content: [
      LessonContent(
        type: "text",
        text:
            "Empathy is the ability to understand and share the feelings of another. In the digital world, it's easy to forget there's a real person behind the screen.",
      ),
      LessonContent(
        type: "quiz",
        question: "What is the best way to respond to a hateful comment?",
        options: [
          "Respond with more hate",
          "Ignore or report it",
          "Make fun of the person",
        ],
        correctAnswer: 1,
      ),
    ],
  ),
  Lesson(
    id: "2",
    title: "Identifying Hate Speech",
    description: "How to spot subtle forms of hate speech and discrimination.",
    duration: "8 min",
    points: 80,
    content: [
      LessonContent(
        type: "text",
        text:
            "Hate speech isn't always obvious slurs. It can be coded language, stereotypes, or dehumanizing comparisons.",
      ),
      LessonContent(
        type: "quiz",
        question: "Which of these is considered a microaggression?",
        options: [
          "You speak English very well for a...",
          "I like your shoes",
          "Can you pass the salt?",
        ],
        correctAnswer: 0,
      ),
    ],
  ),
  Lesson(
    id: "3",
    title: "Constructive Criticism",
    description: "Learn how to disagree without being disagreeable.",
    duration: "6 min",
    points: 60,
    content: [
      LessonContent(
        type: "text",
        text:
            "It's okay to disagree. The key is to attack the idea, not the person. Use 'I' statements instead of 'You' statements.",
      ),
    ],
  ),
];
