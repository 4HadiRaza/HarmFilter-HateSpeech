import 'package:flutter/material.dart';
import 'hf_theme.dart';

class HFSkeleton extends StatefulWidget {
  const HFSkeleton({super.key, this.height = 16, this.width = double.infinity, this.radius = 8});

  final double height;
  final double width;
  final double radius;

  @override
  State<HFSkeleton> createState() => _HFSkeletonState();
}

class _HFSkeletonState extends State<HFSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final opacity = 0.2 + (_controller.value * 0.2);
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: HFTheme.border.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
