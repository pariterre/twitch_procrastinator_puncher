import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/configuration_board.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/hall_of_fame.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/pomodoro_timer.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  TwitchManager? _twitchManager;
  StopWatchStatus _statusWithFocus = StopWatchStatus.initializing;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _resetTimer(preventFromNotifying: true);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
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

  void _greetNewComers(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    _twitchManager!.irc!.send(
        preferences.textNewcomersGreetings.formattedText(context, participant));
    setState(() {});
  }

  void _greetUserHasConnected(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    _twitchManager!.irc!.send(preferences.textUserHasConnectedGreetings
        .formattedText(context, participant));
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

  void _connectToTwitch() async {
    final participants = Participants.of(context, listen: false);

    _twitchManager = await showDialog<TwitchManager>(
      context: context,
      builder: (context) => Dialog(
          child: TwitchAuthenticationScreen(
        onFinishedConnexion: (manager) => Navigator.pop(context, manager),
        appId: twitchAppId,
        scope: twitchScope,
        withChatbot: false,
        forceNewAuthentication: false,
      )),
    );

    // Connect everything related to participants
    participants.twitchManager = _twitchManager!;
    participants.greetNewcomer = _greetNewComers;
    participants.greetUserHasConnected = _greetUserHasConnected;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      body: Container(
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ConfigurationBoard(
              startTimerCallback: _startTimer,
              pauseTimerCallback: _pauseTimer,
              resetTimerCallback: _resetTimer,
              gainFocusCallback: (hasFocus) => () {
                _statusWithFocus = hasFocus;
                if (isInitialized) setState(() {});
              },
              connectToTwitch: _twitchManager == null ? _connectToTwitch : null,
            ),
            Column(
              children: [
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
