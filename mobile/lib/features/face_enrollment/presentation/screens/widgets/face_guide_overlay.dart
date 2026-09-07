import 'package:flutter/material.dart';

import 'face_guide_painter.dart';

/// A full-screen overlay that draws a semi-transparent dim layer with a
/// cutout shaped like the [FaceGuidePainter] head+shoulders outline, plus
/// the guide outline itself centered inside.
///
/// Wraps everything in [IgnorePointer] so it never blocks shutter/flash.
/// Sized via [LayoutBuilder] — no [MediaQuery] dependency.
class FaceGuideOverlay extends StatelessWidget {
  /// Current alignment state — drives default colour if [strokeColor] is null.
  final FaceGuideState guideState;

  /// Override the guide stroke colour. When null, colour is derived from
  /// [guideState]: grey for neutral, amber for warning, green for ready.
  final Color? strokeColor;

  /// Width of the guide outline strokes.
  final double strokeWidth;

  /// Fraction of the shorter available dimension used for the guide height.
  final double sizeFraction;

  const FaceGuideOverlay({
    super.key,
    this.guideState = FaceGuideState.neutral,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.sizeFraction = 0.78,
  });

  Color _resolveColor() {
    if (strokeColor != null) return strokeColor!;
    switch (guideState) {
      case FaceGuideState.neutral:
        return Colors.white54;
      case FaceGuideState.warning:
        return const Color(0xFFFFA726); // amber
      case FaceGuideState.ready:
        return const Color(0xFF66BB6A); // green
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        if (maxW.isInfinite || maxH.isInfinite) {
          return const SizedBox.shrink();
        }

        final guideH = (maxW < maxH ? maxW : maxH) * sizeFraction;
        // 300:400 = 3:4 aspect ratio of the local coordinate box.
        final guideW = guideH * 0.75;
        final color = _resolveColor();

        return Stack(
          children: [
            // ── Dim cutout — full Stack size ──────────────────────────────
            Positioned.fill(
              child: CustomPaint(
                painter: _DimCutoutPainter(
                  guideSize: Size(guideW, guideH),
                  color: Colors.black54,
                ),
              ),
            ),

            // ── Guide outline — centered ──────────────────────────────────
            Center(
              child: SizedBox(
                width: guideW,
                height: guideH,
                child: CustomPaint(
                  painter: FaceGuidePainter(
                    strokeColor: color,
                    strokeWidth: strokeWidth,
                    guideState: guideState,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Draws a full-size semi-transparent fill with the head+shoulders
/// path subtracted — the "cutout" dim layer.
class _DimCutoutPainter extends CustomPainter {
  final Size guideSize;
  final Color color;

  const _DimCutoutPainter({required this.guideSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // The full canvas rect.
    final full = Path()..addRect(Offset.zero & size);

    // Build the guide path in a coordinate space that matches the centered
    // guide rectangle, then subtract it from the full rect.
    final guide = _buildGuidePath(guideSize, size);

    final cutout = Path.combine(PathOperation.difference, full, guide);

    canvas.drawPath(
      cutout,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  /// Build the same head+shoulders path as [FaceGuidePainter], but mapped
  /// into the centered [guideSize] within the overall canvas [canvasSize].
  Path _buildGuidePath(Size guide, Size canvasSize) {
    // Mirror the scaling logic from FaceGuidePainter: 300×400 local box
    // scaled to fit [guide], then offset to center within [canvasSize].
    const localW = 300.0;
    const localH = 400.0;

    final sx = guide.width / localW;
    final sy = guide.height / localH;
    final s = sx < sy ? sx : sy;

    // The guide rect centered in the canvas.
    final ox = (canvasSize.width - localW * s) / 2;
    final oy = (canvasSize.height - localH * s) / 2;

    // Scale helper (same as FaceGuidePainter).
    double px(double x) => ox + x * s;
    double py(double y) => oy + y * s;

    final path = Path();

    // ── Head ────────────────────────────────────────────────────────────
    // Hairline
    path
      ..moveTo(px(100), py(115))
      ..cubicTo(px(100), py(60), px(200), py(60), px(200), py(115));
    // Right side
    path
      ..moveTo(px(200), py(115))
      ..cubicTo(px(205), py(145), px(200), py(175), px(185), py(210))
      ..cubicTo(px(172), py(240), px(158), py(258), px(150), py(268));
    // Left side
    path
      ..moveTo(px(100), py(115))
      ..cubicTo(px(95), py(145), px(100), py(175), px(115), py(210))
      ..cubicTo(px(128), py(240), px(142), py(258), px(150), py(268));

    // ── Eyes ────────────────────────────────────────────────────────────
    for (final cx in [125.0, 175.0]) {
      path
        ..moveTo(px(cx - 14), py(155))
        ..cubicTo(px(cx - 7), py(147), px(cx + 7), py(147), px(cx + 14), py(155))
        ..cubicTo(px(cx + 7), py(161), px(cx - 7), py(161), px(cx - 14), py(155));
    }

    // ── Nose ────────────────────────────────────────────────────────────
    path
      ..moveTo(px(150), py(148))
      ..cubicTo(px(148), py(168), px(144), py(192), px(140), py(200))
      ..cubicTo(px(142), py(204), px(158), py(204), px(160), py(200))
      ..cubicTo(px(158), py(196), px(155), py(194), px(152), py(196));

    // ── Mouth ───────────────────────────────────────────────────────────
    path
      ..moveTo(px(128), py(232))
      ..cubicTo(px(138), py(237), px(162), py(237), px(172), py(232));

    // ── Neck & shoulders ────────────────────────────────────────────────
    path
      ..moveTo(px(137), py(268))
      ..cubicTo(px(135), py(285), px(132), py(300), px(120), py(310))
      ..cubicTo(px(95), py(325), px(55), py(338), px(20), py(345))
      ..cubicTo(px(10), py(347), px(-5), py(348), px(-15), py(348));
    path
      ..moveTo(px(163), py(268))
      ..cubicTo(px(165), py(285), px(168), py(300), px(180), py(310))
      ..cubicTo(px(205), py(325), px(245), py(338), px(280), py(345))
      ..cubicTo(px(290), py(347), px(305), py(348), px(315), py(348));

    return path;
  }

  @override
  bool shouldRepaint(_DimCutoutPainter old) {
    return old.guideSize != guideSize || old.color != color;
  }
}
