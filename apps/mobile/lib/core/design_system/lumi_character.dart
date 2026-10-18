import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lumi_tokens.dart';
import '../../l10n/l10n.dart';

enum LumiMood { calm, happy, encouraging }

/// Люми — светлячок-помощник. Нарисован кодом, без сторонних иллюстраций,
/// чтобы персонаж был полностью оригинальным и лёгким.
class LumiCharacter extends StatefulWidget {
  const LumiCharacter({super.key, this.size = 96, this.mood = LumiMood.calm});

  final double size;
  final LumiMood mood;

  @override
  State<LumiCharacter> createState() => _LumiCharacterState();
}

class _LumiCharacterState extends State<LumiCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    // В тестах и при «уменьшении движения» персонаж не парит.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduceMotion =
          MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (!reduceMotion) _float.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.lumiName,
      image: true,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -6 * Curves.easeInOut.transform(_float.value)),
          child: child,
        ),
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _LumiPainter(widget.mood),
        ),
      ),
    );
  }
}

class _LumiPainter extends CustomPainter {
  _LumiPainter(this.mood);

  final LumiMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s / 2, s * 0.55);
    final body = s * 0.32;

    // Свечение.
    canvas.drawCircle(
      center,
      body * 1.45,
      Paint()
        ..shader = RadialGradient(
          colors: [
            LumiColors.glow.withValues(alpha: 0.55),
            LumiColors.glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: body * 1.45)),
    );

    // Крылышки.
    final wing = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final dir in [-1, 1]) {
      canvas.save();
      canvas.translate(center.dx + dir * body * 0.75, center.dy - body * 0.85);
      canvas.rotate(dir * math.pi / 6);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: body * 0.9,
          height: body * 0.55,
        ),
        wing,
      );
      canvas.restore();
    }

    // Тело.
    canvas.drawCircle(center, body, Paint()..color = LumiColors.glow);
    canvas.drawCircle(
      center.translate(-body * 0.3, -body * 0.35),
      body * 0.25,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    // Усики.
    final antenna = Paint()
      ..color = LumiColors.ink
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final dir in [-1, 1]) {
      final start = center.translate(dir * body * 0.35, -body * 0.9);
      final end = center.translate(dir * body * 0.6, -body * 1.45);
      canvas.drawLine(start, end, antenna);
      canvas.drawCircle(end, s * 0.03, Paint()..color = LumiColors.gentleError);
    }

    // Глаза.
    final eye = Paint()..color = LumiColors.ink;
    final eyeY = center.dy - body * 0.1;
    for (final dir in [-1, 1]) {
      final eyeCenter = Offset(center.dx + dir * body * 0.35, eyeY);
      if (mood == LumiMood.happy) {
        canvas.drawArc(
          Rect.fromCircle(center: eyeCenter, radius: body * 0.14),
          math.pi,
          math.pi,
          false,
          antenna,
        );
      } else {
        canvas.drawCircle(eyeCenter, body * 0.11, eye);
      }
    }

    // Улыбка.
    final smileWidth = mood == LumiMood.calm ? 0.35 : 0.5;
    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(0, body * 0.25),
        width: body * smileWidth * 2,
        height: body * smileWidth * 1.4,
      ),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      antenna,
    );

    // Щёчки.
    final cheek = Paint()
      ..color = LumiColors.gentleError.withValues(alpha: 0.35);
    for (final dir in [-1, 1]) {
      canvas.drawCircle(
        center.translate(dir * body * 0.62, body * 0.2),
        body * 0.12,
        cheek,
      );
    }
  }

  @override
  bool shouldRepaint(_LumiPainter oldDelegate) => oldDelegate.mood != mood;
}
