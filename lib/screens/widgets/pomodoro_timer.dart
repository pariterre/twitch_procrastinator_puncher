import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({super.key});

  Widget _buildText(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final textStyle = TextStyle(
        color: ThemeColor.text,
        fontWeight: FontWeight.bold,
        fontSize: windowHeight * 0.11);
    final pomodoro = PomodoroStatus.of(context);
    final appPreferences = AppPreferences.of(context);

    late TextOnPomodoro textOnPomodoro;
    switch (pomodoro.stopWatchStatus) {
      case StopWatchStatus.initialized:
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
      height: windowHeight * 0.75,
      width: windowHeight * 0.75,
      child: Stack(
        alignment: Alignment.center,
        children: [background, _buildText(context)],
      ),
    );
  }
}
