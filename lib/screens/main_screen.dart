import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app_info.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';
import 'package:twitch_pomorodo_timer/models/twitch_status.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/configuration_board.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/hall_of_fame.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/pomodoro_timer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const route = '/main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TwitchManager? _twitchManager;
  late Future<TwitchManager> managerFactory =
      TwitchManager.factory(appInfo: twitchAppInfo);
  final twitchAppInfo = TwitchAppInfo(
    appName: twitchAppName,
    twitchAppId: twitchAppId,
    redirectAddress: twitchRedirect,
    scope: twitchScope,
  );
  StopWatchStatus _statusWithFocus = StopWatchStatus.initializing;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _resetTimer(preventFromNotifying: true);

    // Connect the callback of the timer
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.activeSessionHasFinishedGuiCallback = _activeSessionDone;
    pomodoro.pauseHasFinishedGuiCallback = _pauseSessionDone;
    pomodoro.finishedWorkingGuiCallback = _workingDone;
  }

  void _startTimer() {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.start();
    setState(() {});
  }

  void _pauseTimer() {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.pause();
    setState(() {});
  }

  void _resetTimer({bool preventFromNotifying = false}) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final appPreferences = AppPreferences.of(context, listen: false);
    pomodoro.reset(
      nbSession: appPreferences.nbSessions,
      focusSessionDuration:
          Duration(seconds: appPreferences.sessionDuration.inSeconds),
      pauseSessionDuration:
          Duration(seconds: appPreferences.pauseDuration.inSeconds),
      notify: !preventFromNotifying,
    );
    _statusWithFocus = StopWatchStatus.initializing;
    setState(() {});
  }

  Future<void> _activeSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endActiveSessionSoundFilePath != null) {
      final player = AudioPlayer();
      await player.play(
          DeviceFileSource('${preferences.endActiveSessionSoundFilePath}'));
    }
  }

  Future<void> _pauseSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endPauseSessionSoundFilePath != null) {
      final player = AudioPlayer();
      await player.play(
          DeviceFileSource('${preferences.endPauseSessionSoundFilePath}'));
    }
  }

  Future<void> _workingDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endWorkingSoundFilePath != null) {
      final player = AudioPlayer();
      await player
          .play(DeviceFileSource('${preferences.endWorkingSoundFilePath}'));
    }
  }

  void _greetNewComers(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    _twitchManager!.irc.send(
        preferences.textNewcomersGreetings.formattedText(context, participant));
    setState(() {});
  }

  void _greetUserHasConnected(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    _twitchManager!.irc.send(preferences.textUserHasConnectedGreetings
        .formattedText(context, participant));
    setState(() {});
  }

  void _connectToTwitch() async {
    _setTwitchManager(await showDialog<TwitchManager>(
      context: context,
      builder: (context) => Dialog(
          child: TwitchAuthenticationScreen(
        onFinishedConnexion: (manager) => Navigator.pop(context, manager),
        appInfo: twitchAppInfo,
        loadPreviousSession: false,
      )),
    ));

    setState(() {});
  }

  void _setTwitchManager(TwitchManager? manager) {
    if (manager == null) return;

    _twitchManager = manager;

    // Connect everything related to participants
    final participants = Participants.of(context, listen: false);
    participants.twitchManager = _twitchManager!;
    participants.greetNewcomerCallback = _greetNewComers;
    participants.greetUserHasConnectedCallback = _greetUserHasConnected;
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      body: Container(
        height: windowHeight,
        decoration: BoxDecoration(color: ThemeColor().background),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FutureBuilder(
                future: managerFactory,
                builder: (context, snapshot) {
                  if (_twitchManager == null && snapshot.hasData) {
                    _setTwitchManager(snapshot.data);
                  }

                  return ConfigurationBoard(
                    startTimerCallback: _startTimer,
                    pauseTimerCallback: _pauseTimer,
                    resetTimerCallback: _resetTimer,
                    gainFocusCallback: (hasFocus) {
                      _statusWithFocus = hasFocus;
                      if (isInitialized) setState(() {});
                    },
                    connectToTwitch: _connectToTwitch,
                    twitchStatus: !snapshot.hasData
                        ? TwitchStatus.initializing
                        : _twitchManager != null && _twitchManager!.isConnected
                            ? TwitchStatus.connected
                            : TwitchStatus.notConnected,
                  );
                }),
            Column(
              children: [
                SizedBox(height: padding),
                PomodoroTimer(textWithFocus: _statusWithFocus),
                SizedBox(height: padding),
                if (preferences.useHallOfFame) const HallOfFame(),
              ],
            ),
          ],
        ),
      ),
    );
    isInitialized = true; // Prevent from calling setState on gainFocus
    return widget;
  }
}
