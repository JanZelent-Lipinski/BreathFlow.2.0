import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import '../session/session_service.dart';
import '../../data/models/breathing_method.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _getMethodName(String methodId) {
    if (methodId == 'cp_test') return 'CP Test';
    try {
      return BreathingMethods.all.firstWhere((m) => m.id == methodId).name;
    } catch (e) {
      return methodId;
    }
  }

  IconData _getMethodIcon(String methodId) {
    if (methodId == 'cp_test') return Icons.timer;
    try {
      final method = BreathingMethods.all.firstWhere((m) => m.id == methodId);
      switch (method.iconName) {
        case 'air':
          return Icons.air;
        case 'crop_square':
          return Icons.crop_square;
        case 'waves':
          return Icons.waves;
        case 'spa':
          return Icons.spa;
        case 'bolt':
          return Icons.bolt;
        default:
          return Icons.self_improvement;
      }
    } catch (e) {
      return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionService = context.watch<SessionService>();
    final sessions = sessionService.sessions;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.oceanGradient,
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Your breathing journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mistWhite.withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                ),

                // Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LiquidGlassContainer(
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              label: 'Total',
                              value: '${sessionService.totalSessions}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.glassBorder,
                          ),
                          Expanded(
                            child: _StatItem(
                              label: 'Today',
                              value: '${sessionService.todaySessionCount}',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.glassBorder,
                          ),
                          Expanded(
                            child: _StatItem(
                              label: 'Latest CP',
                              value: sessionService.latestCpScore?.toStringAsFixed(0) ?? '-',
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Session List
                if (sessions.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: AppColors.mistWhite.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sessions yet',
                            style: TextStyle(
                              color: AppColors.mistWhite.withOpacity(0.6),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a breathing session to see your history',
                            style: TextStyle(
                              color: AppColors.mistWhite.withOpacity(0.4),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = sessions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LiquidGlassContainer(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.tealLight.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getMethodIcon(session.methodType),
                                      color: AppColors.tealLight,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getMethodName(session.methodType),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.mistWhite,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, y • h:mm a').format(session.date),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.mistWhite.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (session.cpScore != null)
                                        Text(
                                          '${session.cpScore!.toStringAsFixed(0)}s',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.tealLight,
                                          ),
                                        )
                                      else
                                        Text(
                                          '${(session.durationSeconds / 60).floor()} min',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.mistWhite.withOpacity(0.6),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate(delay: Duration(milliseconds: 100 * index))
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: 0.1, end: 0),
                          );
                        },
                        childCount: sessions.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.mistWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mistWhite.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
