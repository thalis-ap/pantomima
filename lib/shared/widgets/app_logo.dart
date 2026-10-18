import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// In-app branding logo widget featuring the authentic mime artwork
/// on a purple gradient background.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const AppLogo({
    super.key,
    this.size = 100,
    this.showShadow = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        gradient: AppColors.heroGradient,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.45),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/icon/mime.png',
        width: size * 0.74,
        height: size * 0.74,
        fit: BoxFit.contain,
        semanticLabel: 'Παντομίμα Logo',
      ),
    );
  }
}
