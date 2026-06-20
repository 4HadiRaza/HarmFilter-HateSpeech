import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/models/daily_analytics.dart';
import 'package:harmfilter_flutter/models/post_model.dart';
import 'package:harmfilter_flutter/services/dashboard_service.dart';
import 'package:harmfilter_flutter/services/theme_service.dart';
import 'package:harmfilter_flutter/widgets/hf_button.dart';
import 'package:harmfilter_flutter/widgets/hf_card.dart';
import 'package:harmfilter_flutter/widgets/hf_empty_state.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:harmfilter_flutter/widgets/report_post_sheet.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  DashboardData? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _dashboardService.getDashboardData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  String get _displayName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? 'Agent';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final theme = Theme.of(context);

        if (_isLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: HFTheme.accent),
            ),
          );
        }

        if (_error != null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: HFEmptyState(
              title: 'Failed to load dashboard',
              message: _error!,
              icon: LucideIcons.alertCircle,
              actionLabel: 'RETRY',
              onAction: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadData();
              },
            ),
          );
        }

        final data = _data!;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: HFTheme.accent,
              backgroundColor: theme.cardColor,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 28),
                    if (data.needsProfileSync) ...[
                      _buildSyncPrompt(),
                      const SizedBox(height: 28),
                    ],
                    _buildStatsGrid(data),
                    const SizedBox(height: 16),
                    _buildActivityTimeline(data.weeklyAnalytics),
                    const SizedBox(height: 28),
                    _buildContentDistribution(
                      data.safeCount,
                      data.offensiveCount,
                      data.hatefulCount,
                    ),
                    const SizedBox(height: 28),
                    _buildRecentFlaggedSection(data.recentFlaggedPosts),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreeting() {
    final screenWidth = MediaQuery.of(context).size.width;
    final greetingFontSize = screenWidth < 380 ? 20.0 : 24.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, $_displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: greetingFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.push('/settings'),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.settings_outlined,
              size: 18,
              color: isDark ? HFTheme.muted : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          HFButton(
            label: 'SCAN POST',
            icon: LucideIcons.radar,
            expand: false,
            onPressed: () => context.go('/analyze'),
          ),
          const SizedBox(width: 10),
          HFButton(
            label: 'TAKE QUIZ',
            icon: LucideIcons.helpCircle,
            styleType: HFButtonStyleType.outlined,
            expand: false,
            onPressed: () => context.go('/learn'),
          ),
          const SizedBox(width: 10),
          HFButton(
            label: 'COACH',
            icon: LucideIcons.heart,
            styleType: HFButtonStyleType.ghost,
            expand: false,
            onPressed: () => context.go('/chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncPrompt() {
    final theme = Theme.of(context);

    return HFCard(
      borderColor: HFTheme.accent.withAlpha(80),
      child: Row(
        children: [
          Icon(LucideIcons.database, color: HFTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account not synced',
                  style: GoogleFonts.inter(
                    color: _primaryTextColor(theme),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Store your credentials to track stats.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _secondaryTextColor(theme),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          HFButton(
            label: 'SYNC',
            expand: false,
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _dashboardService.syncProfile();
                await _loadData();
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _error = e.toString();
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DashboardData data) {
    final theme = Theme.of(context);

    return Column(
      children: [
        HFCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SAFETY INDEX',
                    style: GoogleFonts.inter(
                      color: _secondaryTextColor(theme),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Safe Posts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _primaryTextColor(theme),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ).copyWith(
                      height: 1.4,
                      leadingDistribution: TextLeadingDistribution.even,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data.totalPostsAnalyzed > 0
                                ? '${((data.totalSafePosts / data.totalPostsAnalyzed) * 100).toStringAsFixed(0)}%'
                                : '-',
                            style: GoogleFonts.inter(
                              color: HFTheme.accent,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            data.totalPostsAnalyzed > 0
                                ? 'SAFE RATE'
                                : 'NO DATA',
                            style: GoogleFonts.inter(
                              color: HFTheme.accent,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMiniStat(
                      'Posts Analyzed',
                      data.totalPostsAnalyzed.toString(),
                    ),
                  ),
                  _buildMiniDivider(),
                  Expanded(
                    child: _buildMiniStat(
                      'Warnings Issued',
                      data.totalWarnings.toString(),
                    ),
                  ),
                  _buildMiniDivider(),
                  Expanded(
                    child: _buildMiniStat(
                      'Your Points',
                      data.userProfile.points.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                'Total Flags',
                data.totalWarnings.toString(),
                LucideIcons.flag,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatTile(
                'Safe Posts',
                data.totalSafePosts.toString(),
                LucideIcons.shieldCheck,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: _secondaryTextColor(theme),
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: _primaryTextColor(theme),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniDivider() {
    final theme = Theme.of(context);

    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: theme.dividerColor,
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return HFCard(
      backgroundColor: isDark ? HFTheme.elevated : theme.cardColor,
      borderColor: theme.dividerColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HFTheme.accent, size: 20),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: _secondaryTextColor(theme),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _primaryTextColor(theme),
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(List<DailyAnalytics> weeklyData) {
    final theme = Theme.of(context);
    double maxY = 5;
    for (final day in weeklyData) {
      if (day.flaggedCount > maxY) {
        maxY = day.flaggedCount.toDouble();
      }
    }
    maxY = ((maxY / 5).ceil() * 5).toDouble();
    if (maxY < 5) maxY = 5;

    return HFCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVITY TIMELINE',
                style: GoogleFonts.inter(
                  color: _secondaryTextColor(theme),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: HFTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE SYNC',
                    style: GoogleFonts.inter(
                      color: _secondaryTextColor(theme),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(weeklyData.length.clamp(0, 7), (i) {
                final count = weeklyData[i].flaggedCount.toDouble();
                final fraction = maxY > 0
                    ? (count / maxY).clamp(0.05, 1.0)
                    : 0.05;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FractionallySizedBox(
                      heightFactor: fraction,
                      child: Container(
                        decoration: BoxDecoration(
                          color: HFTheme.accent.withAlpha(
                            (50 + (fraction * 200)).toInt().clamp(50, 255),
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weeklyData.length.clamp(0, 7), (i) {
              try {
                final date = DateTime.parse(weeklyData[i].date);
                return Expanded(
                  child: Text(
                    DateFormat('E').format(date),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF444444)
                          : const Color(0xFF6B7280),
                      fontSize: 9,
                    ),
                  ),
                );
              } catch (_) {
                return const Expanded(child: SizedBox());
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContentDistribution(int safe, int offensive, int hateful) {
    final theme = Theme.of(context);
    final total = safe + offensive + hateful;

    if (total == 0) {
      return HFCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              LucideIcons.pieChart,
              size: 40,
              color: _secondaryTextColor(theme),
            ),
            const SizedBox(height: 12),
            Text(
              'No posts analyzed yet',
              style: GoogleFonts.inter(
                color: _secondaryTextColor(theme),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return HFCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTENT DISTRIBUTION',
            style: GoogleFonts.inter(
              color: _secondaryTextColor(theme),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Breakdown by safety level',
            style: GoogleFonts.inter(
              color: _primaryTextColor(theme),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: safe.toDouble(),
                    color: const Color(0xFF00C853),
                    title: '${((safe / total) * 100).toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: offensive.toDouble(),
                    color: const Color(0xFFFF9100),
                    title: '${((offensive / total) * 100).toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: hateful.toDouble(),
                    color: HFTheme.accent,
                    title: '${((hateful / total) * 100).toStringAsFixed(0)}%',
                    radius: 50,
                    titleStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 3,
                centerSpaceRadius: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildLegendDot('Normal', const Color(0xFF00C853)),
              _buildLegendDot('Offensive', const Color(0xFFFF9100)),
              _buildLegendDot('Hateful', HFTheme.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: _secondaryTextColor(theme),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFlaggedSection(List<PostModel> flaggedPosts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: GoogleFonts.inter(
                color: _primaryTextColor(theme),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/analyze'),
              child: Text(
                'VIEW ALL',
                style: GoogleFonts.inter(
                  color: _secondaryTextColor(theme),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (flaggedPosts.isEmpty)
          HFCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  color: Color(0xFF00C853),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All clear',
                        style: GoogleFonts.inter(
                          color: _primaryTextColor(theme),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'No flagged posts detected.',
                        style: GoogleFonts.inter(
                          color: _secondaryTextColor(theme),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...flaggedPosts.map((post) => _buildActivityItem(post)),
      ],
    );
  }

  Widget _buildActivityItem(PostModel post) {
    final isHateful = post.label == 'hateful';
    final borderColor = isHateful ? HFTheme.accent : const Color(0xFFFF9100);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => context.push('/post-detail/${post.id}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(left: BorderSide(color: borderColor, width: 2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? HFTheme.elevated : const Color(0xFFF3F4F6),
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isHateful
                      ? LucideIcons.shieldAlert
                      : LucideIcons.alertTriangle,
                  color: borderColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _primaryTextColor(theme),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${post.username} · ${post.label.toUpperCase()}',
                      style: GoogleFonts.inter(
                        color: _secondaryTextColor(theme),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showReportPostSheet(
                  context,
                  postId: post.id,
                  postContent: post.text,
                  currentFlag: post.label,
                ),
                tooltip: 'Report post',
                icon: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFF6B7280),
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: borderColor.withAlpha(26),
                  border: Border.all(color: borderColor.withAlpha(51)),
                ),
                child: Text(
                  isHateful ? 'CRITICAL' : 'WARNING',
                  style: GoogleFonts.inter(
                    color: borderColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _primaryTextColor(ThemeData theme) {
    return theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark
            ? HFTheme.text
            : const Color(0xFF0D0D0D));
  }

  Color _secondaryTextColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? HFTheme.muted
        : const Color(0xFF6B7280);
  }
}
