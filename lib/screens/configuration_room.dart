import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  TwitchManager? _twitchManager;
  AppPreferences? fileIo;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // _twitchManager ??=
    //     ModalRoute.of(context)!.settings.arguments as TwitchManager;
    fileIo ??= await AppPreferences.factory();
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final appPreferences = AppPreferences.of(context);

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
            ConfigurationBoard(
              startTimerCallback: () => {},
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({super.key, required this.startTimerCallback});

  final Function() startTimerCallback;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    return Container(
      width: windowHeight * 0.5,
      decoration: const BoxDecoration(color: ThemeColor.main),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: startTimerCallback,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              'Start',
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }
}
