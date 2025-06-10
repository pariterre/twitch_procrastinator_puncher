import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/models/reward_redemption.dart';

enum StopWatchStatus {
  initializing,
  inPreSessionCountdown,
  inSession,
  inPauseSession,
  paused,
  done
}

class PomodoroStatus with ChangeNotifier {
  bool _firstSessionStarted = false;
  int _currentSession = -1; // -1 means pre-session countdown if enabled
  int get currentSession => _currentSession;
  set currentSession(int value) {
    _currentSession = value;
    notifyListeners();
  }

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

  bool get hasPreSessionCountdown =>
      getPreSessionCountdownDuration() != Duration.zero;

  ///
  /// Start the counter if it is not done
  void start() {
    if (_stopWatchStatus == StopWatchStatus.done) return;

    if (_stopWatchStatusBeforePausing == null) {
      // If we are starting the timer
      reset(notify: false);
      _stopWatchStatus = hasPreSessionCountdown
          ? StopWatchStatus.inPreSessionCountdown
          : StopWatchStatus.inSession;
    } else {
      // If we are resuming the timer
      _stopWatchStatus = _stopWatchStatusBeforePausing!;
      _stopWatchStatusBeforePausing = null;
    }
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
    _currentSession = hasPreSessionCountdown ? -1 : 0;

    _stopWatchStatus = StopWatchStatus.initializing;
    _timer = hasPreSessionCountdown
        ? getPreSessionCountdownDuration()
        : getActiveDuration(_currentSession);

    if (notify) notifyListeners();
  }

  void _animateAddingTime(Duration duration) async {
    const frameRate = 10; // milliseconds
    const nbFrames = 1000 / frameRate; // 1.0 seconds of animation
    final increasingValue = duration.inMilliseconds ~/ nbFrames;

    // This algorithm is not very precise as notifyListeners() takes time to call.
    for (int i = 0; i < duration.inMilliseconds; i += increasingValue) {
      await Future.delayed(const Duration(milliseconds: frameRate));
      _timer += Duration(milliseconds: increasingValue);
      notifyListeners();
    }
    notifyListeners();
  }

  void addRewardRedemption(RewardRedemptionPreferenced rewardRedemption) {
    if (!rewardRedemption.rewardRedemption.isTimeRelated) return;

    if (rewardRedemption.rewardRedemption.takesEffectNow) {
      _animateAddingTime(rewardRedemption.duration);
      return;
    } else {
      _pendingRewardRedemptions.add(rewardRedemption);
    }
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
  PomodoroStatus({
    required this.getNbSession,
    required this.getPreSessionCountdownDuration,
    required this.getActiveDuration,
    required this.getPauseDuration,
    required this.onSessionEnded,
  }) {
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateCounter());
  }
  static PomodoroStatus of(BuildContext context, {listen = true}) =>
      Provider.of<PomodoroStatus>(context, listen: listen);

  // TIMER CALLBACK
  int Function() getNbSession;
  Duration Function() getPreSessionCountdownDuration;
  Duration Function(int index) getActiveDuration;
  Duration Function(int index) getPauseDuration;
  Function() onSessionEnded;

  ///
  /// Callback that announces that an active session has finished
  Future<void> Function()? timerHasStartedCallback;

  ///
  /// Callback that announces that the pre-session countdown has started
  Future<void> Function()? preSessionCountdownHasFinishedGuiCallback;

  ///
  /// Callback that announces that an active session has finished
  Future<void> Function()? activeSessionHasFinishedGuiCallback;

  ///
  /// Callback that announces that a pause session has finished
  Future<void> Function()? pauseHasFinishedGuiCallback;

  ///
  /// Callback that announces that we arrived at the end
  Future<void> Function()? finishedWorkingGuiCallback;

  ///
  /// Get the total duration of the active session (official + reward redemptions)
  int get _activeDuration {
    final officialActive = getActiveDuration(_currentSession).inSeconds;

    final rewardRedemptionActive = _pendingRewardRedemptions
        .where(
            (e) => e.rewardRedemption == RewardRedemption.nextSessionIslonger)
        .fold(0, (prev, e) => prev + e.duration.inSeconds);
    _pendingRewardRedemptions.removeWhere(
        (e) => e.rewardRedemption == RewardRedemption.nextSessionIslonger);
    _animateAddingTime(Duration(seconds: rewardRedemptionActive));

    return officialActive;
  }

  ///
  /// Get the total duration of the pause (official + reward redemptions)
  int get _pauseDuration {
    final officialPause = getPauseDuration(_currentSession).inSeconds;

    final rewardRedemptionPause = _pendingRewardRedemptions
        .where((e) => e.rewardRedemption == RewardRedemption.nextPauseIsLonger)
        .fold(0, (prev, e) => prev + e.duration.inSeconds);
    _pendingRewardRedemptions.removeWhere(
        (e) => e.rewardRedemption == RewardRedemption.nextPauseIsLonger);
    _animateAddingTime(Duration(seconds: rewardRedemptionPause));

    return officialPause;
  }

  // This method is automatically called every seconds
  void _updateCounter() {
    if (!_firstSessionStarted &&
        _stopWatchStatus != StopWatchStatus.initializing) {
      if (timerHasStartedCallback != null) timerHasStartedCallback!();
      _firstSessionStarted = true;
    }

    if (_stopWatchStatus == StopWatchStatus.inPreSessionCountdown) {
      // Decrement the counter, if it gets to zeros advance the session
      int newTimerValue = _timer.inSeconds - 1;
      if (newTimerValue <= 0) {
        _stopWatchStatus = StopWatchStatus.inSession;
        _currentSession = 0;
        newTimerValue = _activeDuration;
        if (preSessionCountdownHasFinishedGuiCallback != null) {
          preSessionCountdownHasFinishedGuiCallback!();
        }
      }
      _timer = Duration(seconds: newTimerValue);
    } else if (_stopWatchStatus == StopWatchStatus.inSession) {
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
        newTimerValue = _activeDuration;
      }
      _timer = Duration(seconds: newTimerValue);
    }

    notifyListeners();
  }
}
