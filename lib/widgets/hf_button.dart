import 'package:flutter/material.dart';
import 'hf_theme.dart';

enum HFButtonStyleType { filled, outlined, ghost }

class HFButton extends StatelessWidget {
  const HFButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.styleType = HFButtonStyleType.filled,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final HFButtonStyleType styleType;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText = theme.textTheme.bodyMedium?.color ?? HFTheme.text;
    final mutedText = isDark ? HFTheme.muted : const Color(0xFF6B7280);
    final foreground = styleType == HFButtonStyleType.filled
        ? Colors.white
        : (styleType == HFButtonStyleType.outlined
              ? primaryText
              : mutedText);
    final background = styleType == HFButtonStyleType.filled
        ? HFTheme.accent
        : Colors.transparent;

    final hasLabel = label.trim().isNotEmpty;

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: 18),
        if (icon != null && hasLabel) const SizedBox(width: 8),
        if (hasLabel)
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );

    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        padding: EdgeInsets.symmetric(
          horizontal: hasLabel ? 16 : 12,
          vertical: 16,
        ),
        minimumSize: Size(hasLabel ? 64 : 44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: styleType == HFButtonStyleType.filled
                ? Colors.transparent
                : (styleType == HFButtonStyleType.outlined
                      ? theme.dividerColor
                      : Colors.transparent),
          ),
        ),
      ),
      child: child,
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
