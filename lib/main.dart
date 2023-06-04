import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/configuration_room.dart';

void main() async {
  final appPreferences = await AppPreferences.factory();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appPreferences),
      ChangeNotifierProvider(create: (context) => PomodoroStatus()),
    ],
    child: MaterialApp(
      initialRoute: ConfigurationRoom.route,
      routes: {
        TwitchAuthenticationScreen.route: (ctx) =>
            const TwitchAuthenticationScreen(
              nextRoute: ConfigurationRoom.route,
              appId: appId,
              scope: [
                TwitchScope.chatRead,
                TwitchScope.chatEdit,
                TwitchScope.chatters,
                TwitchScope.readFollowers,
                TwitchScope.readSubscribers,
              ],
              withModerator: true,
              forceNewAuthentication: false,
            ),
        ConfigurationRoom.route: (ctx) => const ConfigurationRoom(),
      },
    ),
  ));
}
