import 'dart:async';

import 'package:common_lib/models/preferenced_element.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StopWatchStatus { initializing, inSession, inPauseSession, paused, done }

class PomodoroStatus with ChangeNotifier {
  int _nbSessions = 0;
  int get nbSessions => _nbSessions;
  set nbSessions(int value) {
    _nbSessions = value;
    notifyListeners();
  }

  bool _firstSessionStarted = false;
  int _currentSession = 0;
  int get currentSession => _currentSession;

  Duration _focusSessionDuration = const Duration();
  Duration get sessionDuration => _focusSessionDuration;
  set sessionDuration(Duration duration) {
    _focusSessionDuration = duration;
    if (_stopWatchStatus == StopWatchStatus.initializing) {
      _timer = duration;
    }
    notifyListeners();
  }

  Duration _pauseSessionDuration = const Duration();
  Duration get pauseSessionDuration => _pauseSessionDuration;
  set pauseSessionDuration(Duration duration) {
    _pauseSessionDuration = duration;
    notifyListeners();
  }

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
  void reset({
    required PreferencedInt nbSessions,
    required PreferencedDuration focusSessionDuration,
    required PreferencedDuration pauseSessionDuration,
    bool notify = true,
  }) {
    // Reset all the internal states
    _nbSessions = nbSessions.value;
    _firstSessionStarted = false;
    _currentSession = 0;
    _focusSessionDuration = focusSessionDuration.value;
    _pauseSessionDuration = pauseSessionDuration.value;

    _stopWatchStatus = StopWatchStatus.initializing;
    _timer = Duration(seconds: _focusSessionDuration.inSeconds);

    if (notify) notifyListeners();
  }

  // CONSTRUCTORS
  PomodoroStatus({required this.sessionHasFinishedCallback}) {
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateCounter());
  }
  static PomodoroStatus of(BuildContext context, {listen = true}) =>
      Provider.of<PomodoroStatus>(context, listen: listen);

  Map<String, dynamic> serialize() => {
        'nbSessions': nbSessions,
        'currentSession': currentSession,
        'focusSessionDuration': sessionDuration.inSeconds,
        'pauseSessionDuration': pauseSessionDuration.inSeconds,
        'stopWatchStatus': stopWatchStatus.index,
        'timer': timer.inSeconds
      };

  void updateWebClient(map) {
    nbSessions = map['nbSessions'];
    _currentSession = map['currentSession'];
    sessionDuration = Duration(seconds: map['focusSessionDuration']);
    pauseSessionDuration = Duration(seconds: map['pauseSessionDuration']);
    _stopWatchStatus = StopWatchStatus.values[map['stopWatchStatus']];
    timer = Duration(seconds: map['timer']);
  }

  // TIMER CALLBACK
  Function() sessionHasFinishedCallback;

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
        sessionHasFinishedCallback();

        if (_currentSession + 1 == _nbSessions) {
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
          newTimerValue = _pauseSessionDuration.inSeconds;
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
        newTimerValue = _focusSessionDuration.inSeconds;
      }
      _timer = Duration(seconds: newTimerValue);
    }
    notifyListeners();
  }
}
