import 'package:flutter/material.dart';

/// Reusable premium button for «Παντομίμα»
class GreekButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final double height;
  final double fontSize;
  final String? semanticLabel;
  final bool isFullWidth;

  const GreekButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 58,
    this.fontSize = 18,
    this.semanticLabel,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isEnabled ? textColor : textColor.withValues(alpha: 0.5),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      label: semanticLabel ?? text,
      button: true,
      enabled: isEnabled,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: isEnabled ? gradient : null,
          color: isEnabled
              ? (gradient == null
                    ? (backgroundColor ?? Theme.of(context).colorScheme.primary)
                    : null)
              : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isEnabled && (gradient != null || backgroundColor != null)
              ? [
                  BoxShadow(
                    color: (backgroundColor ?? Colors.purple).withValues(
                      alpha: 0.35,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }
}
