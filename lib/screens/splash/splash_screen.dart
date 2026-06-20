import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          context.go('/dashboard');
        } else {
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: _DotTexture()),
            const Positioned(
              top: 16,
              left: 16,
              child: _Corner(isTop: true, isLeft: true),
            ),
            const Positioned(
              top: 16,
              right: 16,
              child: _Corner(isTop: true, isLeft: false),
            ),
            const Positioned(
              bottom: 16,
              left: 16,
              child: _Corner(isTop: false, isLeft: true),
            ),
            const Positioned(
              bottom: 16,
              right: 16,
              child: _Corner(isTop: false, isLeft: false),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.9, end: 1),
                      duration: const Duration(milliseconds: 1800),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: HFTheme.accent.withAlpha(102),
                              blurRadius: 36,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 110,
                          color: HFTheme.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'HarmFilter',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            color: HFTheme.primaryTextColor(context),
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: HFTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'INITIALIZING SECURITY LAYER',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: HFTheme.secondaryTextColor(context),
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CORE STATUS',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: theme.dividerColor,
                          ),
                        ),
                        Text(
                          'BOOTSTRAPPING',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: HFTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ENCRYPTION',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: theme.dividerColor,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: List.generate(
                            4,
                            (i) => Container(
                              width: 16,
                              height: 4,
                              margin: const EdgeInsets.only(left: 3),
                              color: HFTheme.accent.withValues(
                                alpha: 0.25 + (i * 0.2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotTexture extends StatelessWidget {
  const _DotTexture();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotTexturePainter());
  }
}

class _DotTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = HFTheme.accent.withValues(alpha: 0.04);
    const spacing = 22.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Corner extends StatelessWidget {
  const _Corner({required this.isTop, required this.isLeft});

  final bool isTop;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final border = Border(
      top: isTop
          ? BorderSide(color: borderColor, width: 2)
          : BorderSide.none,
      bottom: !isTop
          ? BorderSide(color: borderColor, width: 2)
          : BorderSide.none,
      left: isLeft
          ? BorderSide(color: borderColor, width: 2)
          : BorderSide.none,
      right: !isLeft
          ? BorderSide(color: borderColor, width: 2)
          : BorderSide.none,
    );

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(border: border),
    );
  }
}
