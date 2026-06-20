import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:harmfilter_flutter/models/leaderboard_item.dart';
import 'package:harmfilter_flutter/services/leaderboard_service.dart';
import 'package:harmfilter_flutter/widgets/hf_card.dart';
import 'package:harmfilter_flutter/widgets/hf_empty_state.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<LeaderboardItem> _leaderboard = [];
  LeaderboardItem? _currentUser;
  int _totalUsers = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      setState(() => _isLoading = true);
      final leaderboard = await _leaderboardService.getTopLeaderboard();
      final currentUser = await _leaderboardService
          .getCurrentUserLeaderboardItem();
      final totalUsers = await _leaderboardService.getTotalUserCount();

      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _currentUser = currentUser;
          _totalUsers = totalUsers;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: Center(child: CircularProgressIndicator(color: HFTheme.accent)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: HFEmptyState(
          title: 'Error loading leaderboard',
          message: _error!,
          icon: LucideIcons.alertCircle,
          actionLabel: 'RETRY',
          onAction: _loadLeaderboard,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: HFTheme.accent,
          backgroundColor: theme.cardColor,
          onRefresh: _loadLeaderboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'DIGITAL SENTINELS',
                        style: GoogleFonts.inter(
                            color: HFTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leaderboard',
                        style: GoogleFonts.inter(
                            color: HFTheme.primaryTextColor(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Podium
                if (_leaderboard.length >= 3) _buildPodium(),
                if (_leaderboard.length < 3)
                  HFCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Not enough users for leaderboard',
                        style: GoogleFonts.inter(
                          color: HFTheme.secondaryTextColor(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 28),

                // Current user section
                if (_currentUser != null) ...[
                  _buildCurrentUserCard(),
                  const SizedBox(height: 20),
                ],

                // Column headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'USER IDENTITY',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: HFTheme.secondaryTextColor(context),
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'POINTS / RANK',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            color: HFTheme.secondaryTextColor(context),
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Rankings list (skip top 3, already in podium)
                ...List.generate(
                  _leaderboard.length > 3 ? _leaderboard.length - 3 : 0,
                  (index) => _buildRankItem(_leaderboard[index + 3], index + 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    final first = _leaderboard[0];
    final second = _leaderboard[1];
    final third = _leaderboard[2];

    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          Expanded(child: _buildPodiumSlot(second, 2, 100)),
          const SizedBox(width: 8),
          // 1st place
          Expanded(child: _buildPodiumSlot(first, 1, 140)),
          const SizedBox(width: 8),
          // 3rd place
          Expanded(child: _buildPodiumSlot(third, 3, 80)),
        ],
      ),
    );
  }

  Widget _buildPodiumSlot(LeaderboardItem item, int rank, double podiumHeight) {
    final isFirst = rank == 1;
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Medal / Crown for #1
        if (isFirst)
          Icon(LucideIcons.crown, color: HFTheme.accent, size: 28),
        if (!isFirst) const SizedBox(height: 28),
        const SizedBox(height: 6),

        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: isFirst
                ? [BoxShadow(color: HFTheme.accent.withAlpha(51), blurRadius: 20)]
                : null,
          ),
          child: HFAvatar(
            name: item.displayName,
            size: isFirst ? 64 : 52,
            highlight: isFirst,
            borderWidth: 2,
          ),
        ),

        // Rank badge
        Transform.translate(
          offset: const Offset(0, -8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isFirst ? HFTheme.accent : theme.dividerColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '0$rank',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // Podium bar
        Container(
          width: double.infinity,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isFirst ? HFTheme.elevatedColor(context) : theme.cardColor,
                theme.cardColor,
              ],
            ),
            border: Border.all(
              color: isFirst ? HFTheme.accent.withAlpha(77) : theme.dividerColor,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: isFirst
                ? [BoxShadow(color: HFTheme.accent.withAlpha(26), blurRadius: 15)]
                : null,
          ),
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Text(
                item.displayName.length > 10
                    ? '${item.displayName.substring(0, 10)}…'
                    : item.displayName,
                style: GoogleFonts.inter(
                  color: isFirst
                      ? HFTheme.primaryTextColor(context)
                      : HFTheme.secondaryTextColor(context),
                  fontSize: isFirst ? 12 : 10,
                  fontWeight: isFirst ? FontWeight.w700 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${item.points}',
                style: GoogleFonts.inter(
                  color: HFTheme.accent,
                  fontSize: isFirst ? 16 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserCard() {
    final user = _currentUser!;
    final isMe = user.uid == FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HFTheme.elevatedColor(context),
        border: Border.all(color: HFTheme.accent.withAlpha(128)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: HFTheme.accent.withAlpha(26), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Text(
            '${user.rank}',
            style: GoogleFonts.inter(
              color: HFTheme.accent.withAlpha(128),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 12),
          HFAvatar(name: user.displayName, size: 40, borderWidth: 1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe
                      ? 'YOU (${user.displayName.toUpperCase()})'
                      : user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: HFTheme.primaryTextColor(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'ACTIVE DEFENSE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: HFTheme.accent,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.points}',
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                'RANK #${user.rank} of $_totalUsers',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(LeaderboardItem item, int displayRank) {
    final isCurrentUser = item.uid == FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrentUser ? HFTheme.elevatedColor(context) : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentUser
                ? HFTheme.accent.withAlpha(128)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${displayRank.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  color: theme.dividerColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Opacity(
                opacity: 0.8,
                child: HFAvatar(
                  name: item.displayName,
                  size: 36,
                  borderWidth: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: GoogleFonts.inter(
                      color: HFTheme.secondaryTextColor(context),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${item.points}',
              style: GoogleFonts.inter(
                color: HFTheme.primaryTextColor(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
