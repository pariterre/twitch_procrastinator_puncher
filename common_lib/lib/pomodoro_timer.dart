import 'dart:convert';
import 'dart:io';

import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({
    super.key,
    required this.textWithFocus,
  });

  // This is so during initialization phase, one can see what they are modifying
  final StopWatchStatus textWithFocus;

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  StopWatchStatus _statusToShow(context) {
    final pomodoro = PomodoroStatus.of(context);

    return pomodoro.stopWatchStatus == StopWatchStatus.initializing
        ? widget.textWithFocus
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
    if (preferences.saveToTextFile) {
      final file =
          File('${preferences.saveDirectory.path}/$textExportFilename');
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

  Uint8List? imageBackground;

  Future<Uint8List> coucou() async {
    final channel = ws.WebSocket(Uri.parse('ws://localhost:9876'));
    channel.messages.listen((message) {
      final image = jsonDecode(jsonDecode(message)["bytes"]) as List;
      imageBackground = Uint8List(image.length);
      for (var i = 0; i < image.length; i++) {
        imageBackground![i] = image[i];
      }
    });
    return Uint8List(100);
  }

  Widget _buildImage(context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);

    Widget background = Container();
    double imageSize = 1;
    final status = _statusToShow(context);

    if (kIsWeb) {
      background = FutureBuilder(
        future: coucou(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          return imageBackground == null
              ? Container()
              : Image.memory(imageBackground!);
        },
      );
    }
    if (!kIsWeb) {
      if ((status == StopWatchStatus.inPauseSession ||
              status == StopWatchStatus.paused) &&
          preferences.pauseBackgroundImage.file != null) {
        background = Image.file(preferences.pauseBackgroundImage.file!);
        imageSize = preferences.pauseBackgroundImage.size;
      } else if (preferences.activeBackgroundImage.file != null) {
        background = Image.file(preferences.activeBackgroundImage.file!);
        imageSize = preferences.activeBackgroundImage.size;
      }
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
