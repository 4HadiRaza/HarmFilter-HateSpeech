import 'package:flutter/material.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class HFToggle extends StatelessWidget {
  const HFToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const double trackWidth = 48;
    const double trackHeight = 26;
    const double thumbSize = 20;
    const double inset = 3;

    final inactiveTrack = HFTheme.isDark(context)
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFD1D5DB);

    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.translucent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: trackWidth,
        height: trackHeight,
        decoration: BoxDecoration(
          color: value ? HFTheme.accent : inactiveTrack,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              top: inset,
              left: value ? (trackWidth - thumbSize - inset) : inset,
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
