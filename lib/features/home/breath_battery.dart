import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';

class BreathBattery extends StatefulWidget {
  final int completedSessions;
  final int dailyGoal;

  const BreathBattery({super.key, required this.completedSessions, required this.dailyGoal});

  @override
  State<BreathBattery> createState() => _BreathBatteryState();
}

class _BreathBatteryState extends State<BreathBattery> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.completedSessions / widget.dailyGoal;

    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BreathBatteryPainter(
              progress: progress.clamp(0.0, 1.0),
              animationValue: _controller.value,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.completedSessions}/${widget.dailyGoal}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: AppColors.mistWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sessions',
                    style: TextStyle(fontSize: 14, color: AppColors.mistWhite.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BreathBatteryPainter extends CustomPainter {
  final double progress;
  final double animationValue;

  _BreathBatteryPainter({required this.progress, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glass circle
    final glassPaint = Paint()
      ..color = AppColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 1, glassPaint);

    // Liquid fill
    final liquidHeight = radius * 2 * progress;
    final liquidTop = size.height - liquidHeight;

    // Create wave effect
    final wavePath = Path();
    final waveAmplitude = 8.0;
    final waveFrequency = 2.0;

    wavePath.moveTo(0, liquidTop);

    for (double x = 0; x <= size.width; x += 1) {
      final y =
          liquidTop +
          math.sin(
                (x / size.width * waveFrequency * math.pi * 2) + (animationValue * math.pi * 2),
              ) *
              waveAmplitude;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    // Clip to circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius - 2)));

    // Draw liquid with gradient
    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.tealLight.withOpacity(0.6), AppColors.tealDark.withOpacity(0.8)],
      ).createShader(Rect.fromLTWH(0, liquidTop, size.width, liquidHeight));

    canvas.drawPath(wavePath, liquidPaint);
    canvas.restore();

    // Inner glow
    final glowPaint = Paint()
      ..color = AppColors.tealLight.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius - 5, glowPaint);
  }

  @override
  bool shouldRepaint(_BreathBatteryPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.animationValue != animationValue;
  }
}
