import 'dart:io';

import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/material.dart';

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
    final appPreferences = AppPreferences.of(context);

    late TextOnPomodoro textOnPomodoro;
    // If we are on initializing phase, show the text with the focus
    switch (_statusToShow(context)) {
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
    final textStyle = appPreferences.fontPomodoro.style(
        textStyle: TextStyle(
            color: textOnPomodoro.color,
            fontWeight: FontWeight.bold,
            fontSize: windowHeight * 0.11 * textOnPomodoro.size));

    final preferences = AppPreferences.of(context, listen: false);
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

    if ((status == StopWatchStatus.inPauseSession ||
            status == StopWatchStatus.paused) &&
        preferences.pauseBackgroundImage.image != null) {
      background = preferences.pauseBackgroundImage.image!;
      imageSize = preferences.pauseBackgroundImage.size;
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
