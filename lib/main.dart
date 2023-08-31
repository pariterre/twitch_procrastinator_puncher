import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';
import 'package:twitch_procastinator_puncher/screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1080),
      center: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setFullScreen(true);
    });
  }

  await declareAppDirectory();
  final preferences = await AppPreferences.factory();
  final participants = await Participants.factory(
      mustFollowForFaming: preferences.mustFollowForFaming.value,
      whitelist: preferences.textWhitelist.text,
      blacklist: preferences.textBlacklist.text);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => preferences),
      ChangeNotifierProvider(create: (context) => participants),
      ChangeNotifierProvider(
          create: (context) => PomodoroStatus(
              getNbSession: () => preferences.nbSessions.value,
              getActiveDuration: (int index) =>
                  preferences.sessionDurations[index].value,
              getPauseDuration: (int index) =>
                  preferences.pauseDurations[index].value,
              onSessionEnded: participants.addSessionDoneToAllConnected)),
    ],
    child: MaterialApp(
      initialRoute: MainScreen.route,
      routes: {
        MainScreen.route: (ctx) => const MainScreen(),
      },
    ),
  ));
}
