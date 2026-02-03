import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass_container.dart';
import '../profiles/profile_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _isChild = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await context.read<ProfileService>().createProfile(name, _isChild, false);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      // Using a stack to creating the ambient background
      body: Stack(
        children: [
          // Ambient Background
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Welcome
                  const Icon(Icons.air, size: 64, color: AppColors.mistWhite)
                      .animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                  Text(
                    "Welcome to SlowFlow",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    "Breathe better, live slower.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mistWhite.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  
                  const SizedBox(height: 48),

                  // Form Container
                  LiquidGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Let's get started",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.mistWhite,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Name Input
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.mistWhite),
                          decoration: InputDecoration(
                            labelText: "What is your name?",
                            labelStyle: TextStyle(color: AppColors.mistWhite.withOpacity(0.6)),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.mistWhite.withOpacity(0.3)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.tealLight),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Age / Child Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Is this profile for a child?",
                              style: TextStyle(color: AppColors.mistWhite.withOpacity(0.8)),
                            ),
                            Switch(
                              value: _isChild,
                              activeColor: AppColors.tealLight,
                              onChanged: (val) => setState(() => _isChild = val),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Action Button
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
                  ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
