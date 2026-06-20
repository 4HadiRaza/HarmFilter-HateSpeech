import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmfilter_flutter/services/auth_service.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/widgets/hf_button.dart';
import 'package:harmfilter_flutter/widgets/hf_card.dart';
import 'package:harmfilter_flutter/widgets/hf_input.dart';
import 'package:harmfilter_flutter/widgets/hf_snackbar.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${_usernameController.text}@harmfilter.com',
          password: _passwordController.text,
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Initialize user profile in Firestore
          await FirestoreService().initializeUserProfile(user);

          // Save user data to local persistence
          await authService.login(user.email!, user.uid, user.displayName);
        }

        if (mounted) {
          context.go('/dashboard');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          String message = 'Login failed';
          if (e.code == 'user-not-found') {
            message = 'No user found with this username';
          } else if (e.code == 'wrong-password') {
            message = 'Wrong password';
          } else if (e.code == 'invalid-email') {
            message = 'Invalid username format';
          }
          HFSnackbar.show(context, message, isError: true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          HFSnackbar.show(context, 'An error occurred', isError: true);
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      await authService.signInWithGoogle();
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      HFSnackbar.show(
        context,
        'Google sign-in failed. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthTexture()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: 0.785398,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: HFTheme.accent,
                                      width: 2,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Transform.rotate(
                                    angle: -0.785398,
                                    child: Icon(
                                      Icons.shield_outlined,
                                      color: HFTheme.accent,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                    'HARM FILTER',
                                  maxLines: 1,
                                  softWrap: false,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: HFTheme.primaryTextColor(context),
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      HFCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HFInput(
                              controller: _usernameController,
                              label: 'Username',
                              hint: 'username',
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your username';
                                if (value.contains(' '))
                                  return 'Username cannot contain spaces';
                                if (value != value.toLowerCase())
                                  return 'Username must be lowercase';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            HFInput(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please enter your password';
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                child: Text(
                                  'Forgot Password',
                                  style: GoogleFonts.inter(
                                    color: HFTheme.accent,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            HFButton(
                              label: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
                              onPressed: _isLoading ? null : _handleLogin,
                              icon: Icons.arrow_forward,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.inter(
                                      color: HFTheme.secondaryTextColor(context),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: (_isLoading || _isGoogleLoading)
                                  ? null
                                  : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                side: BorderSide(color: theme.dividerColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: theme.cardColor,
                              ),
                              child: _isGoogleLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.g_mobiledata,
                                          color: Colors.redAccent,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Continue with Google',
                                          style: GoogleFonts.inter(
                                            color: HFTheme.primaryTextColor(context),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/signup'),
                            child: Text(
                            'New user? Signup',
                            style: GoogleFonts.inter(
                              color: HFTheme.secondaryTextColor(context),
                              fontSize: 10,
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
        ],
      ),
    );
  }
}

class _AuthTexture extends StatelessWidget {
  const _AuthTexture();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AuthTexturePainter());
  }
}

class _AuthTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = HFTheme.accent.withValues(alpha: 0.03);
    const spacing = 24.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [HFTheme.accent.withAlpha(51), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.85, size.height * 0.1),
              radius: 240,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.1),
      240,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
