import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/services/firestore_service.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class _ReportOption {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

String _normalizeFlag(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized == 'hateful') return 'hate';
  if (normalized == 'hate') return 'hate';
  if (normalized == 'offensive') return 'offensive';
  return 'normal';
}

Future<void> showReportPostSheet(
  BuildContext context, {
  required String postId,
  required String postContent,
  required String currentFlag,
}) async {
  final options = [
    const _ReportOption(
      label: 'Normal',
      value: 'normal',
      icon: Icons.check_circle_outline,
      color: Color(0xFF00C853),
    ),
    const _ReportOption(
      label: 'Offensive',
      value: 'offensive',
      icon: Icons.warning_amber_outlined,
      color: Color(0xFFFF9100),
    ),
    _ReportOption(
      label: 'Hate',
      value: 'hate',
      icon: Icons.dangerous_outlined,
      color: HFTheme.accent,
    ),
  ];

  final normalizedCurrent = _normalizeFlag(currentFlag);
  bool isSubmitting = false;
  String? submittingValue;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final theme = Theme.of(sheetContext);
          final titleColor = HFTheme.primaryTextColor(sheetContext);
          final subtitleColor = HFTheme.secondaryTextColor(sheetContext);

          Future<void> submitOption(_ReportOption option) async {
            setSheetState(() {
              isSubmitting = true;
              submittingValue = option.value;
            });

            try {
              await FirestoreService().submitPostReport(
                postId: postId,
                postContent: postContent,
                currentFlag: normalizedCurrent,
                reportedAs: option.value,
              );

              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report submitted. Thank you for your feedback.'),
                ),
              );
            } catch (_) {
              if (!sheetContext.mounted) return;
              setSheetState(() {
                isSubmitting = false;
                submittingValue = null;
              });

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Something went wrong. Please try again.'),
                ),
              );
            }
          }

          Widget buildOptionTile(_ReportOption option) {
            final isCurrent = normalizedCurrent == option.value;
            final isDisabled = isSubmitting || isCurrent;
            final tileColor = isCurrent
                ? theme.dividerColor.withAlpha(20)
                : theme.colorScheme.surface;
            final borderColor = isCurrent
                ? theme.dividerColor
                : option.color.withAlpha(100);
            final labelColor =
                isDisabled ? subtitleColor : HFTheme.primaryTextColor(sheetContext);
            final iconColor = isDisabled ? subtitleColor : option.color;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isDisabled ? null : () => submitOption(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(option.icon, color: iconColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              option.label,
                              style: GoogleFonts.inter(
                                color: labelColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(current)',
                                style: GoogleFonts.inter(
                                  color: subtitleColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSubmitting && submittingValue == option.value)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: HFTheme.accent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Incorrect Flag',
                    style: GoogleFonts.inter(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'What should this post actually be classified as?',
                    style: GoogleFonts.inter(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final option in options) ...[
                    buildOptionTile(option),
                    const SizedBox(height: 12),
                  ],
                  if (isSubmitting) const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
