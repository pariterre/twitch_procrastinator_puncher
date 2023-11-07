import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({
    super.key,
    required this.textWithFocus,
  });

  // This is so during initialization phase, one can see what they are modifying
  final StopWatchStatus textWithFocus;

  StopWatchStatus _statusToShow(context) {
    final pomodoro = PomodoroStatus.of(context);

    return pomodoro.stopWatchStatus == StopWatchStatus.initializing
        ? textWithFocus
        : pomodoro.stopWatchStatus;
  }

  Widget _buildText(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);

    late TextOnPomodoro textOnPomodoro;
    // If we are on initializing phase, show the text with the focus
    switch (_statusToShow(context)) {
      case StopWatchStatus.initializing:
        textOnPomodoro = preferences.textDuringInitialization;
        break;
      case StopWatchStatus.inSession:
        textOnPomodoro = preferences.textDuringActiveSession;
        break;
      case StopWatchStatus.inPauseSession:
        textOnPomodoro = preferences.textDuringPauseSession;
        break;
      case StopWatchStatus.paused:
        textOnPomodoro = preferences.textDuringPause;
        break;
      case StopWatchStatus.done:
        textOnPomodoro = preferences.textDone;
        break;
    }
    final textStyle = preferences.fontPomodoro.style(
        textStyle: TextStyle(
            color: textOnPomodoro.color,
            fontWeight: FontWeight.bold,
            fontSize: windowHeight * 0.11 * textOnPomodoro.size));

    if (preferences.saveToTextFile.value) {
      final file = File('${appDirectory.path}/$textExportFilename');
      file.writeAsString(textOnPomodoro.formattedText(context));
    }

    return Positioned(
      left: textOnPomodoro.offset.dx * windowHeight * 0.001,
      right: 0,
      top: textOnPomodoro.offset.dy * windowHeight * 0.001,
      bottom: 0,
      child: Text(textOnPomodoro.formattedText(context),
          textAlign: TextAlign.center, style: textStyle),
    );
  }

  Widget _buildImage(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);

    Widget background = Container();
    double imageSize = 1;
    final status = _statusToShow(context);

    if (preferences.pauseBackgroundImage.image != null &&
        (status == StopWatchStatus.inPauseSession ||
            status == StopWatchStatus.paused)) {
      background = preferences.pauseBackgroundImage.image!;
      imageSize = preferences.pauseBackgroundImage.size;
    } else if (preferences.endBackgroundImage.image != null &&
        status == StopWatchStatus.done) {
      background = preferences.endBackgroundImage.image!;
      imageSize = preferences.endBackgroundImage.size;
    } else if (preferences.activeBackgroundImage.image != null) {
      background = preferences.activeBackgroundImage.image!;
      imageSize = preferences.activeBackgroundImage.size;
    }

    return SizedBox(width: windowHeight * 0.6 * imageSize, child: background);
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: windowHeight * 0.6,
      height: windowHeight * 0.6,
      child: Stack(
        alignment: Alignment.center,
        children: [_buildImage(context), _buildText(context)],
      ),
    );
  }
}
