import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/configuration_board.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/pomodoro_timer.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  TwitchManager? _twitchManager;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // _twitchManager ??=
    //     ModalRoute.of(context)!.settings.arguments as TwitchManager;
  }

  void _startTimer() {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final appPreferences = AppPreferences.of(context, listen: false);
    pomodoro.timer =
        Duration(seconds: appPreferences.sessionDuration.inSeconds);
    pomodoro.reset(
        nbSession: appPreferences.nbSessions,
        focusSessionDuration:
            Duration(seconds: appPreferences.sessionDuration.inSeconds),
        pauseSessionDuration:
            Duration(seconds: appPreferences.pauseDuration.inSeconds));
    pomodoro.start();
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ConfigurationBoard(startTimerCallback: _startTimer),
            const PomodoroTimer(),
          ],
        ),
      ),
    );
  }
}
