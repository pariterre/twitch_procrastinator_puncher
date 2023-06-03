import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';

class ConfigurationRoom extends StatefulWidget {
  const ConfigurationRoom({super.key});

  static const route = '/configuration-room';

  @override
  State<ConfigurationRoom> createState() => _ConfigurationRoomState();
}

class _ConfigurationRoomState extends State<ConfigurationRoom> {
  TwitchManager? _twitchManager;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    // _twitchManager ??=
    //     ModalRoute.of(context)!.settings.arguments as TwitchManager;
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: windowHeight,
        decoration: const BoxDecoration(color: ThemeColor.greenScreen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ConfigurationBoard(
              startTimerCallback: () => {},
            ),
            ConfigurationBoard(
              startTimerCallback: () => {},
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({super.key, required this.startTimerCallback});

  final Function() startTimerCallback;

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

  Widget _buildFileSelector(
    BuildContext context, {
    required String title,
    required String? path,
    required Function() selectFileCallback,
  }) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: ThemeColor.text, fontWeight: FontWeight.bold)),
          Padding(
            padding: EdgeInsets.only(left: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: windowHeight * 0.3,
                  child: Text(
                    path ?? 'None selected',
                    style: const TextStyle(color: ThemeColor.text),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectFileCallback,
                  style: ThemeButton.elevated,
                  child: const Text('Select',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _savePreferences(context) {
    final appPreferences = AppPreferences.of(context, listen: false);
    appPreferences.save();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Preferences saved'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    final appPreferences = AppPreferences.of(context);

    return Container(
      width: windowHeight * 0.5,
      decoration: const BoxDecoration(color: ThemeColor.main),
      padding: EdgeInsets.only(bottom: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFileSelector(context,
              title: 'Active image',
              path: appPreferences.activeBackgroundImagePath == null
                  ? null
                  : basename(appPreferences.activeBackgroundImagePath!),
              selectFileCallback: () async {
            final filename = await _pickFile(context);
            if (filename == null) return;
            await appPreferences.setActiveBackgroundImagePath(filename);
          }),
          _buildFileSelector(context,
              title: 'Paused image',
              path: appPreferences.pauseBackgroundImagePath == null
                  ? null
                  : basename(appPreferences.pauseBackgroundImagePath!),
              selectFileCallback: () async {
            final filename = await _pickFile(context);
            if (filename == null) return;
            await appPreferences.setPauseBackgroundImagePath(filename);
          }),
          ElevatedButton(
            onPressed: () => _savePreferences(context),
            style: ThemeButton.elevated,
            child: const Text(
              'Save preferences',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Divider(),
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
    );
  }
}
