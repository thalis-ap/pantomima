import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/localization/greek_strings.dart';
import '../../../core/theme/app_colors.dart';

/// Animated circular countdown timer with dynamic color shifting and pulsing
class CircularTimer extends StatefulWidget {
  final int remainingSeconds;
  final int totalDurationSeconds;
  final bool isRunning;
  final double size;

  const CircularTimer({
    super.key,
    required this.remainingSeconds,
    required this.totalDurationSeconds,
    this.isRunning = true,
    this.size = 140,
  });

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(CircularTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning &&
        widget.remainingSeconds > 0 &&
        widget.remainingSeconds <= 5) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getTimerColor(double ratio, int remaining) {
    if (remaining <= 10 || ratio <= 0.15) {
      return AppColors.alertRed;
    } else if (remaining <= 25 || ratio <= 0.35) {
      return AppColors.passAmber;
    } else {
      return AppColors.electricBlue;
    }
  }

  String _formatTime(int totalSeconds) {
    final clamped = max(0, totalSeconds);
    final minutes = clamped ~/ 60;
    final seconds = clamped % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.totalDurationSeconds > 0
        ? (widget.remainingSeconds / widget.totalDurationSeconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    final timerColor = _getTimerColor(ratio, widget.remainingSeconds);
    final timeStr = _formatTime(widget.remainingSeconds);

    return Semantics(
      label: '${GreekStrings.timerSemantic}: $timeStr',
      value: timeStr,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.remainingSeconds <= 5 && widget.isRunning
              ? _pulseAnimation.value
              : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    timerColor.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Dynamic progress track
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: ratio, end: ratio),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, val, _) {
                    return CircularProgressIndicator(
                      value: val,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                    );
                  },
                ),
              ),
              // Centered time text MM:SS
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: widget.size * 0.24,
                      fontWeight: FontWeight.w900,
                      color: timerColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    GreekStrings.seconds,
                    style: TextStyle(
                      fontSize: widget.size * 0.09,
                      fontWeight: FontWeight.w600,
                      color: timerColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
