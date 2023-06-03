import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/file_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/int_selector_tile.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTimerConfiguration(context),
            const Divider(),
            _buildImageSelectors(context),
            const Divider(),
            ElevatedButton(
              onPressed: startTimerCallback,
              style: ThemeButton.elevated,
              child: const Text(
                'Start timer',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerConfiguration(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        IntSelectorTile(
          title: 'Number of sessions',
          initialValue: AppPreferences.of(context, listen: false).nbOfSession,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).nbOfSession = value;
            _savePreferences(context);
          },
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Session duration (min)',
          initialValue: AppPreferences.of(context, listen: false)
              .sessionDuration
              .inMinutes,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).sessionDuration =
                Duration(minutes: value);
            _savePreferences(context);
          },
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Pause duration (min)',
          initialValue:
              AppPreferences.of(context, listen: false).pauseDuration.inMinutes,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).pauseDuration =
                Duration(minutes: value);
            _savePreferences(context);
          },
        ),
      ],
    );
  }

  Widget _buildImageSelectors(BuildContext context) {
    final appPreferences = AppPreferences.of(context);

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
              await appPreferences
                  .setActiveBackgroundImagePath(filename)
                  .then((value) => _savePreferences(context));
            }),
        FileSelectorTile(
            title: 'Paused image',
            path: appPreferences.pauseBackgroundImagePath == null
                ? null
                : basename(appPreferences.pauseBackgroundImagePath!),
            selectFileCallback: () async {
              final filename = await _pickFile(context);
              if (filename == null) return;
              await appPreferences
                  .setPauseBackgroundImagePath(filename)
                  .then((value) => _savePreferences(context));
            }),
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

  void _savePreferences(context) {
    AppPreferences.of(context, listen: false).save();
  }
}
