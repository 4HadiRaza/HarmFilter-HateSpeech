import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/widgets/hf_skeleton.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

/// A dynamic cartoon avatar widget powered by DiceBear.
/// Uses the 'adventurer' style with the username as the seed.
/// Falls back to the initials circle if network fails.
class HFAvatar extends StatelessWidget {
  const HFAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.highlight = false,
    this.borderWidth = 1.5,
  });

  /// The username to use as the seed.
  final String name;

  /// Diameter of the avatar. Defaults to 40.
  final double size;

  /// Retained for compatibility but mostly overridden by the new design.
  final bool highlight;
  final double borderWidth;

  /// Generates 1–2 initials from [name] for the fallback.
  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'D'; // default fallback
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  /// Deterministic color from the name string for the fallback.
  Color _backgroundColor(BuildContext context) {
    if (name.trim().isEmpty) return HFTheme.elevatedColor(context);
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.45, 0.30).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final seedName = name.trim().isEmpty ? 'default' : name.trim();
    final url = 'https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(seedName)}';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size),
        border: Border.all(color: HFTheme.accent.withAlpha(51), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: SvgPicture.network(
          url,
          width: size,
          height: size,
          placeholderBuilder: (BuildContext context) => HFSkeleton(
            width: size,
            height: size,
            radius: size,
          ),
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.inter(
            color: HFTheme.primaryTextColor(context),
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
