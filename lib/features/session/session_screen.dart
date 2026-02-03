import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../data/models/breathing_method.dart';
import 'session_service.dart';

class SessionScreen extends StatefulWidget {
  final BreathingMethod method;

  const SessionScreen({super.key, required this.method});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  Timer? _phaseTimer;
  Timer? _sessionTimer;
  
  int _currentPhaseIndex = 0;
  int _cycleCount = 0;
  int _elapsedSeconds = 0;
  bool _isPaused = false;
  
  BreathPhase get _currentPhase => widget.method.pattern[_currentPhaseIndex];
  int _phaseSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentPhase.durationSeconds),
    );
    
    _phaseSecondsRemaining = _currentPhase.durationSeconds;
    _startSession();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    _startPhase();
    
    // Session timer
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => _elapsedSeconds++);
        
        // Auto-complete after duration
        if (_elapsedSeconds >= widget.method.durationMinutes * 60) {
          _completeSession();
        }
      }
    });
  }

  void _startPhase() {
    final phase = _currentPhase;
    _phaseSecondsRemaining = phase.durationSeconds;
    
    // Animate based on phase type
    _breathController.duration = Duration(seconds: phase.durationSeconds);
    
    if (phase.type == 'inhale') {
      _breathController.forward(from: 0);
      _triggerHaptic(HapticFeedback.lightImpact);
    } else if (phase.type == 'exhale') {
      _breathController.reverse(from: 1);
      _triggerHaptic(HapticFeedback.lightImpact);
    } else if (phase.type == 'hold') {
      // Hold at current position
      _triggerHaptic(HapticFeedback.mediumImpact);
    } else if (phase.type == 'rest') {
      _breathController.animateTo(0.1); // Almost empty
    }
    
    // Phase countdown
    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => _phaseSecondsRemaining--);
        
        if (_phaseSecondsRemaining <= 0) {
          timer.cancel();
          _nextPhase();
        }
      }
    });
  }

  void _nextPhase() {
    setState(() {
      _currentPhaseIndex++;
      if (_currentPhaseIndex >= widget.method.pattern.length) {
        _currentPhaseIndex = 0;
        _cycleCount++;
      }
    });
    _startPhase();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      _breathController.stop();
    } else {
      _startPhase();
    }
  }

  void _completeSession() async {
    _sessionTimer?.cancel();
    _phaseTimer?.cancel();
    
    // Save session to history
    final sessionService = context.read<SessionService>();
    await sessionService.saveSession(
      methodType: widget.method.id,
      durationSeconds: _elapsedSeconds,
    );
    
    if (mounted) {
      context.pop();
    }
  }

  void _triggerHaptic(Function haptic) {
    try {
      haptic();
    } catch (e) {
      // Haptics not available on this platform
    }
  }

  String get _phaseLabel {
    switch (_currentPhase.type) {
      case 'inhale':
        return 'Inhale';
      case 'exhale':
        return 'Exhale';
      case 'hold':
        return 'Hold';
      case 'rest':
        return 'Rest';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;

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

          // Liquid Lung Animation
          Center(
            child: AnimatedBuilder(
              animation: _breathController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(300, 400),
                  painter: _LiquidLungPainter(
                    progress: _breathController.value,
                    phaseType: _currentPhase.type,
                  ),
                );
              },
            ),
          ),

          // UI Overlay
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
                      Text(
                        widget.method.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mistWhite,
                        ),
                      ),
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mistWhite.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Phase Label & Timer
                Column(
                  children: [
                    Text(
                      _phaseLabel,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: AppColors.mistWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_phaseSecondsRemaining}s',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mistWhite,
                      ),
                    ),
                    if (_currentPhase.instruction != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _currentPhase.instruction!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.mistWhite.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 48),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pause/Play
                    IconButton(
                      icon: Icon(
                        _isPaused ? Icons.play_arrow : Icons.pause,
                        size: 48,
                        color: AppColors.mistWhite,
                      ),
                      onPressed: _togglePause,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // End Session
                TextButton(
                  onPressed: _completeSession,
                  child: Text(
                    'End Session',
                    style: TextStyle(
                      color: AppColors.coralGlow,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidLungPainter extends CustomPainter {
  final double progress;
  final String phaseType;

  _LiquidLungPainter({
    required this.progress,
    required this.phaseType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Container outline
    final outlinePaint = Paint()
      ..color = AppColors.glassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final containerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        const Radius.circular(40),
      ));

    canvas.drawPath(containerPath, outlinePaint);

    // Liquid fill
    final liquidHeight = size.height * progress;
    final liquidTop = size.height - liquidHeight;

    // Wave path
    final wavePath = Path();
    final waveAmplitude = 12.0;
    final waveFrequency = 1.5;

    wavePath.moveTo(0, liquidTop);

    for (double x = 0; x <= size.width; x += 2) {
      final y = liquidTop +
          math.sin((x / size.width * waveFrequency * math.pi * 2)) * waveAmplitude;
      wavePath.lineTo(x, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    // Clip to container
    canvas.save();
    canvas.clipPath(containerPath);

    // Gradient based on phase
    Color topColor, bottomColor;
    if (phaseType == 'inhale') {
      topColor = AppColors.tealLight.withOpacity(0.4);
      bottomColor = AppColors.tealDark.withOpacity(0.9);
    } else if (phaseType == 'exhale') {
      topColor = const Color(0xFF7E57C2).withOpacity(0.4);
      bottomColor = const Color(0xFF512DA8).withOpacity(0.9);
    } else {
      topColor = AppColors.tealLight.withOpacity(0.3);
      bottomColor = AppColors.tealLight.withOpacity(0.7);
    }

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ).createShader(Rect.fromLTWH(0, liquidTop, size.width, liquidHeight));

    canvas.drawPath(wavePath, liquidPaint);
    canvas.restore();

    // Glow effect
    final glowPaint = Paint()
      ..color = AppColors.tealLight.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(containerPath, glowPaint);
  }

  @override
  bool shouldRepaint(_LiquidLungPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phaseType != phaseType;
  }
}
