import 'package:flutter/material.dart';

/// The alignment states the guide can represent.
enum FaceGuideState { neutral, warning, ready }

/// A minimal line-art head+shoulders silhouette for face-positioning guidance.
///
/// All geometry is defined in a fixed 300×400 local coordinate box and
/// scale-translated to the actual [size] at paint time so proportions hold
/// on any screen.
class FaceGuidePainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final FaceGuideState guideState;

  const FaceGuidePainter({
    this.strokeColor = Colors.white,
    this.strokeWidth = 2.0,
    this.guideState = FaceGuideState.neutral,
  });

  // ── Fixed local coordinate box ───────────────────────────────────────────
  static const double _localW = 300;
  static const double _localH = 400;

  @override
  void paint(Canvas canvas, Size size) {
    // Scale from local 300×400 box into actual size, preserving aspect ratio.
    final sx = size.width / _localW;
    final sy = size.height / _localH;
    final s = sx < sy ? sx : sy; // fit inside

    final ox = (size.width - _localW * s) / 2;
    final oy = (size.height - _localH * s) / 2;

    canvas
      ..translate(ox, oy)
      ..scale(s);

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawHead(canvas, paint);
    _drawEyes(canvas, paint);
    _drawNose(canvas, paint);
    _drawMouth(canvas, paint);
    _drawNeckAndShoulders(canvas, paint);
  }

  // ── Head (hairline + jaw) ────────────────────────────────────────────────

  void _drawHead(Canvas canvas, Paint paint) {
    final head = Path();

    // Hairline — gentle arc across the top of the skull.
    head
      ..moveTo(100, 115)
      ..cubicTo(100, 60, 200, 60, 200, 115);

    // Right side of face — cheekbone out slightly, then taper to chin.
    head
      ..moveTo(200, 115)
      ..cubicTo(205, 145, 200, 175, 185, 210)
      ..cubicTo(172, 240, 158, 258, 150, 268);

    // Left side — mirror.
    head
      ..moveTo(100, 115)
      ..cubicTo(95, 145, 100, 175, 115, 210)
      ..cubicTo(128, 240, 142, 258, 150, 268);

    canvas.drawPath(head, paint);
  }

  // ── Eyes ──────────────────────────────────────────────────────────────────

  void _drawEyes(Canvas canvas, Paint paint) {
    final eyePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.85
      ..strokeCap = StrokeCap.round;

    // Each eye is a simple almond arc (no fill).
    for (final cx in [125.0, 175.0]) {
      final eye = Path()
        ..moveTo(cx - 14, 155)
        ..cubicTo(cx - 7, 147, cx + 7, 147, cx + 14, 155)
        ..cubicTo(cx + 7, 161, cx - 7, 161, cx - 14, 155);

      canvas.drawPath(eye, eyePaint);
    }
  }

  // ── Nose ──────────────────────────────────────────────────────────────────

  void _drawNose(Canvas canvas, Paint paint) {
    final nosePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.7
      ..strokeCap = StrokeCap.round;

    final nose = Path()
      // bridge — subtle S-curve from between the brows to the tip
      ..moveTo(150, 148)
      ..cubicTo(148, 168, 144, 192, 140, 200)
      // tip curve
      ..cubicTo(142, 204, 158, 204, 160, 200)
      // right nostril hint
      ..cubicTo(158, 196, 155, 194, 152, 196);

    canvas.drawPath(nose, nosePaint);
  }

  // ── Mouth ─────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, Paint paint) {
    final mouthPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.75
      ..strokeCap = StrokeCap.round;

    // Closed mouth — slight downward curve at corners.
    final mouth = Path()
      ..moveTo(128, 232)
      ..cubicTo(138, 237, 162, 237, 172, 232);

    canvas.drawPath(mouth, mouthPaint);
  }

  // ── Neck & shoulders ─────────────────────────────────────────────────────

  void _drawNeckAndShoulders(Canvas canvas, Paint paint) {
    final neck = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.9
      ..strokeCap = StrokeCap.round;

    final path = Path()
      // left neck
      ..moveTo(137, 268)
      ..cubicTo(135, 285, 132, 300, 120, 310)
      // left shoulder — broad outward sweep
      ..cubicTo(95, 325, 55, 338, 20, 345)
      // left shoulder taper off-screen
      ..cubicTo(10, 347, -5, 348, -15, 348);

    path
      // right neck
      ..moveTo(163, 268)
      ..cubicTo(165, 285, 168, 300, 180, 310)
      // right shoulder
      ..cubicTo(205, 325, 245, 338, 280, 345)
      // right shoulder taper
      ..cubicTo(290, 347, 305, 348, 315, 348);

    canvas.drawPath(path, neck);
  }

  @override
  bool shouldRepaint(FaceGuidePainter old) {
    return old.strokeColor != strokeColor ||
        old.strokeWidth != strokeWidth ||
        old.guideState != guideState;
  }
}
