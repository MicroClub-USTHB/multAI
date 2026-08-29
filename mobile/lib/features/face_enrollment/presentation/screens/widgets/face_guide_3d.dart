import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:multai_mobile/core/theme/app_theme_colors.dart';
import '../../../domain/entities/face_photo_entity.dart';

class FaceGuide3D extends StatefulWidget {
  final FacePhotoType type;

  const FaceGuide3D({super.key, required this.type});

  @override
  State<FaceGuide3D> createState() => _FaceGuide3DState();
}

class _FaceGuide3DState extends State<FaceGuide3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late Animation<double> _yawAnim;
  late Animation<double> _pitchAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _yawAnim = Tween(begin: 0.0, end: widget.type.yaw).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic),
    );
    _pitchAnim = Tween(begin: 0.0, end: widget.type.pitch).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic),
    );
    _animCtrl.forward();
  }

  @override
  void didUpdateWidget(FaceGuide3D old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type) {
      final cy = _yawAnim.value;
      final cp = _pitchAnim.value;
      _yawAnim = Tween(begin: cy, end: widget.type.yaw).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic),
      );
      _pitchAnim = Tween(begin: cp, end: widget.type.pitch).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic),
      );
      _animCtrl..reset()..forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, _) => CustomPaint(
        painter: _HeadPainter(
          yaw: _yawAnim.value,
          pitch: _pitchAnim.value,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HeadPainter extends CustomPainter {
  final double yaw;
  final double pitch;

  _HeadPainter({required this.yaw, required this.pitch});

  // ── projection ──────────────────────────────────────────────────────────
  double _px(double x, double z) => x + z * math.sin(yaw);
  double _py(double y, double z) => y - z * math.sin(pitch);

  // ── colours ─────────────────────────────────────────────────────────────
  static const _skinBase = Color(0xFF443850);
  static const _skinLight = Color(0xFF5C4F70);
  static const _skinDark = Color(0xFF2E2540);
  static const _line = Color(0xFF3A3250);
  static const _accent = AppThemeColors.primaryAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = math.min(size.width, size.height) / 280;

    canvas
      ..translate(cx, cy)
      ..scale(s);

    _drawNeck(canvas);
    _drawHeadShape(canvas);
    _drawEars(canvas);
    _drawFeatures(canvas);
    _drawWireframe(canvas);
    _drawScanLines(canvas);
  }

  // ── neck ────────────────────────────────────────────────────────────────
  void _drawNeck(Canvas canvas) {
    final p = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skinDark, Color(0xFF221C30)],
      ).createShader(Rect.fromLTWH(-28, 70, 56, 60));

    final path = Path()
      ..moveTo(_px(-24, 0), 70)
      ..quadraticBezierTo(_px(-18, -3), 88, _px(-16, 0), 120)
      ..lineTo(_px(16, 0), 120)
      ..quadraticBezierTo(_px(18, -3), 88, _px(24, 0), 70)
      ..close();

    canvas.drawPath(path, p);
  }

  // ── head outline ────────────────────────────────────────────────────────
  void _drawHeadShape(Canvas canvas) {
    // smooth egg-shaped head via cubic beziers
    const w = 64.0; // half-width
    const h = 78.0; // half-height
    const top = -h - 2;

    final path = Path()
      // right side top → cheek
      ..moveTo(0, top)
      ..cubicTo(
        _px(w * 0.55, 12), top + h * 0.12,
        _px(w * 0.95, 8),  top + h * 0.35,
        _px(w * 0.88, 0),  top + h * 0.6,
      )
      // right cheek → chin
      ..cubicTo(
        _px(w * 0.75, -4), top + h * 0.88,
        _px(w * 0.35, -4), top + h,
        0,                  top + h + 6,
      )
      // chin → left cheek
      ..cubicTo(
        _px(-w * 0.35, -4), top + h,
        _px(-w * 0.75, -4), top + h * 0.88,
        _px(-w * 0.88, 0),  top + h * 0.6,
      )
      // left cheek → top
      ..cubicTo(
        _px(-w * 0.95, 8), top + h * 0.35,
        _px(-w * 0.55, 12), top + h * 0.12,
        0,                  top,
      );

    // fill gradient
    final fill = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.08 + yaw * 0.25, -0.15 - pitch * 0.15),
        radius: 1.05,
        colors: const [_skinLight, _skinBase, _skinDark],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: w * 2, height: h * 2.2));

    canvas
      ..drawPath(path, fill)
      // outline
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = _line.withValues(alpha: 0.5),
      );

    // forehead highlight
    final hl = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.05 + yaw * 0.2, -0.5 - pitch * 0.15),
        radius: 0.55,
        colors: [
          _skinLight.withValues(alpha: 0.35),
          _skinLight.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(center: Offset(-5, -55), width: 70, height: 50));

    canvas.drawOval(Rect.fromCenter(center: Offset(-5, -55), width: 70, height: 50), hl);
  }

  // ── ears ────────────────────────────────────────────────────────────────
  void _drawEars(Canvas canvas) {
    final earPaint = Paint()
      ..color = _skinBase
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = _line.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    for (final side in [-1.0, 1.0]) {
      final ex = _px(side * 58, 4);
      final ey = _py(-8, 4);

      final ear = Path()
        ..moveTo(ex, ey - 14)
        ..cubicTo(
          ex + side * 10, ey - 10,
          ex + side * 11, ey + 2,
          ex + side * 10, ey + 12,
        )
        ..cubicTo(
          ex + side * 8, ey + 14,
          ex + side * 2, ey + 12,
          ex, ey + 10,
        )
        ..cubicTo(
          ex - side * 2, ey + 4,
          ex - side * 2, ey - 6,
          ex, ey - 14,
        )
        ..close();

      canvas
        ..drawPath(ear, earPaint)
        ..drawPath(ear, outline);
    }
  }

  // ── facial features ─────────────────────────────────────────────────────
  void _drawFeatures(Canvas canvas) {
    _drawEyes(canvas);
    _drawBrows(canvas);
    _drawNose(canvas);
    _drawMouth(canvas);
  }

  void _drawEyes(Canvas canvas) {
    final whitePaint = Paint()..color = const Color(0xFFE0DCE8);
    final irisPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF5A4E6A), Color(0xFF3A3048)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 4.5))
      ..style = PaintingStyle.fill;
    final pupilPaint = Paint()..color = const Color(0xFF14101C);
    final lidPaint = Paint()
      ..color = _line.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    final socketPaint = Paint()
      ..color = _skinDark.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (final side in [-1.0, 1.0]) {
      final ex = _px(side * 20, 18);
      final ey = _py(-16, 18);

      // socket shadow
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ex, ey + 2), width: 22, height: 12),
        socketPaint,
      );

      // eye white — almond shape
      final eye = Path()
        ..moveTo(ex - 9, ey)
        ..quadraticBezierTo(ex, ey - 5.5, ex + 9, ey)
        ..quadraticBezierTo(ex, ey + 4.5, ex - 9, ey);

      canvas
        ..drawPath(eye, whitePaint)
        ..drawPath(eye, lidPaint);

      // iris + pupil
      final ix = ex + math.sin(yaw) * 2;
      final iy = ey + math.sin(pitch) * 1;
      canvas
        ..drawCircle(Offset(ix, iy), 4, irisPaint)
        ..drawCircle(Offset(ix, iy), 1.8, pupilPaint)
        // highlight
        ..drawCircle(
          Offset(ix - 1.2, iy - 1.3),
          1.0,
          Paint()..color = Colors.white.withValues(alpha: 0.55),
        );
    }
  }

  void _drawBrows(Canvas canvas) {
    final p = Paint()
      ..color = _line.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (final side in [-1.0, 1.0]) {
      final bx = _px(side * 20, 16);
      final by = _py(-28, 16);

      canvas.drawPath(
        Path()
          ..moveTo(bx - 9 * side, by + 1)
          ..quadraticBezierTo(bx, by - 3, bx + 9 * side, by + 2),
        p,
      );
    }
  }

  void _drawNose(Canvas canvas) {
    final bridgePaint = Paint()
      ..color = _line.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    final tipPaint = Paint()
      ..color = _skinLight.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final nostrilPaint = Paint()
      ..color = _skinDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final bx = _px(0, 22);
    final by = _py(-10, 22);
    final tx = _px(0, 28);
    final ty = _py(10, 28);

    // bridge
    canvas.drawLine(Offset(bx, by), Offset(tx, ty), bridgePaint);

    // shadow on one side
    final shadowSide = yaw > 0 ? 1.0 : -1.0;
    canvas.drawLine(
      Offset(bx + shadowSide * 1.5, by),
      Offset(tx + shadowSide * 1.5, ty),
      Paint()
        ..color = _skinDark.withValues(alpha: 0.25)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // tip glow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tx, ty + 2), width: 8, height: 5),
      tipPaint,
    );

    // nostrils
    for (final s in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(_px(s * 5, 28), _py(13, 28)), width: 3.5, height: 2),
        nostrilPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas) {
    final lipPaint = Paint()
      ..color = _skinBase.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = _line.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final mx = _px(0, 26);
    final my = _py(32, 26);
    final mw = 18.0 - yaw.abs() * 6;

    // upper lip
    final upper = Path()
      ..moveTo(mx - mw, my)
      ..quadraticBezierTo(mx - mw * 0.3, my - 3, mx, my - 3.5)
      ..quadraticBezierTo(mx + mw * 0.3, my - 3, mx + mw, my);

    // lower lip
    final lower = Path()
      ..moveTo(mx - mw, my)
      ..quadraticBezierTo(mx, my + 5.5, mx + mw, my);

    canvas
      ..drawPath(upper, lipPaint)
      ..drawPath(lower, lipPaint)
      ..drawLine(Offset(mx - mw, my), Offset(mx + mw, my), linePaint);
  }

  // ── wireframe mesh ──────────────────────────────────────────────────────
  void _drawWireframe(Canvas canvas) {
    final p = Paint()
      ..color = _accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.35;

    // horizontal rings
    for (var i = -4; i <= 5; i++) {
      final y = i * 16.0;
      final path = Path();
      for (var j = -5; j <= 5; j++) {
        final x = j * 13.0;
        // bulge outward for 3D feel
        final z = (1.0 - (x * x / 6000 + y * y / 8000)) * 14;
        final pt = Offset(_px(x, z), _py(y, z));
        j == -5 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, p);
    }

    // vertical meridians
    for (var j = -5; j <= 5; j++) {
      final x = j * 13.0;
      final path = Path();
      for (var i = -4; i <= 5; i++) {
        final y = i * 16.0;
        final z = (1.0 - (x * x / 6000 + y * y / 8000)) * 14;
        final pt = Offset(_px(x, z), _py(y, z));
        i == -4 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  // ── scan line effect ────────────────────────────────────────────────────
  void _drawScanLines(Canvas canvas) {
    final p = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _accent.withValues(alpha: 0.0),
          _accent.withValues(alpha: 0.06),
          _accent.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: 160, height: 220));

    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 160, height: 220),
      p,
    );
  }

  @override
  bool shouldRepaint(_HeadPainter o) => o.yaw != yaw || o.pitch != pitch;
}
