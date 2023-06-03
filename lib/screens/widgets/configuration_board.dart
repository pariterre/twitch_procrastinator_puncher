import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/file_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/int_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/string_selector_tile.dart';

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({super.key, required this.startTimerCallback});

  final Function() startTimerCallback;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Container(
      width: windowHeight * 0.5,
      decoration: const BoxDecoration(color: ThemeColor.main),
      padding: EdgeInsets.only(bottom: padding),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
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
    );
  }

  Widget _buildController(context) {
    final padding = ThemePadding.normal(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pomodoro controller',
            style:
                TextStyle(color: ThemeColor.text, fontWeight: FontWeight.bold)),
        SizedBox(height: padding),
        Center(
          child: ElevatedButton(
            onPressed: startTimerCallback,
            style: ThemeButton.elevated,
            child: const Text(
              'Start timer',
              style: TextStyle(color: Colors.black),
            ),
          ),
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
          onValidChange: (value) =>
              AppPreferences.of(context, listen: false).nbSessions = value,
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Session duration (min)',
          initialValue: AppPreferences.of(context, listen: false)
              .sessionDuration
              .inMinutes,
          onValidChange: (value) => AppPreferences.of(context, listen: false)
              .sessionDuration = Duration(minutes: value),
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Pause duration (min)',
          initialValue:
              AppPreferences.of(context, listen: false).pauseDuration.inMinutes,
          onValidChange: (value) => AppPreferences.of(context, listen: false)
              .pauseDuration = Duration(minutes: value),
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
                '\\n is a linebreak',
            child: Icon(
              Icons.info,
              color: Colors.white,
            ),
          ),
        ]),
        SizedBox(height: padding),
        StringSelectorTile(
          title: 'Text during session',
          initialValue: appPreferences.textDuringActiveSession,
          onValidChange: (String value) =>
              appPreferences.textDuringActiveSession = value,
        ),
      ],
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
