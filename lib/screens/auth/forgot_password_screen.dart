import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/widgets/hf_button.dart';
import 'package:harmfilter_flutter/widgets/hf_input.dart';
import 'package:harmfilter_flutter/widgets/hf_snackbar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      HFSnackbar.show(
        context,
        'Password reset email sent. Check your inbox.',
      );
      context.pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'invalid-email' => 'Please enter a valid email.',
        'user-not-found' => 'No account found for this email.',
        _ => 'Unable to send reset email. Try again.',
      };
      HFSnackbar.show(context, message, isError: true);
    } catch (_) {
      if (!mounted) return;
      HFSnackbar.show(context, 'Unable to send reset email.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Reset Credentials',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: HFTheme.primaryTextColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PASSWORD RECOVERY',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: HFTheme.secondaryTextColor(context),
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your account email and we will send a reset link.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: HFTheme.primaryTextColor(context),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    HFInput(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      hint: 'name@domain.com',
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Please enter your email';
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    HFButton(
                      label: _isSending ? 'SENDING...' : 'SEND RESET LINK',
                      icon: Icons.send,
                      onPressed: _isSending ? null : _sendResetLink,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(
                        'Back to login',
                        style: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
