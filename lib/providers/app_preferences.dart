import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/common/config.dart';

class AppPreferences with ChangeNotifier {
  final Directory _saveDirectory;
  static String get _saveFilename => 'preferences.json';
  String get _saveFilePath => _saveFilePathFactory(_saveDirectory);
  static String _saveFilePathFactory(Directory directory) =>
      '${directory.path}/$_saveFilename';

  String? pomodoroRunningImagePath;

  AppPreferences._({
    required Directory directory,
    this.pomodoroRunningImagePath,
  }) : _saveDirectory = directory;

  static Future<AppPreferences> factory({reload = true}) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${documentDirectory.path}/$appName');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final savedFile = File(_saveFilePathFactory(directory));
    Map<String, dynamic>? previousPreferences;
    if (reload && await savedFile.exists()) {
      previousPreferences = jsonDecode(await savedFile.readAsString());
    }
    return AppPreferences._(
        directory: directory,
        pomodoroRunningImagePath:
            previousPreferences?['pomodoroRunningImagePath']);
  }

  Map<String, dynamic> get _serializePreferences => {
        'pomodoroRunningImagePath': pomodoroRunningImagePath,
      };

  static AppPreferences of(context, {listen = false}) =>
      Provider.of(context, listen: listen);

  void copyImage({required Directory imagePath}) {
    // copy(imagePath.path);
  }

  void savePreferences() async {
    final file = File(_saveFilePath);
    await file.writeAsString(json.encode(_serializePreferences));
  }
}
