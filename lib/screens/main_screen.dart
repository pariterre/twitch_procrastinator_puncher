import 'dart:math';

import 'package:collection/collection.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/enums.dart';
import 'package:twitch_procastinator_puncher/models/participant.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/models/twitch_status.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';
import 'package:twitch_procastinator_puncher/widgets/configuration_board.dart';
import 'package:twitch_procastinator_puncher/widgets/hall_of_fame.dart';
import 'package:twitch_procastinator_puncher/widgets/pomodoro_timer.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const route = '/main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TwitchAppManager? _twitchManager;
  final twitchAppInfo = TwitchAppInfo(
      appName: twitchAppName,
      twitchClientId: twitchAppId,
      twitchRedirectUri: twitchRedirectUri,
      authenticationServerUri: authenticationServerUri,
      scope: twitchScope,
      authenticationFlow: TwitchAuthenticationFlow.implicit);

  late Future<TwitchAppManager> managerFactory = isTwitchMockActive
      ? TwitchManagerMock.factory(
          appInfo: twitchAppInfo, debugPanelOptions: twitchDebugPanelOptions)
      : TwitchAppManager.factory(appInfo: twitchAppInfo);
  StopWatchStatus _statusWithFocus = StopWatchStatus.initializing;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _resetTimer(preventFromNotifying: true);

    // Connect the callback of the timer
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.timerHasStartedCallback = _startWorking;
    pomodoro.preSessionCountdownHasFinishedGuiCallback =
        _preSessionCountdownDone;
    pomodoro.activeSessionHasFinishedGuiCallback = _activeSessionDone;
    pomodoro.pauseHasFinishedGuiCallback = _pauseSessionDone;
    pomodoro.finishedWorkingGuiCallback = _workingDone;

    final preferences = AppPreferences.of(context, listen: false);
    if (preferences.shouldAskToBuyMeACoffee) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showBuyMeACoffeeDialog());
    }
  }

  void _showBuyMeACoffeeDialog() async {
    final preferences = AppPreferences.of(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(preferences.texts.buyMeACoffeeDialogTitle),
        content: Text(preferences.texts.buyMeACoffeeDialogContent),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text(preferences.texts.buyMeACoffeeDialogNo),
          ),
          ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse(buyMeACoffeeLink));
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: Text(
              preferences.texts.buyMeACoffeeDialogYes,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
    pomodoro.reset(notify: !preventFromNotifying);
    _statusWithFocus = StopWatchStatus.initializing;
    setState(() {});
  }

  Future<void> _startWorking() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat
          .send(preferences.textTimerHasStarted.formattedText(context));
    }
  }

  Future<void> _preSessionCountdownDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat.send(preferences.textTimerPreSessionCountdownHasEnded
          .formattedText(context));
    }

    final source = preferences.endCountdownSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source,
          volume: preferences.endCountdownSound.volume / 1.0);
    }
  }

  Future<void> _activeSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat.send(
          preferences.textTimerActiveSessionHasEnded.formattedText(context));
    }

    final source = preferences.endActiveSessionSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source,
          volume: preferences.endActiveSessionSound.volume / 1.0);
    }
  }

  Future<void> _pauseSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat
          .send(preferences.textTimerPauseHasEnded.formattedText(context));
    }

    final source = preferences.endPauseSessionSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source,
          volume: preferences.endPauseSessionSound.volume / 1.0);
    }
  }

  Future<void> _workingDone() async {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat
          .send(preferences.textTimerWorkingHasEnded.formattedText(context));
    }

    final source = preferences.endWorkingSound.playableSource;
    if (source != null) {
      final player = AudioPlayer();
      await player.play(source,
          volume: preferences.endWorkingSound.volume / 1.0);
    }
  }

  void _greetNewComers(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat.send(preferences.textNewcomersGreetings
          .formattedText(context, participant));
    }
    setState(() {});
  }

  void _greetUserHasConnected(Participant participant) {
    final preferences = AppPreferences.of(context, listen: false);
    if (_twitchManager?.isConnected ?? false) {
      _twitchManager!.chat.send(preferences.textUserHasConnectedGreetings
          .formattedText(context, participant));
    }
    setState(() {});
  }

  void _connectToTwitch() async {
    await _setTwitchManager(await showDialog<TwitchAppManager>(
      context: context,
      builder: (context) => TwitchAppAuthenticationDialog(
        onConnexionEstablished: (manager) => Navigator.pop(context, manager),
        onCancelConnexion: () => Navigator.pop(context, null),
        appInfo: twitchAppInfo,
        reload: false,
        debugPanelOptions: twitchDebugPanelOptions,
        useMocker: isTwitchMockActive,
      ),
    ));

    setState(() {});
  }

  Future<void> _onRewardRedemptionSaved(
      {required int index, required TypesOfModification modification}) async {
    final preferences = AppPreferences.of(context, listen: false);
    final RewardRedemptionPreferenced reward =
        preferences.rewardRedemptions[index];

    final isValid = reward.title.isNotEmpty && reward.cost > 0;
    late final String snackbarMessage;
    switch (modification) {
      case TypesOfModification.created:
        // Create a new reward redemption
        if (!isValid) {
          // The reward redemption is not valid
          snackbarMessage = preferences.texts.rewardRedemptionFailed;
          break;
        }

        reward.rewardId = await _twitchManager?.api.createRewardRedemption(
            reward: TwitchRewardRedemption.minimal(
                rewardRedemption: reward.title, cost: reward.cost));

        final isSuccessful = reward.rewardId != null;
        if (isSuccessful) reward.isSavedToTwitch = true;

        snackbarMessage = isSuccessful
            ? preferences.texts.rewardRedemptionSuccess
            : preferences.texts.rewardRedemptionFailed;
        break;

      case TypesOfModification.updated:
        // Update an existing reward redemption
        if (!isValid) {
          // The reward redemption is not valid
          snackbarMessage = preferences.texts.rewardRedemptionFailed;
          break;
        }

        final isSuccessful = await _twitchManager?.api
                .updateRewardRedemption(reward: reward.toTwitch) ??
            false;

        if (isSuccessful) reward.isSavedToTwitch = true;
        snackbarMessage = isSuccessful
            ? preferences.texts.rewardRedemptionSuccess
            : preferences.texts.rewardRedemptionFailed;

        break;

      case TypesOfModification.deleted:
        final isSuccessful = await _twitchManager?.api
                .deleteRewardRedemption(reward: reward.toTwitch) ??
            false;

        snackbarMessage = isSuccessful
            ? preferences.texts.rewardRedemptionRemovedSuccess
            : preferences.texts.rewardRedemptionRemovedFailed;

        preferences.removeRewardRedemptionAt(index);
        break;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(snackbarMessage)));
  }

  Future<void> _setTwitchManager(TwitchAppManager? manager) async {
    if (manager == null || !manager.isConnected) return;
    final participants = Participants.of(context, listen: false);

    // Set internals
    _twitchManager = manager;
    _moderators =
        (await _twitchManager!.api.fetchModerators(includeStreamer: true))!;

    // Connect everything related to participants
    _twitchManager!.chat.onMessageReceived.listen(_onMessageReceived);
    _twitchManager!.events.onRewardRedeemed.listen(_onRewardRedemptionRequest);
    participants.twitchManager = _twitchManager!;
    participants.greetNewcomerCallback = _greetNewComers;
    participants.greetUserHasConnectedCallback = _greetUserHasConnected;
  }

  List<String>? _moderators;

  void _onMessageReceived(String sender, String message) async {
    // Check if the message is a command from any chatter
    final responses =
        AppPreferences.of(context, listen: false).automaticResponses;
    for (var response in responses) {
      if (response.command == message) {
        // Get the username of the sender (i.e. login to username)
        final chatter = await _twitchManager!.api.user(login: sender);
        if (!mounted) return;

        final participant = Participants.of(context, listen: false)
            .all
            .firstWhereOrNull((e) => e.user.id == chatter?.id);
        _twitchManager!.chat
            .send(response.answer.formattedText(context, participant));
      }
    }

    // If we are not done fetching, we are really early in the process, so we
    // can afford waiting a bit before checking if the sender is a moderator.
    if (_moderators == null || !_moderators!.contains(sender)) return;

    // Check if the message is a command from a moderator
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

  void _onRewardRedemptionRequest(TwitchRewardRedemption redemption) {
    final prefs = AppPreferences.of(context, listen: false);

    // Cycle through all the reward redemption defined by the streamer to see
    // if one of them matches the currently redempted one.
    for (var e in prefs.rewardRedemptions) {
      // If so, add it to the timer settings
      if (e.title == redemption.rewardRedemption) {
        PomodoroStatus.of(context, listen: false).addRewardRedemption(e);
        _twitchManager!.api.updateRewardRedemptionStatus(
            reward: redemption, status: TwitchRewardRedemptionStatus.fulfilled);
        _twitchManager!.chat.send(e.formattedChatbotAnswer(redemption));
        continue;
      }
    }
    // If we get here, the reward redemption is not related to the
    // procrastinator puncher or the name of the reward redemption was wrong.
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      backgroundColor: Colors.transparent,
      body: TwitchAppDebugOverlay(
        manager: _twitchManager,
        child: Container(
          height: windowHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: preferences.backgroundColor.value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: FutureBuilder(
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
                            : (_twitchManager?.isConnected ?? false)
                                ? TwitchStatus.connected
                                : TwitchStatus.notConnected,
                        onRewardRedemptionSaved: _onRewardRedemptionSaved,
                      );
                    }),
              ),
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
      ),
    );
    isInitialized = true; // Prevent from calling setState on gainFocus
    return widget;
  }
}
