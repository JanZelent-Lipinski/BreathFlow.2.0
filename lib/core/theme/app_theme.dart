import 'package:flutter/material.dart';

class AppColors {
  // Deep Ocean Teal Gradient
  static const Color tealDark = Color(0xFF004D40);
  static const Color tealLight = Color(0xFF00695C);
  
  // Mist White
  static const Color mistWhite = Color(0xE6FFFFFF); // 90% opacity
  static const Color glassBorder = Color(0x33FFFFFF); // 20% opacity white
  
  // Coral Glow
  static const Color coralGlow = Color(0xFFFFAB91);
  
  // Background Gradients
  static const List<Color> oceanGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];
}

class AppTextStyles {
  // Using generic sans-serif for now, assuming system font corresponds to design
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300, // Light
    color: AppColors.mistWhite,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.mistWhite,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.mistWhite,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700, // Bold Caps
    color: AppColors.mistWhite,
    letterSpacing: 1.0,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // The app is generally dark/glassy
      primaryColor: AppColors.tealLight,
      scaffoldBackgroundColor: AppColors.oceanGradient[0],
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }
}
