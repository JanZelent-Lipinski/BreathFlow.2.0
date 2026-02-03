import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import '../../data/models/breathing_method.dart';
import '../../data/models/user_profile.dart';
import '../profiles/profile_service.dart';

class MethodsScreen extends StatelessWidget {
  const MethodsScreen({super.key});

  IconData _getIcon(String? iconName) {
    switch (iconName) {
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
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'therapeutic':
        return AppColors.tealLight;
      case 'relaxation':
        return const Color(0xFF7E57C2);
      case 'emergency':
        return AppColors.coralGlow;
      default:
        return AppColors.tealLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profile = profileService.activeProfile;

    if (profile == null) return const SizedBox.shrink();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
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
                          'Breathing Methods',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your practice',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mistWhite.withOpacity(0.7),
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                      ],
                    ),
                  ),
                ),

                // Therapeutic Methods
                SliverToBoxAdapter(
                  child: _CategorySection(
                    title: 'Therapeutic',
                    methods: BreathingMethods.therapeutic,
                    profile: profile,
                    getIcon: _getIcon,
                    getCategoryColor: _getCategoryColor,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                ),

                // Relaxation Methods
                SliverToBoxAdapter(
                  child: _CategorySection(
                    title: 'Relaxation',
                    methods: BreathingMethods.relaxation,
                    profile: profile,
                    getIcon: _getIcon,
                    getCategoryColor: _getCategoryColor,
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                ),

                // Emergency Methods
                SliverToBoxAdapter(
                  child: _CategorySection(
                    title: 'Emergency',
                    methods: BreathingMethods.emergency,
                    profile: profile,
                    getIcon: _getIcon,
                    getCategoryColor: _getCategoryColor,
                  ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
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

class _CategorySection extends StatelessWidget {
  final String title;
  final List<BreathingMethod> methods;
  final UserProfile? profile;
  final IconData Function(String?) getIcon;
  final Color Function(String) getCategoryColor;

  const _CategorySection({
    required this.title,
    required this.methods,
    required this.profile,
    required this.getIcon,
    required this.getCategoryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (methods.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.mistWhite.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...methods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MethodCard(
              method: method,
              profile: profile,
              icon: getIcon(method.iconName),
              color: getCategoryColor(method.category),
            ),
          )),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final BreathingMethod method;
  final UserProfile? profile;
  final IconData icon;
  final Color color;

  const _MethodCard({
    required this.method,
    required this.profile,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUnsafe = profile?.isPregnant == true && !method.isSafeForPregnancy;

    return Stack(
      children: [
        InkWell(
          onTap: isUnsafe ? null : () {
            context.push('/session', extra: method);
          },
          borderRadius: BorderRadius.circular(20),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: isUnsafe ? 4.0 : 0.0,
              sigmaY: isUnsafe ? 4.0 : 0.0,
            ),
            child: LiquidGlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mistWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mistWhite.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${method.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.mistWhite.withOpacity(0.3),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isUnsafe)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.coralGlow, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Not safe during pregnancy',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
