import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({
    super.key,
    required this.textWithFocus,
  });

  // This is so during initialization phase, one can see what they are modifying
  final StopWatchStatus textWithFocus;

  Widget _buildText(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final textStyle = TextStyle(
        color: ThemeColor().pomodoroText,
        fontWeight: FontWeight.bold,
        fontSize: windowHeight * 0.11);
    final pomodoro = PomodoroStatus.of(context);
    final appPreferences = AppPreferences.of(context);

    late TextOnPomodoro textOnPomodoro;
    // If we are on initializing phase, show the text with the focus
    switch (pomodoro.stopWatchStatus == StopWatchStatus.initializing
        ? textWithFocus
        : pomodoro.stopWatchStatus) {
      case StopWatchStatus.initializing:
        textOnPomodoro = appPreferences.textDuringInitialization;
        break;
      case StopWatchStatus.inSession:
        textOnPomodoro = appPreferences.textDuringActiveSession;
        break;
      case StopWatchStatus.inPauseSession:
        textOnPomodoro = appPreferences.textDuringPauseSession;
        break;
      case StopWatchStatus.paused:
        textOnPomodoro = appPreferences.textDuringPause;
        break;
      case StopWatchStatus.done:
        textOnPomodoro = appPreferences.textDone;
        break;
    }

    return Positioned(
      left: textOnPomodoro.offset.dx,
      top: textOnPomodoro.offset.dy,
      child: Text(textOnPomodoro.formattedText(context),
          textAlign: TextAlign.center,
          style: textStyle.copyWith(
              fontSize: windowHeight * 0.11 * textOnPomodoro.size)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final appPreferences = AppPreferences.of(context);

    final background = (appPreferences.activeBackgroundImagePath == null)
        ? Container()
        : Image.file(File(appPreferences.activeBackgroundImagePath!));

    return SizedBox(
      height: windowHeight * 0.6,
      width: windowHeight * 0.6,
      child: Stack(
        alignment: Alignment.center,
        children: [background, _buildText(context)],
      ),
    );
  }
}
