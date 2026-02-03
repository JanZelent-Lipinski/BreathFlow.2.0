import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/session.dart';

class SessionService extends ChangeNotifier {
  Box<Session>? _sessionsBox;
  String? _activeProfileId;

  List<Session> get sessions {
    if (_sessionsBox == null) return [];
    return _sessionsBox!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  List<Session> get todaySessions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sessions.where((s) {
      final sessionDate = DateTime(s.date.year, s.date.month, s.date.day);
      return sessionDate.isAtSameMomentAs(today);
    }).toList();
  }

  List<Session> get cpTests {
    return sessions.where((s) => s.cpScore != null).toList();
  }

  Future<void> init(String profileId) async {
    _activeProfileId = profileId;
    _sessionsBox = await Hive.openBox<Session>('sessions_$profileId');
    notifyListeners();
  }

  Future<void> switchProfile(String profileId) async {
    await _sessionsBox?.close();
    await init(profileId);
  }

  Future<void> saveSession({
    required String methodType,
    required int durationSeconds,
    double? cpScore,
  }) async {
    if (_sessionsBox == null) return;

    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      durationSeconds: durationSeconds,
      methodType: methodType,
      cpScore: cpScore,
    );

    await _sessionsBox!.add(session);
    notifyListeners();
  }

  Future<void> deleteSession(Session session) async {
    await session.delete();
    notifyListeners();
  }

  // Statistics
  int get totalSessions => sessions.length;
  int get todaySessionCount => todaySessions.length;
  
  double? get latestCpScore {
    final tests = cpTests;
    return tests.isEmpty ? null : tests.first.cpScore;
  }

  Map<String, int> get sessionsByMethod {
    final map = <String, int>{};
    for (final session in sessions) {
      map[session.methodType] = (map[session.methodType] ?? 0) + 1;
    }
    return map;
  }
}
