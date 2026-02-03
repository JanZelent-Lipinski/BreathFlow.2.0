import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  Box<UserProfile>? profilesBox;
  Box? _settingsBox;

  static const String _activeProfileKey = 'activeProfileId';

  UserProfile? _activeProfile;
  UserProfile? get activeProfile => _activeProfile;
  
  bool get hasProfile => profilesBox?.isNotEmpty ?? false;
  bool get isInitialized => profilesBox != null;

  Future<void> init() async {
    profilesBox = await Hive.openBox<UserProfile>('profiles');
    _settingsBox = await Hive.openBox('settings');
    
    _loadActiveProfile();
    notifyListeners();
  }

  void _loadActiveProfile() {
    if (profilesBox == null || profilesBox!.isEmpty) return;

    final savedId = _settingsBox?.get(_activeProfileKey);
    if (savedId != null) {
      try {
        _activeProfile = profilesBox!.values.firstWhere((p) => p.id == savedId);
      } catch (e) {
        // Saved ID not found, fallback
        _activeProfile = profilesBox!.getAt(0);
      }
    } else {
      _activeProfile = profilesBox!.getAt(0);
    }
  }

  Future<void> createProfile(String name, bool isChild, bool isPregnant) async {
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple ID
      name: name,
      isChild: isChild,
      isPregnant: isPregnant,
      createdAt: DateTime.now(),
    );
    await profilesBox?.add(newProfile);
    await setActiveProfile(newProfile);
  }

  Future<void> setActiveProfile(UserProfile profile) async {
    _activeProfile = profile;
    await _settingsBox?.put(_activeProfileKey, profile.id);
    notifyListeners();
  }
}
