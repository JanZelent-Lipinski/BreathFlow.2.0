import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import '../../core/recommendation_service.dart';
import '../profiles/profile_service.dart';
import '../session/session_service.dart';
import 'breath_battery.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profile = profileService.activeProfile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ambient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.oceanGradient,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getGreeting()},',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            ),
                          ).animate().fadeIn(duration: 600.ms),
                          const SizedBox(height: 4),
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        ],
                      ),
                      // Profile Avatar
                      InkWell(
                        onTap: () => context.push('/profile-management'),
                        borderRadius: BorderRadius.circular(24),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.tealLight,
                          child: Text(
                            profile.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Breath Battery
                  Center(
                    child: Consumer<SessionService>(
                      builder: (context, sessionService, _) => BreathBattery(
                        completedSessions: sessionService.todaySessionCount,
                        dailyGoal: 3,
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),

                  const SizedBox(height: 48),

                  // Quick Actions
                  LiquidGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Quick Start',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.mistWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Consumer2<ProfileService, SessionService>(
                          builder: (context, profileService, sessionService, _) {
                            final recommendationService = RecommendationService(sessionService);
                            final recommended = recommendationService.getRecommendation(
                              profile: profile,
                            );
                            final reason = recommendationService.getRecommendationReason(
                              profile: profile,
                              method: recommended,
                            );

                            return _QuickActionButton(
                              icon: Icons.self_improvement,
                              title: 'Recommended Session',
                              subtitle: '${recommended.name} • ${recommended.durationMinutes} min • $reason',
                              onTap: () {
                                context.push('/session', extra: recommended);
                              },
                            );
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _QuickActionButton(
                          icon: Icons.timer,
                          title: 'CP Test',
                          subtitle: 'Control Pause measurement',
                          onTap: () {
                            context.push('/cp-test');
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tealLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.tealLight, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.mistWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.mistWhite.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mistWhite.withOpacity(0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
