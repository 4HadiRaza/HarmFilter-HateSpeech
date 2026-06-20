import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:harmfilter_flutter/services/auth_service.dart';
import 'package:harmfilter_flutter/services/firebase_service.dart';
import 'package:harmfilter_flutter/services/theme_service.dart';
import 'package:harmfilter_flutter/widgets/hf_snackbar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _kAvatarSeed = 'avatar_seed';
  static const List<_AccentOption> _accentOptions = [
    _AccentOption('Red', Color(0xFFE8001D)),
    _AccentOption('Blue', Color(0xFF2563EB)),
    _AccentOption('Purple', Color(0xFF8B5CF6)),
    _AccentOption('Green', Color(0xFF16A34A)),
    _AccentOption('Pink', Color(0xFFDB2777)),
    _AccentOption('Orange', Color(0xFFF97316)),
    _AccentOption('Teal', Color(0xFF0F766E)),
    _AccentOption('Amber', Color(0xFFF59E0B)),
  ];

  final TextEditingController _nameController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _editingDisplayName = false;
  bool _savingName = false;
  String _avatarSeed = 'default';
  String _appVersion = '-';

  User? get _user => FirebaseAuth.instance.currentUser;

  String get _displayName {
    final current = _user?.displayName?.trim();
    if (current != null && current.isNotEmpty) return current;
    final emailPrefix = _user?.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) return emailPrefix;
    return 'User';
  }

  String get _userEmail => _user?.email ?? 'Not signed in';

  String get _avatarUrl {
    return 'https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(_avatarSeed)}';
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _displayName;
    _loadPreferences();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final fallbackSeed = (_user?.displayName?.trim().isNotEmpty ?? false)
        ? _user!.displayName!.trim()
        : 'default';

    if (!mounted) return;
    setState(() {
      _avatarSeed = prefs.getString(_kAvatarSeed) ?? fallbackSeed;
    });
  }

  Future<void> _regenerateAvatar() async {
    final newSeed = DateTime.now().millisecondsSinceEpoch.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarSeed, newSeed);

    if (!mounted) return;
    setState(() => _avatarSeed = newSeed);

    try {
      await _firebaseService.updateUserAvatarSeed(newSeed);
    } catch (_) {
      // Keep local update even if remote persistence fails.
    }
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  Future<void> _saveDisplayName() async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) {
      HFSnackbar.show(context, 'Display name cannot be empty', isError: true);
      return;
    }

    setState(() => _savingName = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(trimmed);
      await _firebaseService.updateUserDisplayName(trimmed);
      if (!mounted) return;
      setState(() {
        _editingDisplayName = false;
        _savingName = false;
      });
      HFSnackbar.show(context, 'Display name updated.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _savingName = false);
      HFSnackbar.show(context, 'Failed to update. Try again.', isError: true);
    }
  }

  void _showChangePasswordSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return _ChangePasswordSheet(
          userEmail: _userEmail,
          hostContext: context,
        );
      },
    );
  }

  void _showLogoutSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Log out of HarmFilter?',
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can sign in again anytime.',
                style: GoogleFonts.inter(
                  color: _secondaryTextColor(theme),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HFTheme.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await authService.logout();
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    context.go('/login');
                  },
                  child: Text(
                    'LOG OUT',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: isDark
                        ? const Color(0xFF8A8A8A)
                        : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchExternal(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _sendFeedback() async {
    final uri = Uri.parse(
      'mailto:support@harmfilter.com?subject=HarmFilter%20Feedback&body=App%20Version%3A%20$_appVersion%0ADevice%3A%20%5Bdevice%5D%0A%0A',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _rateApp() async {
    final url = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? 'https://play.google.com/store/apps/details?id=com.example.harmfilter_flutter'
        : 'https://apps.apple.com/app/idYOUR_APP_ID';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.inter(
            color: theme.appBarTheme.foregroundColor ?? _primaryTextColor(theme),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Consumer<ThemeService>(
          builder: (context, themeService, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('ACCOUNT'),
                  const SizedBox(height: 8),
                  _buildAccountCard(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('APPEARANCE'),
                  const SizedBox(height: 8),
                  _buildThemeToggle(themeService),
                  const SizedBox(height: 12),
                  _buildAccentCard(themeService),
                  const SizedBox(height: 24),
                  _buildSectionLabel('ABOUT'),
                  const SizedBox(height: 8),
                  _buildAboutCard(),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: _showLogoutSheet,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: HFTheme.accent),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'LOG OUT',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: HFTheme.accent,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: GoogleFonts.inter(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF555555)
            : const Color(0xFF6B7280),
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _cardShell({required Widget child}) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildAccountCard() {
    final theme = Theme.of(context);
    return _cardShell(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: HFTheme.accent.withAlpha(102),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: SvgPicture.network(_avatarUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: _primaryTextColor(theme),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),
          _divider(context),
          _buildDisplayNameRow(),
          _divider(context),
          _buildAvatarRow(),
          _divider(context),
          _buildActionRow(
            label: 'Change Password',
            onTap: () => _showChangePasswordSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayNameRow() {
    final theme = Theme.of(context);
    if (_editingDisplayName) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(
              'Display Name',
              style: GoogleFonts.inter(
                color: _secondaryTextColor(theme),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 4),
                  border: InputBorder.none,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: HFTheme.accent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: HFTheme.accent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _savingName
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: HFTheme.accent,
                    ),
                  )
                : IconButton(
                    onPressed: _saveDisplayName,
                    icon: const Icon(
                      Icons.check,
                      color: Color(0xFF00C853),
                      size: 20,
                    ),
                  ),
            IconButton(
              onPressed: () {
                setState(() {
                  _editingDisplayName = false;
                  _nameController.text = _displayName;
                });
              },
              icon: Icon(Icons.close, color: HFTheme.accent, size: 20),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        setState(() {
          _nameController.text = _displayName;
          _editingDisplayName = true;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Text(
              'Display Name',
              style: GoogleFonts.inter(
                color: _secondaryTextColor(theme),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              _displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _primaryTextColor(theme),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.edit, size: 14, color: _mutedIconColor(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentCard(ThemeService themeService) {
    final theme = Theme.of(context);
    return _cardShell(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accent Color',
              style: GoogleFonts.inter(
                color: _primaryTextColor(theme),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose the highlight color used across the app.',
              style: GoogleFonts.inter(
                color: _secondaryTextColor(theme),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _accentOptions
                  .map(
                    (option) => _buildAccentOption(
                      option: option,
                      selected: themeService.accentColor == option.color,
                      onTap: () => themeService.setAccentColor(option.color),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentOption({
    required _AccentOption option,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161616) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? option.color : theme.dividerColor,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: option.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: option.color.withOpacity(0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: isDark
                    ? HFTheme.text
                    : const Color(0xFF374151),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: 12,
                ),
              ),
            ),
            if (value != null) ...[
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    color: _primaryTextColor(theme),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right, color: _trailingIconColor(theme), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Text(
            'Avatar',
            style: GoogleFonts.inter(
              color: _primaryTextColor(theme),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _regenerateAvatar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            splashRadius: 18,
            icon: Icon(
              Icons.chevron_left,
              color: _trailingIconColor(theme),
              size: 22,
            ),
          ),
          IconButton(
            onPressed: _regenerateAvatar,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            splashRadius: 18,
            icon: Icon(
              Icons.chevron_right,
              color: _trailingIconColor(theme),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeService themeService) {
    final theme = Theme.of(context);
    return _cardShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Dark Mode',
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: 14,
                ),
              ),
            ),
            Switch.adaptive(
              value: themeService.isDarkMode,
              onChanged: (v) => themeService.toggleTheme(v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return _cardShell(
      child: Consumer<ThemeService>(
        builder: (context, _, __) {
          return Column(
            children: [
              _buildStaticInfoRow(context: context, label: 'App Version', value: _appVersion),
              _divider(context),
              _buildExternalRow(
                context: context,
                label: 'Privacy Policy',
                onTap: () => _launchExternal('https://harmfilter.com/privacy-policy'),
              ),
              _divider(context),
              _buildExternalRow(
                context: context,
                label: 'Terms of Service',
                onTap: () => _launchExternal('https://harmfilter.com/terms-of-service'),
              ),
              _divider(context),
              _buildExternalRow(context: context, label: 'Send Feedback', onTap: _sendFeedback),
              _divider(context),
              _buildExternalRow(context: context, label: 'Rate the App', onTap: _rateApp),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStaticInfoRow({required BuildContext context, required String label, required String value}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _primaryTextColor(theme),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _secondaryTextColor(theme),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalRow({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _primaryTextColor(theme),
                  fontSize: 12,
                ),
              ),
            ),
            Icon(Icons.open_in_new, color: _trailingIconColor(theme), size: 18),
          ],
        ),
      ),
    );
  }

  Color _primaryTextColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? HFTheme.text
        : const Color(0xFF0D0D0D);
  }

  Color _secondaryTextColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? const Color(0xFF8A8A8A)
        : const Color(0xFF6B7280);
  }

  Color _mutedIconColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? const Color(0xFF555555)
        : const Color(0xFF9CA3AF);
  }

  Color _trailingIconColor(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? const Color(0xFF555555)
        : const Color(0xFF9CA3AF);
  }
}

class _AccentOption {
  const _AccentOption(this.label, this.color);

  final String label;
  final Color color;
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({
    required this.userEmail,
    required this.hostContext,
  });

  final String userEmail;
  final BuildContext hostContext;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reset Password',
              style: GoogleFonts.inter(
                color: theme.textTheme.titleMedium?.color ?? HFTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll send a password reset link to your registered email address.",
              style: GoogleFonts.inter(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF8A8A8A)
                    : const Color(0xFF6B7280),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF161616)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.userEmail,
                style: GoogleFonts.inter(
                  color: theme.textTheme.bodyMedium?.color ?? HFTheme.text,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HFTheme.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _sending
                    ? null
                    : () async {
                        setState(() => _sending = true);
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: widget.userEmail,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          HFSnackbar.show(
                            widget.hostContext,
                            'Reset link sent. Check your email.',
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          setState(() => _sending = false);
                          HFSnackbar.show(
                            widget.hostContext,
                            'Failed to send. Try again.',
                            isError: true,
                          );
                        }
                      },
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'SEND RESET LINK',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _sending ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF8A8A8A)
                        : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
