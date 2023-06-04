import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/configuration_room.dart';

void main() async {
  final appPreferences = await AppPreferences.factory();
  final participants = await Participants.factory();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appPreferences),
      ChangeNotifierProvider(create: (context) => participants),
      ChangeNotifierProvider(create: (context) => PomodoroStatus()),
    ],
    child: MaterialApp(
      initialRoute: ConfigurationRoom.route,
      routes: {
        ConfigurationRoom.route: (ctx) => const ConfigurationRoom(),
      },
    ),
  ));
}
