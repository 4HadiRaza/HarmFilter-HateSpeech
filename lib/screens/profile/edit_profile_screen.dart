import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/widgets/hf_button.dart';
import 'package:harmfilter_flutter/widgets/hf_snackbar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';
import 'package:harmfilter_flutter/widgets/hf_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;
  bool _isLoading = true;

  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _websiteController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final profile = await _firestoreService.getCurrentUserProfile();
      final user = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      _nameController.text = profile?.displayName ?? user?.displayName ?? '';
      _bioController.text = '';
      _websiteController.text = '';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await _firestoreService.updateCurrentUserProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        website: _websiteController.text.trim(),
      );
      if (!mounted) return;
      HFSnackbar.show(context, 'Profile updated');
      context.pop();
    } catch (_) {
      if (!mounted) return;
      HFSnackbar.show(context, 'Failed to save profile', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: Icon(Icons.close, color: HFTheme.primaryTextColor(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: HFButton(
              label: _isSaving ? 'SAVING...' : 'SAVE',
              expand: false,
              onPressed: _isSaving ? null : _saveProfile,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: HFTheme.accent))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Banner
                  Container(
                    height: 130,
                    width: double.infinity,
                    color: HFTheme.elevatedColor(context),
                    child: Center(
                      child: Icon(LucideIcons.camera, color: HFTheme.secondaryTextColor(context), size: 28),
                    ),
                  ),

                  // Avatar (overlapping)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                      ),
                      child: HFAvatar(
                        name: _nameController.text.isNotEmpty ? _nameController.text : 'U',
                        size: 80,
                        borderWidth: 0,
                      ),
                    ),
                  ),

                  // Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Name',
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _bioController,
                            label: 'Bio',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _websiteController,
                            label: 'Website',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context), fontSize: 12),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: HFTheme.accent),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: HFTheme.accent),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: HFTheme.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
