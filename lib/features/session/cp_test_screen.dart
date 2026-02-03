import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import 'session_service.dart';

class CpTestScreen extends StatefulWidget {
  const CpTestScreen({super.key});

  @override
  State<CpTestScreen> createState() => _CpTestScreenState();
}

class _CpTestScreenState extends State<CpTestScreen> {
  bool _isRunning = false;
  bool _isComplete = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTest() {
    setState(() {
      _isRunning = true;
      _seconds = 0;
    });

    HapticFeedback.mediumImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds++);
    });
  }

  void _stopTest() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isComplete = true;
    });

    HapticFeedback.heavyImpact();

    // Save CP score
    final sessionService = context.read<SessionService>();
    await sessionService.saveSession(
      methodType: 'cp_test',
      durationSeconds: _seconds,
      cpScore: _seconds.toDouble(),
    );
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _seconds = 0;
    });
  }

  String get _resultMessage {
    if (_seconds < 10) return 'Keep practicing';
    if (_seconds < 20) return 'Good progress';
    if (_seconds < 40) return 'Excellent!';
    return 'Outstanding!';
  }

  Color get _resultColor {
    if (_seconds < 10) return AppColors.coralGlow;
    if (_seconds < 20) return const Color(0xFFFFD54F);
    if (_seconds < 40) return AppColors.tealLight;
    return const Color(0xFF66BB6A);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.oceanGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.mistWhite),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'CP Test',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mistWhite,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const Spacer(),

                // Instructions or Results
                if (!_isRunning && !_isComplete) ...[
                  LiquidGlassContainer(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 64,
                          color: AppColors.tealLight,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Control Pause Test',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mistWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '1. Breathe normally\n2. Exhale gently\n3. Hold your breath\n4. Stop when you feel the first urge to breathe',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mistWhite.withOpacity(0.8),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                ],

                // Timer
                if (_isRunning) ...[
                  Text(
                    '$_seconds',
                    style: const TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.w300,
                      color: AppColors.mistWhite,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2000.ms, color: AppColors.tealLight.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'seconds',
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.mistWhite,
                    ),
                  ),
                ],

                // Results
                if (_isComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: _resultColor,
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 24),
                        Text(
                          '$_seconds seconds',
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w700,
                            color: _resultColor,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        Text(
                          _resultMessage,
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppColors.mistWhite,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Action Button
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      if (!_isRunning && !_isComplete)
                        ElevatedButton(
                          onPressed: _startTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start Test',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      
                      if (_isRunning)
                        ElevatedButton(
                          onPressed: _stopTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.coralGlow,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Stop',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      
                      if (_isComplete) ...[
                        ElevatedButton(
                          onPressed: _reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Test Again',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Done',
                            style: TextStyle(color: AppColors.mistWhite),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
