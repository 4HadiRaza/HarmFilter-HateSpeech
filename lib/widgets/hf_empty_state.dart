import 'package:flutter/material.dart';
import 'hf_button.dart';
import 'hf_theme.dart';

class HFEmptyState extends StatelessWidget {
  const HFEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final mutedColor = Theme.of(context).brightness == Brightness.dark
        ? HFTheme.muted
        : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: mutedColor),
            const SizedBox(height: 12),
            Text(title, style: HFTheme.syneTitle(context, size: 22), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: HFTheme.body(context, size: 14).copyWith(color: mutedColor), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              HFButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
