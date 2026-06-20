/// Enum for different question types supported in quizzes
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillBlank,
  matching,
  multipleSelect,
  scenario,
}

/// Abstract base class for all question types
abstract class Question {
  final String id;
  final String questionText;
  final String explanation;
  final QuestionType type;
  final int points;

  Question({
    required this.id,
    required this.questionText,
    required this.explanation,
    required this.type,
    this.points = 10,
  });
}

/// Multiple Choice Question - single correct answer from options
class MCQQuestion extends Question {
  final List<String> options;
  final int correctAnswerIndex;

  MCQQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.options,
    required this.correctAnswerIndex,
    int points = 10,
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    type: QuestionType.multipleChoice,
    points: points,
  );
}

/// True/False Question - boolean correct answer
class TrueFalseQuestion extends Question {
  final bool correctAnswer;

  TrueFalseQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.correctAnswer,
    int points = 10,
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    type: QuestionType.trueFalse,
    points: points,
  );
}

/// Fill-in-the-Blank Question - text input with multiple correct variations
class FillBlankQuestion extends Question {
  /// Template with [blank] placeholders
  final String template;

  /// List of acceptable answers (supports variations)
  /// Example: ['hate', 'hatred', 'hateful'] all accepted
  final List<String> correctAnswers;

  /// Optional hint text for user
  final String? hints;

  FillBlankQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.template,
    required this.correctAnswers,
    this.hints,
    int points = 10,
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    type: QuestionType.fillBlank,
    points: points,
  );

  /// Check if answer is correct (case-insensitive, checks all variations)
  bool isAnswerCorrect(String userAnswer) {
    final normalized = userAnswer.toLowerCase().trim();
    return correctAnswers.any(
      (answer) => answer.toLowerCase().trim() == normalized,
    );
  }
}

/// Matching Question - match left items to right items via drag-drop
class MatchingQuestion extends Question {
  /// Left column items (phrases, concepts, etc.)
  final List<String> leftItems;

  /// Right column items (categories, definitions, etc.)
  final List<String> rightItems;

  /// Correct pairs mapping: leftIndex -> rightIndex
  /// Example: {0: 2, 1: 0, 2: 1} means:
  /// - leftItems[0] matches rightItems[2]
  /// - leftItems[1] matches rightItems[0]
  /// - leftItems[2] matches rightItems[1]
  final Map<int, int> correctPairs;

  MatchingQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.leftItems,
    required this.rightItems,
    required this.correctPairs,
    int points = 10,
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    type: QuestionType.matching,
    points: points,
  );

  /// Check if all pairs are correctly matched
  bool areAnswersCorrect(Map<int, int> userAnswers) {
    if (userAnswers.length != correctPairs.length) return false;

    for (final entry in correctPairs.entries) {
      if (userAnswers[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}

/// Multiple Select Question - choose ALL correct answers
class MultiSelectQuestion extends Question {
  /// All available options
  final List<String> options;

  /// Indices of all correct answers
  final List<int> correctAnswerIndices;

  /// Minimum number of correct answers required to pass
  final int minSelectRequired;

  MultiSelectQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.options,
    required this.correctAnswerIndices,
    this.minSelectRequired = 1,
    int points = 10,
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    type: QuestionType.multipleSelect,
    points: points,
  );

  /// Check if user selected exactly the correct answers
  bool areAnswersCorrect(List<int> userSelectedIndices) {
    // Must select all correct answers and no incorrect ones
    final userSet = userSelectedIndices.toSet();
    final correctSet = correctAnswerIndices.toSet();
    return userSet.containsAll(correctSet) && correctSet.containsAll(userSet);
  }
}

/// Scenario-based Question - context followed by MCQ
/// Inherits from MCQQuestion but with additional scenario context
class ScenarioQuestion extends MCQQuestion {
  /// Larger narrative context or scenario description
  final String scenario;

  /// Explanation of why the answer is correct/best
  final String reasoning;

  ScenarioQuestion({
    required String id,
    required String questionText,
    required String explanation,
    required this.scenario,
    required this.reasoning,
    required List<String> options,
    required int correctAnswerIndex,
    int points = 15, // Scenarios are worth more
  }) : super(
    id: id,
    questionText: questionText,
    explanation: explanation,
    options: options,
    correctAnswerIndex: correctAnswerIndex,
    points: points,
  );
}
