import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'data/models/user_profile.dart';
import 'data/models/session.dart';
import 'features/profiles/profile_service.dart';
import 'features/session/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(SessionAdapter());

  final profileService = ProfileService();
  await profileService.init();

  final sessionService = SessionService();
  if (profileService.activeProfile != null) {
    await sessionService.init(profileService.activeProfile!.id);
  }

  runApp(SlowFlowApp(
    profileService: profileService,
    sessionService: sessionService,
  ));
}

class SlowFlowApp extends StatefulWidget {
  final ProfileService profileService;
  final SessionService sessionService;

  const SlowFlowApp({
    super.key,
    required this.profileService,
    required this.sessionService,
  });

  @override
  State<SlowFlowApp> createState() => _SlowFlowAppState();
}

class _SlowFlowAppState extends State<SlowFlowApp> {
  late final router = createAppRouter(widget.profileService);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.profileService),
        ChangeNotifierProvider.value(value: widget.sessionService),
      ],
      child: MaterialApp.router(
        title: 'SlowFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
