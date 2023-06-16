import 'package:audioplayers/audioplayers.dart';
import 'package:common_lib/hall_of_fame.dart';
import 'package:common_lib/models/app_theme.dart';
import 'package:common_lib/pomodoro_timer.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:common_lib/widgets/web_socket_holders.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const route = '/main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Connect the callback of the timer
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.activeSessionHasFinishedGuiCallback = _activeSessionDone;
    pomodoro.pauseHasFinishedGuiCallback = _pauseSessionDone;
    pomodoro.finishedWorkingGuiCallback = _workingDone;
  }

  Future<void> _activeSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endActiveSessionSound.file != null) {
      final player = AudioPlayer();
      await player
          .play(DeviceFileSource(preferences.endActiveSessionSound.filepath!));
    }
  }

  Future<void> _pauseSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endPauseSessionSound.file != null) {
      final player = AudioPlayer();
      await player
          .play(DeviceFileSource(preferences.endPauseSessionSound.filepath!));
    }
  }

  Future<void> _workingDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endWorkingSound.file != null) {
      final player = AudioPlayer();
      await player
          .play(DeviceFileSource(preferences.endWorkingSound.filepath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      backgroundColor: preferences.backgroundColor.value.withOpacity(0),
      body: WebSocketClientHolder(
        child: SizedBox(
          height: windowHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SizedBox(height: padding),
                  const PomodoroTimer(
                      textWithFocus: StopWatchStatus.initializing),
                  SizedBox(height: padding),
                  if (preferences.useHallOfFame.value) const HallOfFame(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    isInitialized = true; // Prevent from calling setState on gainFocus
    return widget;
  }
}
