import '../data/models/breathing_method.dart';
import '../data/models/user_profile.dart';
import '../features/session/session_service.dart';

class RecommendationService {
  final SessionService sessionService;

  RecommendationService(this.sessionService);

  BreathingMethod getRecommendation({
    required UserProfile profile,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final sessions = sessionService.sessions;
    final todaySessions = sessionService.todaySessions;

    // If user is a child, prioritize safe methods
    if (profile.isChild) {
      return _getChildRecommendation(hour, todaySessions);
    }

    // Time-based recommendations
    if (hour >= 5 && hour < 9) {
      // Morning: Energizing
      return _getMorningRecommendation(sessions);
    } else if (hour >= 9 && hour < 17) {
      // Daytime: Focus & calm
      return _getDaytimeRecommendation(sessions);
    } else if (hour >= 17 && hour < 21) {
      // Evening: Relaxation
      return _getEveningRecommendation(sessions);
    } else {
      // Night: Deep relaxation
      return _getNightRecommendation(sessions);
    }
  }

  BreathingMethod _getChildRecommendation(int hour, List<dynamic> sessions) {
    // Children should use gentler methods
    if (hour >= 5 && hour < 12) {
      return BreathingMethods.box; // Simple and safe
    } else if (hour >= 12 && hour < 18) {
      return BreathingMethods.guillarme; // Gentle and therapeutic
    } else {
      return BreathingMethods.relax; // Calming for bedtime
    }
  }

  BreathingMethod _getMorningRecommendation(List<dynamic> sessions) {
    // Morning: Build CO2 tolerance or energize
    final hasButeyko = sessions.any((s) => s.methodType == 'buteyko');
    
    if (!hasButeyko || sessions.length < 3) {
      return BreathingMethods.buteyko; // Foundation method
    }
    
    return BreathingMethods.noseUnblock; // Clear airways
  }

  BreathingMethod _getDaytimeRecommendation(List<dynamic> sessions) {
    // Daytime: Focus and stress management
    final hasBox = sessions.any((s) => s.methodType == 'box');
    
    if (!hasBox) {
      return BreathingMethods.box; // Great for focus
    }
    
    return BreathingMethods.guillarme; // Calm and steady
  }

  BreathingMethod _getEveningRecommendation(List<dynamic> sessions) {
    // Evening: Wind down
    final hasRelax = sessions.any((s) => s.methodType == 'relax');
    
    if (!hasRelax) {
      return BreathingMethods.relax; // Deep relaxation
    }
    
    return BreathingMethods.guillarme; // Gentle transition
  }

  BreathingMethod _getNightRecommendation(List<dynamic> sessions) {
    // Night: Prepare for sleep
    return BreathingMethods.relax; // Always relax before bed
  }

  String getRecommendationReason({
    required UserProfile profile,
    required BreathingMethod method,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    if (profile.isChild) {
      if (hour >= 5 && hour < 12) return 'Gentle morning practice';
      if (hour >= 12 && hour < 18) return 'Afternoon calm';
      return 'Bedtime relaxation';
    }

    if (hour >= 5 && hour < 9) {
      if (method.id == 'buteyko') return 'Build morning CO₂ tolerance';
      return 'Clear airways for the day';
    } else if (hour >= 9 && hour < 17) {
      if (method.id == 'box') return 'Enhance focus & calm';
      return 'Reduce daytime stress';
    } else if (hour >= 17 && hour < 21) {
      return 'Wind down after your day';
    } else {
      return 'Prepare for restful sleep';
    }
  }
}
