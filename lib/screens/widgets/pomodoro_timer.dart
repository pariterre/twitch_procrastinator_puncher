import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({super.key});

  String _formatString(context, String original) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    return original
        .replaceAll('{timer}', durationAsString(pomodoro.timer))
        .replaceAll(r'\n', '\n')
        .replaceAll('{currentSession}', pomodoro.currentSession.toString())
        .replaceAll('{maxSessions}', pomodoro.nbSessions.toString());
  }

  Widget _buildText(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final textStyle = TextStyle(
        color: ThemeColor.text,
        fontWeight: FontWeight.bold,
        fontSize: windowHeight * 0.11);
    final pomodoro = PomodoroStatus.of(context);
    final appPreferences = AppPreferences.of(context);

    if (pomodoro.stopWatchStatus == StopWatchStatus.initialized) {
      return Text('Bienvenue!', style: textStyle);
    } else if (pomodoro.stopWatchStatus == StopWatchStatus.inSession) {
      String text =
          _formatString(context, appPreferences.textDuringActiveSession);
      return Positioned(
        left: 0,
        top: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(fontSize: windowHeight * 0.11)),
          ],
        ),
      );
    } else if (pomodoro.stopWatchStatus == StopWatchStatus.paused) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Pause!',
              style: textStyle.copyWith(fontSize: windowHeight * 0.12)),
          Text(durationAsString(pomodoro.timer), style: textStyle),
        ],
      );
    } else if (pomodoro.stopWatchStatus == StopWatchStatus.done) {
      return Text('Bravo!', style: textStyle);
    } else {
      return Text('Wrong state', style: textStyle);
    }
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
      child: Stack(
        alignment: Alignment.center,
        children: [background, _buildText(context)],
      ),
    );
  }
}
