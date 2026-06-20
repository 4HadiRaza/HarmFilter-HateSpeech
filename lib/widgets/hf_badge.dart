import 'package:flutter/material.dart';
import 'hf_theme.dart';

class HFBadge extends StatelessWidget {
  const HFBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.borderColor,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = background ?? HFTheme.elevatedColor(context);
    final effectiveForeground = foreground ?? HFTheme.primaryTextColor(context);
    final effectiveBorder = borderColor ?? HFTheme.borderColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: effectiveBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: effectiveForeground,
        ),
      ),
    );
  }
}
