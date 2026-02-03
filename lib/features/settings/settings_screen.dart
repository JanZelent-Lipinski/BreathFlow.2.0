import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  LiquidGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mistWhite.withOpacity(0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SettingItem(
                          icon: Icons.person,
                          title: 'Manage Profiles',
                          onTap: () => context.push('/profile-management'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  LiquidGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferences',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mistWhite.withOpacity(0.6),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SettingItem(
                          icon: Icons.volume_up,
                          title: 'Sound',
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.glassBorder, height: 32),
                        _SettingItem(
                          icon: Icons.vibration,
                          title: 'Haptics',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.tealLight, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.mistWhite,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.mistWhite.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
