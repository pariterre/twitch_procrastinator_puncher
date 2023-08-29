import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/participant.dart';
import 'package:twitch_procastinator_puncher/models/twitch_status.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';
import 'package:twitch_procastinator_puncher/widgets/configuration_board.dart';
import 'package:twitch_procastinator_puncher/widgets/hall_of_fame.dart';
import 'package:twitch_procastinator_puncher/widgets/pomodoro_timer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const route = '/main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TwitchManager? _twitchManager;
  final twitchAppInfo = TwitchAppInfo(
    appName: twitchAppName,
    twitchAppId: twitchAppId,
    redirectAddress: twitchRedirect,
    scope: twitchScope,
    useAuthenticationService: true,
    authenticationServiceAddress: authenticationServiceAddress,
  );
  final _twitchMockOptions = const TwitchMockOptions(
      isActive: true,
      messagesModerators: ['!startTimer', '!pauseTimer', '!resetTimer']);
  late Future<TwitchManager> managerFactory = _twitchMockOptions.isActive
      ? TwitchManagerMock.factory(
          appInfo: twitchAppInfo, mockOptions: _twitchMockOptions)
      : TwitchManager.factory(appInfo: twitchAppInfo);
  StopWatchStatus _statusWithFocus = StopWatchStatus.initializing;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _resetTimer(preventFromNotifying: true);

    // Connect the callback of the timer
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.timerHasStartedCallback = _startWorking;
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
      nbSessions: appPreferences.nbSessions,
      focusSessionDuration: appPreferences.sessionDuration,
      pauseSessionDuration: appPreferences.pauseDuration,
      notify: !preventFromNotifying,
    );
    _statusWithFocus = StopWatchStatus.initializing;
    setState(() {});
  }

  Future<void> _startWorking() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc
          .send(preferences.textTimerHasStarted.formattedText(context));
    }
  }

  Future<void> _activeSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc.send(
          preferences.textTimerActiveSessionHasEnded.formattedText(context));
    }

    final source = preferences.endActiveSessionSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source);
    }
  }

  Future<void> _pauseSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc
          .send(preferences.textTimerPauseHasEnded.formattedText(context));
    }

    final source = preferences.endPauseSessionSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source);
    }
  }

  Future<void> _workingDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc
          .send(preferences.textTimerWorkingHasEnded.formattedText(context));
    }

    final source = preferences.endWorkingSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source);
    }
  }

  void _greetNewComers(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc.send(preferences.textNewcomersGreetings
          .formattedText(context, participant));
    }
    setState(() {});
  }

  void _greetUserHasConnected(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager!.isConnected) {
      _twitchManager!.irc.send(preferences.textUserHasConnectedGreetings
          .formattedText(context, participant));
    }
    setState(() {});
  }

  void _connectToTwitch() async {
    _setTwitchManager(await showDialog<TwitchManager>(
      context: context,
      builder: (context) => Dialog(
          child: TwitchAuthenticationScreen(
        mockOptions: _twitchMockOptions,
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
    _twitchManager!.irc.messageCallback = _onMessageReceived;
    participants.twitchManager = _twitchManager!;
    fetchModerators();
    participants.greetNewcomerCallback = _greetNewComers;
    participants.greetUserHasConnectedCallback = _greetUserHasConnected;
  }

  List<String>? _moderators;
  Future<void> fetchModerators() async {
    _moderators = (await _twitchManager!.api.fetchModerators())!;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _onMessageReceived(String sender, String message) async {
    // If we are not done fetching, we are really early in the process, so we
    // can afford waiting a bit.
    if (_moderators == null || !_moderators!.contains(sender)) return;

    switch (message) {
      case '!startTimer':
        _startTimer();
        break;
      case '!pauseTimer':
        _pauseTimer();
        break;
      case '!resetTimer':
        _resetTimer();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      body: Stack(
        children: [
          Container(
            height: windowHeight,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: preferences.backgroundColor.value),
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
                            : _twitchManager != null &&
                                    _twitchManager!.isConnected
                                ? TwitchStatus.connected
                                : TwitchStatus.notConnected,
                      );
                    }),
                Column(
                  children: [
                    SizedBox(height: padding),
                    PomodoroTimer(textWithFocus: _statusWithFocus),
                    SizedBox(height: padding),
                    if (preferences.useHallOfFame.value) const HallOfFame(),
                  ],
                ),
              ],
            ),
          ),
          if (_twitchManager != null)
            TwitchDebugPanel(manager: _twitchManager!),
        ],
      ),
    );
    isInitialized = true; // Prevent from calling setState on gainFocus
    return widget;
  }
}
