import 'package:flutter/material.dart';
import 'hf_theme.dart';

class HFCard extends StatelessWidget {
  const HFCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 20),
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 12,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding.add(const EdgeInsets.only(bottom: 8));
    final theme = Theme.of(context);

    final card = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? theme.dividerColor),
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: card,
    );
  }
}
