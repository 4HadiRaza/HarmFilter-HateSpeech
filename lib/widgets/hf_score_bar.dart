import 'package:flutter/material.dart';
import 'hf_theme.dart';

class HFScoreBar extends StatelessWidget {
  const HFScoreBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();
    final barColor = color ?? (clamped > 0.6 ? HFTheme.accent : (clamped > 0.3 ? Colors.orange : Colors.green));
    final secondaryText = HFTheme.secondaryTextColor(context);
    final borderColor = HFTheme.borderColor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.w700)),
            Text('${(clamped * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: barColor, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: clamped,
            backgroundColor: borderColor,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
