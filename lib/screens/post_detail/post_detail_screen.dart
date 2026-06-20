import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/models/post_model.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/widgets/hf_card.dart';
import 'package:harmfilter_flutter/widgets/hf_empty_state.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  final FirestoreService _firestoreService = FirestoreService();

  PostDetailScreen({super.key, required this.postId});

  Color _getLabelColor(String label) {
    switch (label) {
      case 'normal':
        return const Color(0xFF00C853);
      case 'offensive':
        return const Color(0xFFFF9100);
      case 'hateful':
        return HFTheme.accent;
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label) {
      case 'normal':
        return LucideIcons.checkCircle2;
      case 'offensive':
        return LucideIcons.alertTriangle;
      case 'hateful':
        return LucideIcons.shieldAlert;
      default:
        return LucideIcons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text(
          'Post Details',
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: HFTheme.primaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<PostModel?>(
        stream: _firestoreService.getPostByIdStream(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: HFTheme.accent));
          }

          if (snapshot.hasError) {
            return HFEmptyState(
              title: 'Error',
              message: '${snapshot.error}',
              icon: LucideIcons.alertCircle,
            );
          }

          final post = snapshot.data;
          if (post == null) {
            return const HFEmptyState(
              title: 'Post not found',
              message: 'This post may have been deleted.',
              icon: LucideIcons.fileQuestion,
            );
          }

          final labelColor = _getLabelColor(post.label);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Row(
                  children: [
                    HFAvatar(name: post.username, size: 56),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: GoogleFonts.inter(
                            color: HFTheme.primaryTextColor(context),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          post.createdAt.toLocal().toString().split('.').first,
                          style: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Post text
                HFCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    post.text,
                    style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontSize: 15, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Label card
                HFCard(
                  borderColor: labelColor,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_getLabelIcon(post.label), color: labelColor, size: 22),
                          const SizedBox(width: 8),
                            Text(
                            post.label.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: labelColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: labelColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(16),
                        ),
                          child: Text(
                          post.language == 'roman-urdu' ? 'Roman Urdu' : 'English',
                          style: GoogleFonts.inter(
                            color: labelColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Score cards
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreCard(
                        context,
                        'Text Score',
                        post.textScore,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildScoreCard(
                        context,
                        'Image Score',
                        post.imageScore ?? 0.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildScoreCard(
                        context,
                        'Fused Score',
                        post.fusedScore,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Explanation
                Text(
                  'EXPLANATION',
                  style: GoogleFonts.inter(
                    color: HFTheme.primaryTextColor(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                HFCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    post.explanation.isNotEmpty ? post.explanation : 'No explanation available.',
                    style: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context), fontSize: 13, height: 1.5),
                  ),
                ),

                // Problematic spans
                if (post.problematicSpans.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'PROBLEMATIC PHRASES',
                    style: GoogleFonts.inter(
                      color: HFTheme.primaryTextColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: post.problematicSpans.map((span) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: HFTheme.accent.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: HFTheme.accent.withAlpha(51)),
                        ),
                          child: Text(
                          '"$span"',
                          style: GoogleFonts.inter(color: HFTheme.accent, fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Suggestions
                if (post.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'SUGGESTED REWRITES',
                    style: GoogleFonts.inter(
                      color: HFTheme.primaryTextColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...post.suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HFCard(
                        borderColor: const Color(0xFF00C853).withAlpha(77),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.lightbulb, color: Color(0xFF00C853), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                suggestion,
                                style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, String title, double score) {
    final theme = Theme.of(context);
    return HFCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              color: HFTheme.secondaryTextColor(context),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(score * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.inter(
              color: HFTheme.primaryTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(HFTheme.accent),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
