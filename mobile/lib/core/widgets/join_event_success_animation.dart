import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';

/// A full-screen overlay that plays a liquid-ripple celebration
/// when the user successfully joins an event.
class JoinEventSuccessAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const JoinEventSuccessAnimation({super.key, required this.onComplete});

  @override
  State<JoinEventSuccessAnimation> createState() =>
      _JoinEventSuccessAnimationState();
}

class _JoinEventSuccessAnimationState extends State<JoinEventSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return IgnorePointer(
          child: Opacity(
            opacity: (1.0 - t).clamp(0.0, 1.0),
            child: CustomPaint(
              painter: _LiquidRipplePainter(progress: t),
              size: MediaQuery.of(context).size,
            ),
          ),
        );
      },
    );
  }
}

class _LiquidRipplePainter extends CustomPainter {
  final double progress;

  _LiquidRipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );

    // Phase timings (0..1 mapped to overall progress)
    final rippleT = (progress / 0.7).clamp(0.0, 1.0);
    final blobT = ((progress - 0.1) / 0.5).clamp(0.0, 1.0);
    final checkT = ((progress - 0.35) / 0.45).clamp(0.0, 1.0);
    final sparkleT = ((progress - 0.2) / 0.6).clamp(0.0, 1.0);

    // ── Ripple rings ─────────────────────────────────────────────────────
    final rippleCount = 4;
    for (var i = 0; i < rippleCount; i++) {
      final delay = i * 0.12;
      final p = ((rippleT - delay) / (1.0 - delay)).clamp(0.0, 1.0);
      if (p <= 0) continue;

      final radius = maxRadius * p * 0.8;
      final opacity = (1.0 - p) * 0.35;

      final glowPaint = Paint()
        ..color = AppThemeColors.primaryAccent.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0 * (1.0 - p);
      canvas.drawCircle(center, radius + 6, glowPaint);

      final ringPaint = Paint()
        ..color = AppThemeColors.primaryAccent.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * (1.0 - p * 0.5);
      canvas.drawCircle(center, radius, ringPaint);
    }

    // ── Central liquid blob ──────────────────────────────────────────────
    if (blobT > 0) {
      final blobRadius = 56.0 * _easeOutBack(blobT);
      final fadeOut = (1.0 - ((progress - 0.7) / 0.3).clamp(0.0, 1.0));
      final blobOpacity = fadeOut;

      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppThemeColors.primaryAccent.withValues(alpha: 0.4 * blobOpacity),
            AppThemeColors.primaryAccent.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: center, radius: blobRadius * 2),
        );
      canvas.drawCircle(center, blobRadius * 2, glowPaint);

      final blobPath = _createBlobPath(center, blobRadius, progress);
      final blobPaint = Paint()
        ..color = AppThemeColors.primaryAccent.withValues(alpha: blobOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(blobPath, blobPaint);

      final shimmerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25 * blobOpacity)
        ..style = PaintingStyle.fill;
      final shimmerPath = _createBlobPath(
        center + const Offset(-8, -10),
        blobRadius * 0.5,
        progress,
      );
      canvas.drawPath(shimmerPath, shimmerPaint);
    }

    // ── Checkmark ────────────────────────────────────────────────────────
    if (checkT > 0) {
      final fadeOut = (1.0 - ((progress - 0.7) / 0.3).clamp(0.0, 1.0));
      final checkOpacity = checkT * fadeOut;

      final checkPaint = Paint()
        ..color = Colors.white.withValues(alpha: checkOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final checkSize = 22.0;
      final path = Path()
        ..moveTo(center.dx - checkSize * 0.6, center.dy)
        ..lineTo(
          center.dx - checkSize * 0.1,
          center.dy + checkSize * 0.5,
        );

      final secondStrokeProgress = ((checkT - 0.4) / 0.6).clamp(0.0, 1.0);
      if (secondStrokeProgress > 0) {
        final end = Offset(
          center.dx + checkSize * 0.7,
          center.dy - checkSize * 0.4,
        );
        final mid = Offset(
          center.dx - checkSize * 0.1,
          center.dy + checkSize * 0.5,
        );
        path.lineTo(
          mid.dx + (end.dx - mid.dx) * secondStrokeProgress,
          mid.dy + (end.dy - mid.dy) * secondStrokeProgress,
        );
      }

      canvas.drawPath(path, checkPaint);
    }

    // ── Sparkle particles ────────────────────────────────────────────────
    final sparkleOpacity = sparkleT * (1.0 - ((progress - 0.7) / 0.3).clamp(0.0, 1.0));
    if (sparkleOpacity > 0) {
      final sparklePaint = Paint()..style = PaintingStyle.fill;
      final rng = math.Random(42);
      for (var i = 0; i < 12; i++) {
        final angle = (i / 12) * 2 * math.pi + progress * 0.5;
        final dist = 70.0 + rng.nextDouble() * 40.0 * progress;
        final sparkleCenter = Offset(
          center.dx + math.cos(angle) * dist,
          center.dy + math.sin(angle) * dist,
        );
        final sparkleSize = 2.0 + rng.nextDouble() * 2.0;
        sparklePaint.color = [
          AppThemeColors.primaryAccent,
          AppThemeColors.accent,
          Colors.white,
        ][i % 3].withValues(
          alpha: sparkleOpacity * (0.5 + rng.nextDouble() * 0.5),
        );
        canvas.drawCircle(sparkleCenter, sparkleSize, sparklePaint);
      }
    }
  }

  Path _createBlobPath(Offset center, double radius, double t) {
    final path = Path();
    final segments = 36;
    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      final wobble = 1.0 +
          0.08 * math.sin(angle * 3 + t * 6) +
          0.04 * math.cos(angle * 5 - t * 4);
      final r = radius * wobble;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  @override
  bool shouldRepaint(covariant _LiquidRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
