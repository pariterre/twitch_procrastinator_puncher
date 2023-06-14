import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/participants.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_client/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appPreferences = await AppPreferences.factory();
  final participants = await Participants.factory(
      mustFollowForFaming: appPreferences.mustFollowForFaming,
      whitelist: appPreferences.textWhitelist.text,
      blacklist: appPreferences.textBlacklist.text);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appPreferences),
      ChangeNotifierProvider(create: (context) => participants),
      ChangeNotifierProvider(
          create: (context) =>
              PomodoroStatus(sessionHasFinishedCallback: () {})),
    ],
    child: MaterialApp(
      initialRoute: MainScreen.route,
      routes: {
        MainScreen.route: (ctx) => const MainScreen(),
      },
    ),
  ));
}
