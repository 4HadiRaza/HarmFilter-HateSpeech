import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmfilter_flutter/models/post_model.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/models/user_profile.dart';
import 'package:harmfilter_flutter/widgets/hf_empty_state.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';
import 'package:harmfilter_flutter/widgets/report_post_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _deletePost(BuildContext context, String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Delete',
                style: TextStyle(color: HFTheme.accent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await FirestoreService().deletePost(postId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _buildProfileHeader(context)),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(_buildTabBar()),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [_buildPostsTab(context), _buildReportedTab()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<UserProfile?>(
      future: FirestoreService().getCurrentUserProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final displayName = profile?.displayName ?? user?.displayName ?? 'User';
        final email = profile?.email ?? user?.email ?? '';
        final bio = profile?.bio?.trim() ?? '';
        final handle = email.isNotEmpty
            ? '@${email.split('@').first}'
            : '@user';

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: HFTheme.accent, width: 2),
                    ),
                    child: HFAvatar(name: displayName, size: 72, borderWidth: 0),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => context.push('/edit-profile'),
                          style: FilledButton.styleFrom(
                            backgroundColor: HFTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'EDIT PROFILE',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: HFTheme.primaryTextColor(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                handle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: HFTheme.secondaryTextColor(context),
                  fontSize: 13,
                ),
              ),
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: HFTheme.primaryTextColor(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorColor: HFTheme.accent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: HFTheme.primaryTextColor(context),
          labelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelColor: HFTheme.secondaryTextColor(context),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
          tabs: const [
            Tab(text: "Posts"),
            Tab(text: "Reported"),
          ],
        ),
      );
    });
  }

  Widget _buildPostsTab(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const HFEmptyState(
        title: 'Not signed in',
        message: 'Please log in to view your posts.',
        icon: LucideIcons.logIn,
      );
    }

    return StreamBuilder<List<PostModel>>(
      stream: FirestoreService().getUserPostsStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: HFTheme.accent),
          );
        }

        if (snapshot.hasError) {
          return HFEmptyState(
            title: 'Error',
            message: '${snapshot.error}',
            icon: LucideIcons.alertCircle,
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(height: 12),
                Text(
                  'No posts yet',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostItem(
              context,
              name: post.username,
              content: post.text,
              label: post.label,
              postId: post.id,
              onDelete: () => _deletePost(context, post.id),
              onReport: () => showReportPostSheet(
                context,
                postId: post.id,
                postContent: post.text,
                currentFlag: post.label,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportedTab() {
    return const HFEmptyState(
      title: 'Coming Soon',
      message: 'Reported content review is under development.',
      icon: LucideIcons.clock,
    );
  }

  Widget _buildPostItem(
    BuildContext context, {
    required String name,
    required String content,
    String? label,
    required String postId,
    required VoidCallback onDelete,
    required VoidCallback onReport,
  }) {
    return GestureDetector(
      onTap: () => context.push('/post-detail/$postId'),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HFAvatar(name: name, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: HFTheme.primaryTextColor(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onReport,
                      tooltip: 'Report post',
                      icon: const Icon(
                        Icons.flag_outlined,
                        color: Color(0xFF6B7280),
                        size: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Delete post',
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF6B7280),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: HFTheme.primaryTextColor(context),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (label != null && label != 'normal') ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HFTheme.accent.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HFTheme.accent.withAlpha(51)),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: HFTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _tabBar;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
