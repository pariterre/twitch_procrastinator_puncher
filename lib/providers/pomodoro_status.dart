import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum StopWatchStatus { initialized, inSession, inPauseSession, paused, done }

String durationAsString(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class PomodoroStatus with ChangeNotifier {
  int _nbSessions = 0;
  int get nbSessions => _nbSessions;
  set nbSessions(int value) {
    _nbSessions = value;
    notifyListeners();
  }

  int _currentSession = 0;
  int get currentSession => _currentSession;
  Duration _focusSessionDuration = const Duration();
  Duration get focusSessionDuration => _focusSessionDuration;
  set focusSessionDuration(Duration duration) {
    _focusSessionDuration = duration;
    if (_stopWatchStatus == StopWatchStatus.initialized) {
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
  StopWatchStatus _stopWatchStatus = StopWatchStatus.initialized;
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
    required int nbSession,
    required Duration focusSessionDuration,
    required Duration pauseSessionDuration,
    bool notify = true,
  }) {
    // Reset all the internal states
    _nbSessions = nbSession;
    _currentSession = 0;
    _focusSessionDuration = focusSessionDuration;
    _pauseSessionDuration = pauseSessionDuration;

    _stopWatchStatus = StopWatchStatus.initialized;
    _timer = Duration(seconds: _focusSessionDuration.inSeconds);

    if (notify) notifyListeners();
  }

  // CONSTRUCTORS
  PomodoroStatus() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateCounter());
  }
  static PomodoroStatus of(BuildContext context, {listen = true}) =>
      Provider.of<PomodoroStatus>(context, listen: listen);

  // TIMER CALLBACK

  // This method is automatically called every seconds
  void _updateCounter() {
    if (_stopWatchStatus == StopWatchStatus.inSession) {
      // Decrement the counter, if it gets to zeros advance the session
      int newTimerValue = _timer.inSeconds - 1;
      if (newTimerValue <= 0) {
        if (_currentSession == _nbSessions) {
          // If we got to last session, it is over
          _stopWatchStatus = StopWatchStatus.done;
          newTimerValue = 0;
        } else {
          // Otherwise start the pause
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
        _currentSession++;
        _stopWatchStatus = StopWatchStatus.inSession;
        newTimerValue = _focusSessionDuration.inSeconds;
      }
      _timer = Duration(seconds: newTimerValue);
    }
    notifyListeners();
  }
}
