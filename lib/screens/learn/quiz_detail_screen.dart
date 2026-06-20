import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:harmfilter_flutter/data/quiz_data.dart';
import 'package:harmfilter_flutter/models/quiz_question_model.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;
  final Future<void> Function(String, int, int)? onQuizComplete;

  const QuizDetailScreen({
    super.key,
    required this.quizId,
    this.onQuizComplete,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  late Quiz _quiz;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  bool _isQuizFinished = false;

  final Map<int, dynamic> _userAnswers = {};
  int? _selectedIndex;
  Map<int, int>? _matchingAnswers;
  List<int>? _multiSelectAnswers;
  String? _fillBlankAnswer;

  String _username = 'User';
  int _userTotalPoints = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _quiz = allQuizzes.firstWhere(
      (q) => q.id == widget.quizId,
      orElse: () => allQuizzes.first,
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _firestoreService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _username = profile?.displayName ?? 'User';
        _userTotalPoints = profile?.points ?? 0;
      });
    }
  }

  Question get _currentQuestion => _quiz.questions[_currentQuestionIndex];
  bool get _canGoNext => _currentQuestionIndex < _quiz.questions.length - 1;
  bool get _canGoPrevious => _currentQuestionIndex > 0;

  bool get _hasSelectedAnswer {
    if (_currentQuestion is MCQQuestion) return _selectedIndex != null;
    if (_currentQuestion is TrueFalseQuestion) return _selectedIndex != null;
    if (_currentQuestion is FillBlankQuestion)
      return _fillBlankAnswer != null && _fillBlankAnswer!.trim().isNotEmpty;
    if (_currentQuestion is MatchingQuestion)
      return _matchingAnswers != null &&
          _matchingAnswers!.length ==
              (_currentQuestion as MatchingQuestion).leftItems.length;
    if (_currentQuestion is MultiSelectQuestion)
      return _multiSelectAnswers != null && _multiSelectAnswers!.isNotEmpty;
    return false;
  }

  void _submitAnswer() {
    if (_isAnswered) return;

    bool isCorrect = false;

    if (_currentQuestion is MCQQuestion) {
      final q = _currentQuestion as MCQQuestion;
      isCorrect = _selectedIndex == q.correctAnswerIndex;
      _userAnswers[_currentQuestionIndex] = _selectedIndex;
    } else if (_currentQuestion is TrueFalseQuestion) {
      final q = _currentQuestion as TrueFalseQuestion;
      final selectedBool = _selectedIndex == 1;
      isCorrect = selectedBool == q.correctAnswer;
      _userAnswers[_currentQuestionIndex] = _selectedIndex;
    } else if (_currentQuestion is FillBlankQuestion) {
      final q = _currentQuestion as FillBlankQuestion;
      isCorrect = q.isAnswerCorrect(_fillBlankAnswer ?? '');
      _userAnswers[_currentQuestionIndex] = _fillBlankAnswer;
    } else if (_currentQuestion is MatchingQuestion) {
      final q = _currentQuestion as MatchingQuestion;
      isCorrect = q.areAnswersCorrect(_matchingAnswers ?? {});
      _userAnswers[_currentQuestionIndex] = _matchingAnswers;
    } else if (_currentQuestion is MultiSelectQuestion) {
      final q = _currentQuestion as MultiSelectQuestion;
      isCorrect = q.areAnswersCorrect(_multiSelectAnswers ?? []);
      _userAnswers[_currentQuestionIndex] = _multiSelectAnswers;
    }

    if (isCorrect) {
      _score += _currentQuestion.points;
    }

    setState(() => _isAnswered = true);
  }

  void _restoreAnswerState(int index) {
    _isAnswered = _userAnswers.containsKey(index);
    _selectedIndex = null;
    _matchingAnswers = null;
    _multiSelectAnswers = null;
    _fillBlankAnswer = null;

    if (_isAnswered) {
      final answer = _userAnswers[index];
      final question = _quiz.questions[index];

      if (question is MCQQuestion ||
          question is TrueFalseQuestion ||
          question is ScenarioQuestion) {
        _selectedIndex = answer as int?;
      } else if (question is FillBlankQuestion) {
        _fillBlankAnswer = answer as String?;
      } else if (question is MatchingQuestion) {
        _matchingAnswers = answer as Map<int, int>?;
      } else if (question is MultiSelectQuestion) {
        _multiSelectAnswers = answer as List<int>?;
      }
    }
  }

  void _nextQuestion() {
    if (_canGoNext) {
      setState(() {
        _currentQuestionIndex++;
        _restoreAnswerState(_currentQuestionIndex);
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_canGoPrevious) {
      setState(() {
        _currentQuestionIndex--;
        _restoreAnswerState(_currentQuestionIndex);
      });
    }
  }

  void _finishQuiz() {
    setState(() => _isQuizFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isQuizFinished) {
      return _buildResultsScreen(context);
    }

    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);
    final isCompact = MediaQuery.of(context).size.width < 360;
    final progressPercent =
        (_currentQuestionIndex + 1) / _quiz.questions.length;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: HFTheme.secondaryTextColor(context),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _quiz.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'POINTS',
                style: GoogleFonts.inter(
                  color: HFTheme.accent,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
                color: HFTheme.elevatedColor(context),
              ),
              clipBehavior: Clip.antiAlias,
              child: HFAvatar(name: _username, size: 32),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            width: double.infinity,
            height: 4,
            color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB),
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width * progressPercent,
              height: 4,
              decoration: BoxDecoration(
                color: _quiz.color,
                boxShadow: [
                  BoxShadow(
                    color: _quiz.color.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT MODULE',
                              style: GoogleFonts.inter(
                                color: _quiz.color,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _quiz.title.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: HFTheme.primaryTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Question ${_currentQuestionIndex + 1} of ${_quiz.questions.length}'
                              .toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            color: HFTheme.secondaryTextColor(context),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildQuestionContent(_currentQuestion),
                ],
              ),
            ),

            // Explanation Bottom Sheet (slides up)
            if (_isAnswered)
              Positioned(
                left: 16,
                right: 16,
                bottom: 88,
                child: _buildExplanationPanel(),
              ),

            // Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  children: [
                    if (_canGoPrevious)
                      TextButton(
                        onPressed: _previousQuestion,
                        child: Text(
                          'PREVIOUS',
                          style: GoogleFonts.inter(
                            color: HFTheme.secondaryTextColor(context),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _isAnswered
                              ? ElevatedButton(
                                  onPressed: _nextQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.cardColor,
                                    foregroundColor: HFTheme.primaryTextColor(context),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _canGoNext ? 'NEXT_STEP' : 'FINISH',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _canGoNext
                                            ? Icons.arrow_forward
                                            : Icons.check,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _hasSelectedAnswer
                                      ? _submitAnswer
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _hasSelectedAnswer
                                        ? _quiz.color
                                        : theme.dividerColor,
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: const Color(
                                      0xFF8A8A8A,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    elevation: _hasSelectedAnswer ? 4 : 0,
                                    shadowColor: _quiz.color.withOpacity(0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'SUBMIT_ANSWER',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.bolt, size: 16),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationPanel() {
    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);
    bool isCorrect = false;
    if (_currentQuestion is TrueFalseQuestion) {
      isCorrect =
          _selectedIndex ==
          ((_currentQuestion as TrueFalseQuestion).correctAnswer ? 1 : 0);
    } else if (_currentQuestion is MCQQuestion) {
      isCorrect =
          _selectedIndex ==
          (_currentQuestion as MCQQuestion).correctAnswerIndex;
    } else if (_currentQuestion is FillBlankQuestion) {
      isCorrect = (_currentQuestion as FillBlankQuestion).isAnswerCorrect(
        _fillBlankAnswer ?? '',
      );
    } else if (_currentQuestion is MatchingQuestion) {
      isCorrect = (_currentQuestion as MatchingQuestion).areAnswersCorrect(
        _matchingAnswers ?? {},
      );
    } else if (_currentQuestion is MultiSelectQuestion) {
      isCorrect = (_currentQuestion as MultiSelectQuestion).areAnswersCorrect(
        _multiSelectAnswers ?? [],
      );
    }

    final color = isCorrect ? Colors.green : HFTheme.accent;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: isDark
            ? const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                'ANALYSIS COMPLETE',
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: GoogleFonts.inter(
              color: HFTheme.secondaryTextColor(context),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (_currentQuestion is ScenarioQuestion) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HFTheme.elevatedColor(context),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REASONING',
                    style: GoogleFonts.inter(
                      color: _quiz.color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (_currentQuestion as ScenarioQuestion).reasoning,
                    style: GoogleFonts.inter(
                      color: HFTheme.primaryTextColor(context),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionContent(Question question) {
    final isDark = HFTheme.isDark(context);
    if (question is ScenarioQuestion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HFTheme.elevatedColor(context),
              border: Border(left: BorderSide(color: _quiz.color, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal, color: _quiz.color, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'SCENARIO_INPUT',
                      style: GoogleFonts.inter(
                        color: HFTheme.secondaryTextColor(context),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"${question.scenario}"',
                  style: GoogleFonts.inter(
                    color: HFTheme.primaryTextColor(context),
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _quiz.color.withOpacity(0.1),
                  border: Border.all(color: _quiz.color.withOpacity(0.3)),
                ),
                child: Text(
                  'MCQ_TYPE',
                  style: GoogleFonts.inter(
                    color: _quiz.color,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: GoogleFonts.inter(
              color: HFTheme.primaryTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ..._buildOptionsForMCQ(question),
        ],
      );
    } else if (question is MCQQuestion) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _quiz.color.withOpacity(0.1),
                  border: Border.all(color: _quiz.color.withOpacity(0.3)),
                ),
                child: Text(
                  'MCQ_TYPE',
                  style: GoogleFonts.inter(
                    color: _quiz.color,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: GoogleFonts.inter(
              color: HFTheme.primaryTextColor(context),
              fontSize: 22,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ..._buildOptionsForMCQ(question),
        ],
      );
    } else if (question is TrueFalseQuestion) {
      return _buildTrueFalseQuestion(question);
    } else if (question is FillBlankQuestion) {
      return _buildFillBlankQuestion(question);
    } else if (question is MatchingQuestion) {
      return _buildMatchingQuestion(question);
    } else if (question is MultiSelectQuestion) {
      return _buildMultiSelectQuestion(question);
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildOptionsForMCQ(MCQQuestion question) {
    final isDark = HFTheme.isDark(context);
    return List.generate(question.options.length, (index) {
      final isSelected = _selectedIndex == index;
      final isCorrect = index == question.correctAnswerIndex;
      final showFeedback = _isAnswered;

      Color borderColor = Theme.of(context).dividerColor;
      Color bgColor = Theme.of(context).cardColor;
      Color letterColor = HFTheme.secondaryTextColor(context);
      Color textcolor = HFTheme.primaryTextColor(context);
      Widget? trailingIcon;
      List<BoxShadow>? boxShadow;

      if (showFeedback) {
        if (isCorrect) {
          borderColor = Colors.green.withOpacity(0.5);
          bgColor = HFTheme.elevatedColor(context);
          letterColor = Colors.green;
          textcolor = HFTheme.primaryTextColor(context);
          trailingIcon = const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          );
          } else if (isSelected && !isCorrect) {
          borderColor = HFTheme.accent.withOpacity(0.5);
          bgColor = HFTheme.elevatedColor(context);
          letterColor = HFTheme.accent;
          textcolor = HFTheme.primaryTextColor(context);
          trailingIcon = Icon(Icons.cancel, color: HFTheme.accent, size: 20);
        } else {
          bgColor = Theme.of(context).cardColor;
          borderColor = Theme.of(context).dividerColor;
          letterColor = HFTheme.secondaryTextColor(context);
          textcolor = HFTheme.secondaryTextColor(context);
        }
      } else if (isSelected) {
        borderColor = _quiz.color;
        bgColor = HFTheme.elevatedColor(context);
        letterColor = _quiz.color;
        textcolor = HFTheme.primaryTextColor(context);
        boxShadow = [
          BoxShadow(color: _quiz.color.withOpacity(0.4), blurRadius: 15),
        ];
      }

      final letters = ['A', 'B', 'C', 'D', 'E', 'F'];

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: _isAnswered
              ? null
              : () => setState(() => _selectedIndex = index),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              boxShadow: boxShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    letters[index],
                    style: GoogleFonts.inter(
                      color: letterColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question.options[index],
                    style: GoogleFonts.inter(color: textcolor, fontSize: 14),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 12),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTrueFalseQuestion(TrueFalseQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _quiz.color.withOpacity(0.1),
                border: Border.all(color: _quiz.color.withOpacity(0.3)),
              ),
              child: Text(
                'BOOLEAN_TYPE',
                style: GoogleFonts.inter(
                  color: _quiz.color,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.questionText,
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontSize: 22,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildTFButton(true, Icons.check_circle_outline, 'TRUE'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTFButton(false, Icons.cancel_outlined, 'FALSE'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTFButton(bool isTrue, IconData icon, String label) {
    final value = isTrue ? 1 : 0;
    final isSelected = _selectedIndex == value;
    final showFeedback = _isAnswered;
    final isCorrect =
        value ==
        ((_currentQuestion as TrueFalseQuestion).correctAnswer ? 1 : 0);

    Color borderColor = Theme.of(context).dividerColor;
    Color bgColor = Theme.of(context).cardColor;
    Color contentColor = HFTheme.secondaryTextColor(context);

    if (showFeedback) {
      if (isCorrect) {
        borderColor = Colors.green.withOpacity(0.5);
        bgColor = HFTheme.elevatedColor(context);
        contentColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        borderColor = HFTheme.accent.withOpacity(0.5);
        bgColor = HFTheme.elevatedColor(context);
        contentColor = HFTheme.accent;
      }
    } else if (isSelected) {
      borderColor = _quiz.color;
      bgColor = HFTheme.elevatedColor(context);
      contentColor = _quiz.color;
    }

    return GestureDetector(
      onTap: _isAnswered ? null : () => setState(() => _selectedIndex = value),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          boxShadow: isSelected && !showFeedback
              ? [BoxShadow(color: _quiz.color.withOpacity(0.4), blurRadius: 15)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: contentColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                color: contentColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillBlankQuestion(FillBlankQuestion question) {
    final parts = question.template.split('[blank]');
    final textBefore = parts.isNotEmpty ? parts[0] : '';
    final textAfter = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _quiz.color.withOpacity(0.1),
                border: Border.all(color: _quiz.color.withOpacity(0.3)),
              ),
              child: Text(
                'INPUT_TYPE',
                style: GoogleFonts.inter(
                  color: _quiz.color,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: HFTheme.primaryTextColor(context),
                fontSize: 18,
                height: 1.6,
              ),
              children: [
                TextSpan(text: textBefore),
                WidgetSpan(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: HFTheme.accent, width: 2),
                      ),
                    ),
                    child: Text(
                      _fillBlankAnswer?.isEmpty ?? true
                          ? '       '
                          : _fillBlankAnswer!,
                      style: GoogleFonts.inter(
                        color: HFTheme.accent,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                TextSpan(text: textAfter),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          enabled: !_isAnswered,
          onChanged: (val) => setState(() => _fillBlankAnswer = val),
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            hintStyle: GoogleFonts.inter(
              color: HFTheme.secondaryTextColor(context),
            ),
            filled: true,
            fillColor: HFTheme.inputFillColor(context),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _quiz.color),
              borderRadius: BorderRadius.zero,
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.zero,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'INPUT',
                style: GoogleFonts.inter(
                  color: HFTheme.secondaryTextColor(context),
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        if (question.hints != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.orange, width: 4)),
              color: HFTheme.elevatedColor(context),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encrypted Hint',
                        style: GoogleFonts.inter(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.hints!,
                        style: GoogleFonts.inter(
                          color: HFTheme.secondaryTextColor(context),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMatchingQuestion(MatchingQuestion question) {
    _matchingAnswers ??= {};
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(left: BorderSide(color: _quiz.color, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MISSION OBJECTIVE',
                style: GoogleFonts.inter(
                  color: _quiz.color,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.questionText,
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TERMS',
                    style: GoogleFonts.inter(
                      color: HFTheme.secondaryTextColor(context),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(question.leftItems.length, (leftIndex) {
                    final isMatched = _matchingAnswers!.containsKey(leftIndex);
                    final isCorrect =
                        _isAnswered &&
                        _matchingAnswers![leftIndex] ==
                            question.correctPairs[leftIndex];
                    final isWrong = _isAnswered && !isCorrect && isMatched;

                    Color borderColor = theme.dividerColor;
                    Color bgColor = HFTheme.elevatedColor(context);
                    if (isCorrect) {
                      borderColor = Colors.green;
                      bgColor = Colors.green.withOpacity(0.1);
                    } else if (isWrong) {
                      borderColor = HFTheme.accent;
                      bgColor = HFTheme.accent.withOpacity(0.1);
                    } else if (isMatched) {
                      borderColor = _quiz.color;
                      bgColor = _quiz.color.withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _isAnswered
                            ? null
                            : () => _showMatchingOptions(
                                context,
                                question,
                                leftIndex,
                              ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            border: Border(
                              left: BorderSide(
                                color: (isMatched || isCorrect || isWrong)
                                    ? borderColor
                                    : theme.dividerColor,
                                width: (isMatched || isCorrect || isWrong)
                                    ? 3
                                    : 1,
                              ),
                              top: BorderSide(color: theme.dividerColor),
                              right: BorderSide(color: theme.dividerColor),
                              bottom: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                          child: Text(
                            question.leftItems[leftIndex],
                            style: GoogleFonts.inter(
                              color: HFTheme.primaryTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEFINITIONS',
                    style: GoogleFonts.inter(
                      color: HFTheme.secondaryTextColor(context),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(question.rightItems.length, (rightIndex) {
                    final matchedLeftIndex = _matchingAnswers!.entries
                        .where((e) => e.value == rightIndex)
                        .map((e) => e.key)
                        .firstOrNull;
                    final isMatched = matchedLeftIndex != null;

                    Color borderColor = theme.dividerColor;
                    Color bgColor = HFTheme.elevatedColor(context);

                    if (_isAnswered && isMatched) {
                      final isCorrect =
                          question.correctPairs[matchedLeftIndex] == rightIndex;
                      if (isCorrect) {
                        borderColor = Colors.green;
                        bgColor = Colors.green.withOpacity(0.1);
                      } else {
                        borderColor = HFTheme.accent;
                        bgColor = HFTheme.accent.withOpacity(0.1);
                      }
                    } else if (isMatched) {
                      borderColor = _quiz.color;
                      bgColor = _quiz.color.withOpacity(0.1);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border(
                            left: BorderSide(
                              color: isMatched
                                  ? borderColor
                                  : theme.dividerColor,
                              width: isMatched ? 3 : 1,
                            ),
                            top: BorderSide(color: theme.dividerColor),
                            right: BorderSide(color: theme.dividerColor),
                            bottom: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                        child: Text(
                          question.rightItems[rightIndex],
                          style: GoogleFonts.inter(
                            color: HFTheme.primaryTextColor(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMatchingOptions(
    BuildContext context,
    MatchingQuestion question,
    int leftIndex,
  ) {
    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Match For:',
                  style: GoogleFonts.inter(
                    color: HFTheme.secondaryTextColor(context),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.leftItems[leftIndex],
                  style: GoogleFonts.inter(
                    color: HFTheme.primaryTextColor(context),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.rightItems.length, (rightIndex) {
                  final isAlreadyMatched = _matchingAnswers!.values.contains(
                    rightIndex,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: isAlreadyMatched
                          ? null
                          : () {
                              setState(() {
                                _matchingAnswers![leftIndex] = rightIndex;
                              });
                              Navigator.pop(context);
                            },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isAlreadyMatched
                              ? HFTheme.inputFillColor(context).withOpacity(0.5)
                              : (isDark
                                  ? const Color(0xFF090909)
                                  : const Color(0xFFF3F4F6)),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.rightItems[rightIndex],
                                style: GoogleFonts.inter(
                                  color: isAlreadyMatched
                                      ? HFTheme.secondaryTextColor(context)
                                          .withOpacity(0.5)
                                      : HFTheme.primaryTextColor(context),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isAlreadyMatched)
                              Icon(
                                Icons.check,
                                color: theme.dividerColor,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiSelectQuestion(MultiSelectQuestion question) {
    _multiSelectAnswers ??= [];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(left: BorderSide(color: _quiz.color, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MULTI_SELECT',
                style: GoogleFonts.inter(
                  color: _quiz.color,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.questionText,
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          final isSelected = _multiSelectAnswers!.contains(index);
          final isCorrectOption = question.correctAnswerIndices.contains(index);
          final showFeedback = _isAnswered;

          Color borderColor = theme.dividerColor;
          Color bgColor = theme.cardColor;
          Widget? trailingIcon;

          if (showFeedback) {
            if (isSelected && isCorrectOption) {
              borderColor = Colors.green;
              trailingIcon = const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              );
            } else if (isSelected && !isCorrectOption) {
              borderColor = HFTheme.accent;
              trailingIcon = Icon(
                Icons.cancel,
                color: HFTheme.accent,
                size: 20,
              );
            } else if (!isSelected && isCorrectOption) {
              borderColor = Colors.orange; // Missed
              trailingIcon = const Icon(
                Icons.warning,
                color: Colors.orange,
                size: 20,
              );
            }
          } else if (isSelected) {
            borderColor = _quiz.color;
            bgColor = HFTheme.elevatedColor(context);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: _isAnswered
                  ? null
                  : () {
                      setState(() {
                        if (isSelected) {
                          _multiSelectAnswers!.remove(index);
                        } else {
                          _multiSelectAnswers!.add(index);
                        }
                      });
                    },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? _quiz.color : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? _quiz.color
                              : HFTheme.secondaryTextColor(context),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        question.options[index],
                        style: GoogleFonts.inter(
                          color: HFTheme.primaryTextColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) trailingIcon,
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultsScreen(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);
    final totalPoints = _quiz.questions.fold<int>(
      0,
      (sum, q) => sum + q.points,
    );
    final percentage = (_score / totalPoints * 100).round();
    final passed = percentage >= 80;

    if (passed) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.menu, color: HFTheme.accent, size: 24),
              const SizedBox(width: 16),
              Text(
                'HarmFilter',
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'LEARN',
                  style: GoogleFonts.inter(
                    color: HFTheme.accent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: HFAvatar(name: _username, size: 32),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Assessment Complete',
                    style: GoogleFonts.inter(
                      color: HFTheme.secondaryTextColor(context),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      percentage == 100 ? 'Perfect Score!' : 'Great Job!',
                      style: GoogleFonts.inter(
                        color: HFTheme.primaryTextColor(context),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$_score / $totalPoints',
                      style: GoogleFonts.inter(
                        color: Colors.green,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: HFTheme.elevatedColor(context),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage / 100,
                      child: Container(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        left: BorderSide(color: Colors.green, width: 4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.green),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'You earned +${_quiz.points} points!',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: HFTheme.primaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _retryQuiz,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: HFTheme.accent,
                            side: BorderSide(color: HFTheme.accent),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            'RETRY',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _exitQuiz(totalPoints),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HFTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 10,
                            shadowColor: HFTheme.accent.withOpacity(0.5),
                          ),
                          child: Text(
                            'BACK TO LEARN',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Fail screen
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.cardColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.menu, color: HFTheme.accent, size: 24),
              const SizedBox(width: 16),
              Text(
                'HarmFilter',
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'LEARN',
                  style: GoogleFonts.inter(
                    color: HFTheme.accent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: HFAvatar(name: _username, size: 32),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HFTheme.accent.withOpacity(0.1),
                        border: Border.all(
                          color: HFTheme.accent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: HFTheme.accent.withOpacity(0.2),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.refresh,
                          color: HFTheme.accent,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Keep Practicing!',
                        style: GoogleFonts.inter(
                          color: HFTheme.primaryTextColor(context),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$_score / $totalPoints',
                        style: GoogleFonts.inter(
                          color: HFTheme.primaryTextColor(context),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 8,
                      width: double.infinity,
                      color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE5E7EB),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(color: HFTheme.accent),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border(
                          left: BorderSide(color: HFTheme.accent, width: 4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error, color: HFTheme.accent),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "You didn't pass this time. Score 80% or above to earn points.",
                              style: GoogleFonts.inter(
                                color: HFTheme.secondaryTextColor(context),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _retryQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HFTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          'TRY AGAIN',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _exitQuiz(totalPoints),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: HFTheme.primaryTextColor(context),
                          side: BorderSide(color: theme.dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          'BACK TO LEARN',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  void _retryQuiz() {
    setState(() {
      _score = 0;
      _currentQuestionIndex = 0;
      _isAnswered = false;
      _selectedIndex = null;
      _matchingAnswers = null;
      _multiSelectAnswers = null;
      _fillBlankAnswer = null;
      _userAnswers.clear();
      _isQuizFinished = false;
    });
  }

  void _exitQuiz(int totalPoints) {
    widget.onQuizComplete?.call(widget.quizId, _score, totalPoints);
    context.pop();
  }
}
