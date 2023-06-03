import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/file_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/int_selector_tile.dart';

class ConfigurationBoard extends StatefulWidget {
  const ConfigurationBoard({super.key, required this.startTimerCallback});

  final Function() startTimerCallback;

  @override
  State<ConfigurationBoard> createState() => _ConfigurationBoardState();
}

class _ConfigurationBoardState extends State<ConfigurationBoard> {
  late final _nbSessionTextController = TextEditingController(
      text: AppPreferences.of(this.context, listen: false).nbOfSession > 0
          ? AppPreferences.of(this.context, listen: false)
              .nbOfSession
              .toString()
          : '');
  late final _sessionDurationTextController = TextEditingController(
      text: AppPreferences.of(this.context, listen: false)
                  .sessionDuration
                  .inMinutes >
              0
          ? AppPreferences.of(this.context, listen: false)
              .sessionDuration
              .inMinutes
              .toString()
          : '');

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
            SizedBox(height: 2 * padding),
            ElevatedButton(
              onPressed: () => _savePreferences(context),
              style: ThemeButton.elevated,
              child: const Text(
                'Save preferences',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Divider(),
            ElevatedButton(
              onPressed: widget.startTimerCallback,
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
          controller: _nbSessionTextController,
          onValidChange: (value) =>
              AppPreferences.of(context, listen: false).nbOfSession = value,
        ),
        SizedBox(height: padding),
        IntSelectorTile(
          title: 'Session duration (min)',
          controller: _sessionDurationTextController,
          onValidChange: (value) => AppPreferences.of(context, listen: false)
              .sessionDuration = Duration(minutes: value),
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
              await appPreferences.setActiveBackgroundImagePath(filename);
            }),
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
    final appPreferences = AppPreferences.of(context, listen: false);
    appPreferences.save();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Preferences saved'),
    ));
  }
}
