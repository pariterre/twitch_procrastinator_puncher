import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/models/reward_redemption.dart';

enum StopWatchStatus { initializing, inSession, inPauseSession, paused, done }

class PomodoroStatus with ChangeNotifier {
  bool _firstSessionStarted = false;
  int _currentSession = 0;
  int get currentSession => _currentSession;

  final List<RewardRedemptionPreferenced> _pendingRewardRedemptions = [];

  Duration _timer = const Duration();
  StopWatchStatus _stopWatchStatus = StopWatchStatus.initializing;
  StopWatchStatus? _stopWatchStatusBeforePausing;
  StopWatchStatus get stopWatchStatus => _stopWatchStatus;

  Duration get timer => _timer;
  set timer(Duration value) {
    _timer = value;
    notifyListeners();
  }

  ///
  /// Start the counter if it is not done
  void start() {
    if (_stopWatchStatus == StopWatchStatus.done) return;

    _stopWatchStatus =
        _stopWatchStatusBeforePausing ?? StopWatchStatus.inSession;
    _stopWatchStatusBeforePausing = null;
    notifyListeners();
  }

  ///
  /// Pause the counter if it is not done
  void pause() {
    if (_stopWatchStatus == StopWatchStatus.done) return;

    _stopWatchStatusBeforePausing = _stopWatchStatus;
    _stopWatchStatus = StopWatchStatus.paused;
    notifyListeners();
  }

  ///
  /// Reset the counter
  void reset({bool notify = true}) {
    // Reset all the internal states
    _firstSessionStarted = false;
    _currentSession = 0;

    _stopWatchStatus = StopWatchStatus.initializing;
    _timer = getActiveDuration(_currentSession);

    if (notify) notifyListeners();
  }

  void addRewardRedemption(RewardRedemptionPreferenced rewardRedemption) {
    _pendingRewardRedemptions.add(rewardRedemption);
  }

  ///
  /// Set the timer to a specific value it has not run yet
  void setTimer(Duration duration) {
    if (_stopWatchStatus == StopWatchStatus.initializing) {
      _timer = duration;
    }
    notifyListeners();
  }

  // CONSTRUCTORS
  PomodoroStatus(
      {required this.getNbSession,
      required this.getActiveDuration,
      required this.getPauseDuration,
      required this.onSessionEnded}) {
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateCounter());
  }
  static PomodoroStatus of(BuildContext context, {listen = true}) =>
      Provider.of<PomodoroStatus>(context, listen: listen);

  // TIMER CALLBACK
  int Function() getNbSession;
  Duration Function(int index) getActiveDuration;
  Duration Function(int index) getPauseDuration;
  Function() onSessionEnded;

  ///
  /// Callback that announces that an active session has finished
  Future<void> Function()? timerHasStartedCallback;

  ///
  /// Callback that announces that an active session has finished
  Future<void> Function()? activeSessionHasFinishedGuiCallback;

  ///
  /// Callback that announces that a pause session has finished
  Future<void> Function()? pauseHasFinishedGuiCallback;

  ///
  /// Callback that announces that we arrived at the end
  Future<void> Function()? finishedWorkingGuiCallback;

  int get _pauseDuration {
    final officialPause = getPauseDuration(_currentSession).inSeconds;

    final rewardRedemptionPause = _pendingRewardRedemptions
        .where((e) => e.rewardRedemption == RewardRedemption.longerPause)
        .fold(0, (prev, e) => prev + e.duration.inSeconds);
    _pendingRewardRedemptions
        .removeWhere((e) => e.rewardRedemption == RewardRedemption.longerPause);

    return officialPause + rewardRedemptionPause;
  }

  // This method is automatically called every seconds
  void _updateCounter() {
    if (_stopWatchStatus == StopWatchStatus.inSession) {
      if (!_firstSessionStarted) {
        if (timerHasStartedCallback != null) timerHasStartedCallback!();
        _firstSessionStarted = true;
      }

      // Decrement the counter, if it gets to zeros advance the session
      int newTimerValue = _timer.inSeconds - 1;
      if (newTimerValue <= 0) {
        onSessionEnded();

        if (_currentSession + 1 == getNbSession()) {
          if (finishedWorkingGuiCallback != null) {
            finishedWorkingGuiCallback!();
          }
          // If next session is the last session, it is over
          _stopWatchStatus = StopWatchStatus.done;
          newTimerValue = 0;
        } else {
          // Otherwise start the pause
          if (activeSessionHasFinishedGuiCallback != null) {
            activeSessionHasFinishedGuiCallback!();
          }
          _stopWatchStatus = StopWatchStatus.inPauseSession;
          newTimerValue = _pauseDuration;
        }
      }
      _timer = Duration(seconds: newTimerValue);
    } else if (_stopWatchStatus == StopWatchStatus.inPauseSession) {
      // Decrement the counter, if it gets to zeros starts the next session
      int newTimerValue = _timer.inSeconds - 1;
      if (newTimerValue <= 0) {
        // Start the next session
        if (pauseHasFinishedGuiCallback != null) {
          pauseHasFinishedGuiCallback!();
        }
        _currentSession++;
        _stopWatchStatus = StopWatchStatus.inSession;
        newTimerValue = getActiveDuration(_currentSession).inSeconds;
      }
      _timer = Duration(seconds: newTimerValue);
    }
    notifyListeners();
  }
}
