class BreathingMethod {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final List<BreathPhase> pattern;
  final String category;
  final String? iconName;
  final bool isSafe; // For children/pregnant
  final bool isSafeForPregnancy; // Specifically for pregnancy

  const BreathingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.pattern,
    required this.category,
    this.iconName,
    this.isSafe = true,
    this.isSafeForPregnancy = true,
  });
}

class BreathPhase {
  final String type; // 'inhale', 'hold', 'exhale', 'rest'
  final int durationSeconds;
  final String? instruction;

  const BreathPhase({
    required this.type,
    required this.durationSeconds,
    this.instruction,
  });
}

// Preset breathing methods
class BreathingMethods {
  static const buteyko = BreathingMethod(
    id: 'buteyko',
    name: 'Buteyko',
    description: 'Build CO₂ tolerance',
    durationMinutes: 15,
    category: 'therapeutic',
    iconName: 'air',
    isSafeForPregnancy: false, // Not safe for pregnant women
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 3),
      BreathPhase(type: 'exhale', durationSeconds: 3),
      BreathPhase(type: 'rest', durationSeconds: 4),
    ],
  );

  static const box = BreathingMethod(
    id: 'box',
    name: 'Box Breathing',
    description: 'Equal breathing for calm',
    durationMinutes: 5,
    category: 'relaxation',
    iconName: 'crop_square',
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 4),
      BreathPhase(type: 'hold', durationSeconds: 4),
      BreathPhase(type: 'exhale', durationSeconds: 4),
      BreathPhase(type: 'hold', durationSeconds: 4),
    ],
  );

  static const guillarme = BreathingMethod(
    id: 'guillarme',
    name: 'Guillarme',
    description: 'Long, even exhale with support',
    durationMinutes: 10,
    category: 'therapeutic',
    iconName: 'waves',
    isSafe: true,
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 4),
      BreathPhase(type: 'exhale', durationSeconds: 6),
      BreathPhase(type: 'rest', durationSeconds: 2),
    ],
  );

  static const relax = BreathingMethod(
    id: 'relax',
    name: 'Relax',
    description: 'Deep relaxation breathing',
    durationMinutes: 8,
    category: 'relaxation',
    iconName: 'spa',
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 4),
      BreathPhase(type: 'hold', durationSeconds: 7),
      BreathPhase(type: 'exhale', durationSeconds: 8),
    ],
  );

  static const panicReset = BreathingMethod(
    id: 'panic_reset',
    name: 'Panic Reset',
    description: '3–5 "sighs" with long exhale. Immediate tension relief.',
    durationMinutes: 1,
    category: 'emergency',
    iconName: 'bolt',
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 3, instruction: 'Deep breath in'),
      BreathPhase(type: 'exhale', durationSeconds: 6, instruction: 'Long sigh out'),
    ],
  );

  static const noseUnblock = BreathingMethod(
    id: 'nose_unblock',
    name: 'Nose Unblock',
    description: 'Equal phases 4–4–4. Training concentration.',
    durationMinutes: 5,
    category: 'therapeutic',
    iconName: 'air',
    pattern: [
      BreathPhase(type: 'inhale', durationSeconds: 4),
      BreathPhase(type: 'hold', durationSeconds: 4),
      BreathPhase(type: 'exhale', durationSeconds: 4),
    ],
  );

  static List<BreathingMethod> get all => [
    buteyko,
    guillarme,
    box,
    relax,
    panicReset,
    noseUnblock,
  ];

  static List<BreathingMethod> get therapeutic => 
    all.where((m) => m.category == 'therapeutic').toList();

  static List<BreathingMethod> get relaxation => 
    all.where((m) => m.category == 'relaxation').toList();

  static List<BreathingMethod> get emergency => 
    all.where((m) => m.category == 'emergency').toList();
}
