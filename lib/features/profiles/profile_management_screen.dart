import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import 'profile_service.dart';
import '../../data/models/user_profile.dart';
import '../session/session_service.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  bool _showCreateForm = false;
  final _nameController = TextEditingController();
  bool _isChild = false;
  bool _isPregnant = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final profileService = context.read<ProfileService>();
    await profileService.createProfile(name, _isChild, _isPregnant);

    // Initialize session service for new profile
    final sessionService = context.read<SessionService>();
    await sessionService.switchProfile(profileService.activeProfile!.id);

    setState(() {
      _showCreateForm = false;
      _nameController.clear();
      _isChild = false;
      _isPregnant = false;
    });
  }

  void _switchProfile(UserProfile profile) async {
    final profileService = context.read<ProfileService>();
    await profileService.setActiveProfile(profile);

    // Switch session service to new profile
    final sessionService = context.read<SessionService>();
    await sessionService.switchProfile(profile.id);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileService = context.watch<ProfileService>();
    final profiles = profileService.profilesBox?.values.toList() ?? [];
    final activeProfile = profileService.activeProfile;

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
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.mistWhite),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Manage Profiles',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                ),

                // Create Profile Button
                if (!_showCreateForm)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LiquidGlassContainer(
                        child: InkWell(
                          onTap: () => setState(() => _showCreateForm = true),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.tealLight.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.tealLight,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Create New Profile',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
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
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    ),
                  ),

                // Create Profile Form
                if (_showCreateForm)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: LiquidGlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'New Profile',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.mistWhite,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.mistWhite),
                                  onPressed: () => setState(() {
                                    _showCreateForm = false;
                                    _nameController.clear();
                                    _isChild = false;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameController,
                              style: const TextStyle(color: AppColors.mistWhite),
                              decoration: InputDecoration(
                                labelText: "Name",
                                labelStyle: TextStyle(
                                  color: AppColors.mistWhite.withOpacity(0.6),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.mistWhite.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.tealLight),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Is this profile for a child?",
                                  style: TextStyle(
                                    color: AppColors.mistWhite.withOpacity(0.8),
                                  ),
                                ),
                                Switch(
                                  value: _isChild,
                                  activeColor: AppColors.tealLight,
                                  onChanged: (val) => setState(() => _isChild = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Is this person pregnant?",
                                  style: TextStyle(
                                    color: AppColors.mistWhite.withOpacity(0.8),
                                  ),
                                ),
                                Switch(
                                  value: _isPregnant,
                                  activeColor: AppColors.tealLight,
                                  onChanged: (val) => setState(() => _isPregnant = val),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _createProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tealLight,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text("Create Profile"),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Profiles List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Your Profiles',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mistWhite.withOpacity(0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Profile Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final profile = profiles[index];
                        final isActive = activeProfile?.id == profile.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: LiquidGlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: InkWell(
                              onTap: isActive ? null : () => _switchProfile(profile),
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: isActive
                                        ? AppColors.tealLight
                                        : AppColors.mistWhite.withOpacity(0.2),
                                    child: Text(
                                      profile.name[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.mistWhite,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              profile.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.mistWhite,
                                              ),
                                            ),
                                            if (profile.isChild) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.coralGlow.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Child',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.coralGlow,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (isActive)
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                size: 14,
                                                color: AppColors.tealLight,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Active',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.tealLight,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            'Tap to switch',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mistWhite.withOpacity(0.5),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!isActive)
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.mistWhite.withOpacity(0.3),
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ).animate(delay: Duration(milliseconds: 100 * index))
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: 0.1, end: 0),
                        );
                      },
                      childCount: profiles.length,
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
