import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/common/config.dart';

String _path(Directory directory, String filename) =>
    '${directory.path}/$filename';

class AppPreferences with ChangeNotifier {
  // Path to save data folder and file
  final Directory _saveDirectory;
  String get _preferencesPath => _path(_saveDirectory, preferencesFilename);

  // Background image during the countdown
  String? _activeBackgroundImagePath;
  String? get activeBackgroundImagePath => _activeBackgroundImagePath;
  Future<void> setActiveBackgroundImagePath(String? value) async {
    if (value == null) {
      _activeBackgroundImagePath = null;
      notifyListeners();
    }
    _activeBackgroundImagePath = await _copyFile(original: value!);
    notifyListeners();
  }

  // Background image during the pause
  String? _pauseBackgroundImagePath;
  String? get pauseBackgroundImagePath => _pauseBackgroundImagePath;
  Future<void> setPauseBackgroundImagePath(String? value) async {
    if (value == null) {
      _pauseBackgroundImagePath = null;
      notifyListeners();
    }
    _pauseBackgroundImagePath = await _copyFile(original: value!);
    notifyListeners();
  }

  ///
  /// Vanilla way to save the current preferences to a file
  void savePreferences() async {
    final file = File(_preferencesPath);
    await file.writeAsString(json.encode(_serializePreferences));
  }

  // CONSTRUCTOR AND ACCESSORS

  ///
  /// Main accessor of the AppPreference
  static AppPreferences of(context, {listen = true}) =>
      Provider.of(context, listen: listen);

  ///
  /// Main constructor of the AppPreferences. If [reload] is false, then the
  /// previously saved folder is ignored
  static Future<AppPreferences> factory({reload = true}) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${documentDirectory.path}/$appName');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final preferencesFile = File(_path(directory, preferencesFilename));
    Map<String, dynamic>? previousPreferences;
    if (reload && await preferencesFile.exists()) {
      previousPreferences = jsonDecode(await preferencesFile.readAsString());
    }
    return AppPreferences._(
        directory: directory,
        pomodoroRunningImagePath:
            previousPreferences?['pomodoroRunningImagePath']);
  }

  AppPreferences._({
    required Directory directory,
    String? pomodoroRunningImagePath,
  })  : _saveDirectory = directory,
        _activeBackgroundImagePath = pomodoroRunningImagePath;

  // INTERNAL METHODS

  ///
  /// Copy a file and return the new path
  Future<String> _copyFile({required String original}) async {
    final file = File(original);
    final newFile = await file.copy(_path(_saveDirectory, basename(file.path)));
    return newFile.path;
  }

  ///
  /// Serialize all the values
  Map<String, dynamic> get _serializePreferences => {
        'pomodoroRunningImagePath': activeBackgroundImagePath,
      };
}
