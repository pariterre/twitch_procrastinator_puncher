import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
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
            ConfigurationBoard(
              startTimerCallback: () => {},
            ),
            const PomodoroTimer(),
          ],
        ),
      ),
    );
  }
}
