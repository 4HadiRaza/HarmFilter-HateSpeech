import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/data/quiz_data.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  int _userPoints = 0;
  bool _isLoading = true;
  final Set<String> _completedQuizzes = {};
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    try {
      final profile = await _firestoreService.getCurrentUserProfile();
      final progress = await _firestoreService.getCurrentUserQuizProgress();

      final completed = progress.entries
          .where(
            (entry) => (entry.value as Map<String, dynamic>)['passed'] == true,
          )
          .map((entry) => entry.key)
          .toSet();

      if (mounted) {
        setState(() {
          _userPoints = profile?.points ?? 0;
          _username = profile?.displayName ?? 'User';
          _completedQuizzes
            ..clear()
            ..addAll(completed);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startQuiz(Quiz quiz) async {
    await context.push('/learn/quiz/${quiz.id}', extra: _handleQuizComplete);
    await _loadProgress();
  }

  Future<void> _handleQuizComplete(
    String quizId,
    int score,
    int totalPoints,
  ) async {
    final quiz = allQuizzes.firstWhere((q) => q.id == quizId);
    await _firestoreService.saveQuizResult(
      quizId: quizId,
      score: score,
      totalPoints: totalPoints,
      awardPoints: quiz.points,
    );
  }

  List<Quiz> get _englishQuizzes =>
      allQuizzes.where((q) => q.language == 'English').toList();

  List<Quiz> get _romanUrduQuizzes =>
      allQuizzes.where((q) => q.language == 'Roman Urdu').toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: HFTheme.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
        titleSpacing: 16,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/leaderboard'),
              child: Icon(
                LucideIcons.trophy,
                color: HFTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'LEARN',
              style: GoogleFonts.inter(
                color: HFTheme.primaryTextColor(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        actions: [
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
      ),
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRAINING MODULE',
                      style: GoogleFonts.inter(
                        color: HFTheme.accent,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Learn & Grow',
                      style: GoogleFonts.inter(
                        color: HFTheme.primaryTextColor(context),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Master hate speech detection and digital safety protocols.',
                      style: GoogleFonts.inter(
                        color: HFTheme.secondaryTextColor(context),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStatsRow(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                backgroundColor: theme.scaffoldBackgroundColor,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161616)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: HFTheme.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: HFTheme.secondaryTextColor(context),
                    labelStyle: GoogleFonts.inter(fontSize: 11),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'ENGLISH'),
                      Tab(text: 'ROMAN URDU'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildQuizList(_englishQuizzes),
              _buildQuizList(_romanUrduQuizzes),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            value: '$_userPoints',
            label: 'PTS',
            valueColor: HFTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            value: '${_completedQuizzes.length} / ${allQuizzes.length}',
            label: 'QUIZZES',
            valueColor: HFTheme.primaryTextColor(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatTile(
            value: '${allQuizzes.fold(0, (sum, q) => sum + q.points)}',
            label: 'MAX',
            valueColor: HFTheme.primaryTextColor(context).withOpacity(
              HFTheme.isDark(context) ? 0.4 : 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: valueColor,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: HFTheme.secondaryTextColor(context),
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(List<Quiz> quizzes) {
    final theme = Theme.of(context);
    final isDark = HFTheme.isDark(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final isCompleted = _completedQuizzes.contains(quiz.id);

        if (isCompleted) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(color: Colors.green.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Opacity(
                opacity: 0.95,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: HFTheme.elevatedColor(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              quiz.icon,
                              color: HFTheme.secondaryTextColor(context),
                              size: 20,
                            ),
                          ),
                          const Icon(
                            LucideIcons.checkCircle2,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quiz.title,
                        style: GoogleFonts.inter(
                          color: HFTheme.primaryTextColor(context),
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.description,
                        style: GoogleFonts.inter(
                          color: HFTheme.secondaryTextColor(context),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'COMPLETED - ${quiz.points}/${quiz.points}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _startQuiz(quiz),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'REPLAY',
                                style: GoogleFonts.inter(
                                  color: HFTheme.primaryTextColor(context),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
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
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: quiz.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(quiz.icon, color: quiz.color, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF090909)
                              : const Color(0xFFF3F4F6),
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${quiz.points} PTS',
                          style: GoogleFonts.inter(
                            color: quiz.color,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quiz.title,
                    style: GoogleFonts.inter(
                      color: HFTheme.primaryTextColor(context),
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: GoogleFonts.inter(
                      color: HFTheme.secondaryTextColor(context),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A1D0D)
                          : const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Score 80% or above to earn points',
                            style: GoogleFonts.inter(
                              color: Colors.orange,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startQuiz(quiz),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: quiz.color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'START QUIZ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
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
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  _TabBarDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
