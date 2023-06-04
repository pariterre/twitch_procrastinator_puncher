import 'dart:io';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/file_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/int_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/string_selector_tile.dart';
import 'package:twitch_pomorodo_timer/widgets/plus_or_minus.dart';

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({
    super.key,
    required this.startTimerCallback,
    required this.pauseTimerCallback,
    required this.resetTimerCallback,
  });

  final Function() startTimerCallback;
  final Function() pauseTimerCallback;
  final Function() resetTimerCallback;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Container(
      width: windowHeight * 0.5,
      height: windowHeight * 0.7,
      decoration: const BoxDecoration(color: ThemeColor.main),
      padding: EdgeInsets.only(bottom: padding),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildController(context),
              const Divider(),
              _buildTimerConfiguration(context),
              const Divider(),
              _buildImageSelectors(context),
              const Divider(),
              _buildTextSelectors(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildController(context) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final padding = ThemePadding.normal(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pomodoro controller',
            style:
                TextStyle(color: ThemeColor.text, fontWeight: FontWeight.bold)),
        SizedBox(height: padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: pomodoro.stopWatchStatus == StopWatchStatus.inSession
                  ? pauseTimerCallback
                  : startTimerCallback,
              style: ThemeButton.elevated,
              child: Text(
                pomodoro.stopWatchStatus == StopWatchStatus.initialized
                    ? 'Start timer'
                    : pomodoro.stopWatchStatus == StopWatchStatus.paused
                        ? 'Resume timer'
                        : 'Pause timer',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: resetTimerCallback,
              style: ThemeButton.elevated,
              child: const Text(
                'Reset timer',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerConfiguration(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        IntSelectorTile(
          title: 'Number of sessions',
          initialValue: AppPreferences.of(context, listen: false).nbSessions,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).nbSessions = value;
            PomodoroStatus.of(context, listen: false).nbSessions = value;
          },
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Session duration (min)',
          initialValue: AppPreferences.of(context, listen: false)
              .sessionDuration
              .inMinutes,
          onValidChange: (value) {
            final duration = Duration(minutes: value);
            AppPreferences.of(context, listen: false).sessionDuration =
                duration;
            PomodoroStatus.of(context, listen: false).focusSessionDuration =
                duration;
          },
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Pause duration (min)',
          initialValue:
              AppPreferences.of(context, listen: false).pauseDuration.inMinutes,
          onValidChange: (value) {
            final duration = Duration(minutes: value);
            AppPreferences.of(context, listen: false).pauseDuration = duration;
            PomodoroStatus.of(context, listen: false).focusSessionDuration =
                duration;
          },
        ),
      ],
    );
  }

  Widget _buildImageSelectors(BuildContext context) {
    final appPreferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        FileSelectorTile(
            title: 'Active image',
            path: appPreferences.activeBackgroundImagePath == null
                ? null
                : basename(appPreferences.activeBackgroundImagePath!),
            selectFileCallback: () async {
              final filename = await _pickFile(context);
              if (filename == null) return;
              await appPreferences.setActiveBackgroundImagePath(filename);
            }),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Paused image',
            path: appPreferences.pauseBackgroundImagePath == null
                ? null
                : basename(appPreferences.pauseBackgroundImagePath!),
            selectFileCallback: () async {
              final filename = await _pickFile(context);
              if (filename == null) return;
              await appPreferences.setPauseBackgroundImagePath(filename);
            }),
      ],
    );
  }

  void _moveText(
      context, Function(Offset) textPointer, PressDirection direction) {
    final windowHeight = MediaQuery.of(context).size.height;
    switch (direction) {
      case PressDirection.up:
        textPointer(Offset(0, -windowHeight * 0.01));
        return;
      case PressDirection.right:
        textPointer(Offset(windowHeight * 0.01, 0));
        return;
      case PressDirection.down:
        textPointer(Offset(0, windowHeight * 0.01));
        return;
      case PressDirection.left:
        textPointer(Offset(-windowHeight * 0.01, 0));
        return;
    }
  }

  Widget _buildTextSelectors(BuildContext context) {
    final appPreferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        Row(children: [
          const Text(
            'Text to print on the images',
            style:
                TextStyle(color: ThemeColor.text, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: padding),
          const Tooltip(
            message: 'You can use tags that will change automatically\n'
                '{currentSession} is the current session\n'
                '{maxSessions} is the max sessions\n'
                '{timer} is the timer\n'
                '{sessionDuration} is the time of the focus sessions\n'
                '{pauseDuration} is the time of the pauses\n'
                '\\n is a linebreak',
            child: Icon(
              Icons.info,
              color: Colors.white,
            ),
          ),
        ]),
        SizedBox(height: padding),
        _buildStringSelectorTile(context,
            title: 'Text during initialization',
            textOnPomodoro: appPreferences.textDuringInitialization),
        _buildStringSelectorTile(context,
            title: 'Text during focus sessions',
            textOnPomodoro: appPreferences.textDuringActiveSession),
        _buildStringSelectorTile(context,
            title: 'Text during pause sessions',
            textOnPomodoro: appPreferences.textDuringPauseSession),
        _buildStringSelectorTile(context,
            title: 'Text during pauses',
            textOnPomodoro: appPreferences.textDuringPause),
        _buildStringSelectorTile(context,
            title: 'Text when done', textOnPomodoro: appPreferences.textDone),
      ],
    );
  }

  StringSelectorTile _buildStringSelectorTile(context,
      {required String title, required TextOnPomodoro textOnPomodoro}) {
    return StringSelectorTile(
      title: title,
      initialValue: textOnPomodoro.text,
      onTextChanged: (String value) => textOnPomodoro.text = value,
      onSizeChanged: (direction) => textOnPomodoro
          .increaseSize(direction == PlusOrMinusSelection.plus ? 0.01 : -0.01),
      onMoveText: (direction) {
        _moveText(context, textOnPomodoro.addToOffset, direction);
      },
    );
  }

  Future<String?> _pickFile(context) async {
    final appPreferences = AppPreferences.of(context, listen: false);
    final path = await FilesystemPicker.open(
      title: 'Open file',
      context: context,
      directory: appPreferences.lastVisitedDirectory,
      rootDirectory: Directory(rootPath),
      rootName: rootPath,
      fsType: FilesystemType.file,
      allowedExtensions: ['.jpg', '.png', '.jpeg'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );
    return path;
  }
}
