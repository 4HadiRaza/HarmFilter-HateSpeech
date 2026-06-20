import 'package:flutter/material.dart';
import 'hf_theme.dart';

class HFSnackbar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : HFTheme.primaryTextColor(context),
          ),
        ),
        backgroundColor: isError
            ? HFTheme.accent
            : (HFTheme.isDark(context) ? HFTheme.elevated : theme.cardColor),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
