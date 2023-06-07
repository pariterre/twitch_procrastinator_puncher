import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';

String _path(Directory directory, String filename) =>
    '${directory.path}/$filename';

String get rootPath => Platform.isWindows ? r'C:\' : '/';

class AppPreferences with ChangeNotifier {
  // Path to save data folder and file
  final Directory preferencesDirectory;
  String get _preferencesPath =>
      _path(preferencesDirectory, preferencesFilename);
  Directory _lastVisitedDirectory = Directory('');
  Directory get lastVisitedDirectory => _lastVisitedDirectory;

  // Number of total session
  int _nbSessions;
  int get nbSessions => _nbSessions;
  set nbSessions(int value) {
    _nbSessions = value;
    _save();
  }

  // Session time
  Duration _sessionDuration;
  Duration get sessionDuration => _sessionDuration;
  set sessionDuration(Duration value) {
    _sessionDuration = value;
    _save();
  }

  // Pause time
  Duration _pauseDuration;
  Duration get pauseDuration => _pauseDuration;
  set pauseDuration(Duration value) {
    _pauseDuration = value;
    _save();
  }

  // Background image during the countdown
  String? _activeBackgroundImageFilename;
  String? get activeBackgroundImagePath =>
      _activeBackgroundImageFilename == null
          ? null
          : _path(preferencesDirectory, _activeBackgroundImageFilename!);
  Future<void> setActiveBackgroundImagePath(String? value) async {
    if (value == null) {
      _activeBackgroundImageFilename = null;
    } else {
      _activeBackgroundImageFilename = await _copyFile(original: value);
    }
    _save();
  }

  // Background image during the pause
  String? _pauseBackgroundImageFilename;
  String? get pauseBackgroundImagePath => _pauseBackgroundImageFilename == null
      ? null
      : _path(preferencesDirectory, _pauseBackgroundImageFilename!);
  Future<void> setPauseBackgroundImagePath(String? value) async {
    if (value == null) {
      _pauseBackgroundImageFilename = null;
    } else {
      _pauseBackgroundImageFilename = await _copyFile(original: value);
    }
    _save();
  }

  // Foreground texts
  TextOnPomodoro textDuringInitialization;
  TextOnPomodoro textDuringActiveSession;
  TextOnPomodoro textDuringPauseSession;
  TextOnPomodoro textDuringPause;
  TextOnPomodoro textDone;

  bool _useHallOfFame;
  bool get useHallOfFame => _useHallOfFame;
  set useHallOfFame(bool value) {
    _useHallOfFame = value;
    _save();
  }

  bool _mustFollowForFaming;
  bool get mustFollowForFaming => _mustFollowForFaming;
  set mustFollowForFaming(bool value) {
    _mustFollowForFaming = value;
    _save();
  }

  int _hallOfFameScrollVelocity;
  int get hallOfFameScrollVelocity => _hallOfFameScrollVelocity;
  set hallOfFameScrollVelocity(int value) {
    _hallOfFameScrollVelocity += value;
    if (_hallOfFameScrollVelocity <= 0) _hallOfFameScrollVelocity = 0;
    _save();
  }

  TextToChat textNewcomersGreetings;
  TextToChat textUserHasConnectedGreetings;
  PlainText textWhitelist;
  PlainText textBlacklist;
  PlainText textHallOfFameTitle;
  PlainText textHallOfFameName;
  PlainText textHallOfFameToday;
  PlainText textHallOfFameAlltime;

  ///
  /// Save the current preferences to a file
  void _save() async {
    final file = File(_preferencesPath);
    await file.writeAsString(json.encode(_serializePreferences));
    notifyListeners();
  }

  // CONSTRUCTOR AND ACCESSORS

  ///
  /// Main accessor of the AppPreference
  static AppPreferences of(BuildContext context, {listen = true}) =>
      Provider.of<AppPreferences>(context, listen: listen);

  ///
  /// Main constructor of the AppPreferences. If [reload] is false, then the
  /// previously saved folder is ignored
  static Future<AppPreferences> factory({reload = true}) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${documentDirectory.path}/$twitchAppName');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final preferencesFile = File(_path(directory, preferencesFilename));
    Map<String, dynamic>? previousPreferences;
    if (reload && await preferencesFile.exists()) {
      try {
        previousPreferences = jsonDecode(await preferencesFile.readAsString());
      } catch (_) {
        previousPreferences = null;
      }
    }
    return AppPreferences._(
        nbSessions: previousPreferences?['nbSessions'] ?? 0,
        sessionDuration:
            Duration(seconds: previousPreferences?['sessionTime'] ?? 0),
        pauseDuration:
            Duration(seconds: previousPreferences?['pauseDuration'] ?? 0),
        directory: directory,
        activeBackgroundImageFilename:
            previousPreferences?['activeBackgroundImageFilename'],
        pauseBackgroundImageFilename:
            previousPreferences?['pauseBackgroundImageFilename'],
        textDuringInitialization: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringInitialization'],
            defaultText: 'Bienvenue!'),
        textDuringActiveSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringActiveSession'],
            defaultText: r'Session {currentSession}/{maxSessions}\n{timer}!'),
        textDuringPauseSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPauseSession'],
            defaultText: r'Pause\n{timer}!'),
        textDuringPause: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPause'],
            defaultText: r'Pause!'),
        textDone: TextOnPomodoro.deserialize(previousPreferences?['textDone'],
            defaultText: r'Bravo!'),
        useHallOfFame: previousPreferences?['useHallOfFame'] ?? true,
        mustFollowForFaming:
            previousPreferences?['mustFollowForFaming'] ?? true,
        hallOfFameScrollVelocity: previousPreferences?['hallOfFameScrollVelocity'] ?? 2000,
        textNewcomersGreetings: TextToChat.deserialize(previousPreferences?['textNewcomersGreetings'], defaultText: r'Welcome to {username} who has joined for the first time!'),
        textUserHasConnectedGreetings: TextToChat.deserialize(previousPreferences?['textUserHasConnectedGreetings'], defaultText: r'Welcome back to {username} who has joined us!'),
        textWhitelist: PlainText.deserialize(previousPreferences?['textWhitelist'], defaultText: r''),
        textBlacklist: PlainText.deserialize(previousPreferences?['textBlacklist'], defaultText: r''),
        textHallOfFameTitle: PlainText.deserialize(previousPreferences?['textHallOfFameTitle'], defaultText: r'Hall of fame'),
        textHallOfFameName: PlainText.deserialize(previousPreferences?['textHallOfFameName'], defaultText: r'Name of the viewers'),
        textHallOfFameToday: PlainText.deserialize(previousPreferences?['textHallOfFameToday'], defaultText: r'Today'),
        textHallOfFameAlltime: PlainText.deserialize(previousPreferences?['textHallOfFameAlltime'], defaultText: r'All time'),
        lastVisitedDirectory: Directory(previousPreferences?['lastVisitedDirectory'] ?? documentDirectory.path));
  }

  AppPreferences._({
    required int nbSessions,
    required Duration sessionDuration,
    required Duration pauseDuration,
    required Directory directory,
    required String? activeBackgroundImageFilename,
    required String? pauseBackgroundImageFilename,
    required this.textDuringInitialization,
    required this.textDuringActiveSession,
    required this.textDuringPauseSession,
    required this.textDuringPause,
    required this.textDone,
    required bool useHallOfFame,
    required bool mustFollowForFaming,
    required int hallOfFameScrollVelocity,
    required this.textNewcomersGreetings,
    required this.textUserHasConnectedGreetings,
    required this.textWhitelist,
    required this.textBlacklist,
    required this.textHallOfFameTitle,
    required this.textHallOfFameName,
    required this.textHallOfFameToday,
    required this.textHallOfFameAlltime,
    required Directory lastVisitedDirectory,
  })  : _nbSessions = nbSessions,
        _sessionDuration = sessionDuration,
        _pauseDuration = pauseDuration,
        preferencesDirectory = directory,
        _activeBackgroundImageFilename = activeBackgroundImageFilename,
        _pauseBackgroundImageFilename = pauseBackgroundImageFilename,
        _useHallOfFame = useHallOfFame,
        _mustFollowForFaming = mustFollowForFaming,
        _hallOfFameScrollVelocity = hallOfFameScrollVelocity,
        _lastVisitedDirectory = lastVisitedDirectory {
    textDuringInitialization.saveCallback = _save;
    textDuringActiveSession.saveCallback = _save;
    textDuringPauseSession.saveCallback = _save;
    textDuringPause.saveCallback = _save;
    textDone.saveCallback = _save;
    textNewcomersGreetings.saveCallback = _save;
    textUserHasConnectedGreetings.saveCallback = _save;
    textBlacklist.saveCallback = _save;
    textHallOfFameTitle.saveCallback = _save;
    textHallOfFameName.saveCallback = _save;
    textHallOfFameToday.saveCallback = _save;
    textHallOfFameAlltime.saveCallback = _save;
  }

  // INTERNAL METHODS

  ///
  /// Copy a file and return the name of the new file
  Future<String> _copyFile({required String original}) async {
    final file = File(original);
    final newFile =
        await file.copy(_path(preferencesDirectory, basename(file.path)));

    _lastVisitedDirectory = file.parent;
    return basename(newFile.path);
  }

  ///
  /// Serialize all the values
  Map<String, dynamic> get _serializePreferences => {
        'nbSessions': _nbSessions,
        'sessionTime': _sessionDuration.inSeconds,
        'pauseDuration': _pauseDuration.inSeconds,
        'activeBackgroundImageFilename': _activeBackgroundImageFilename,
        'pauseBackgroundImageFilename': _pauseBackgroundImageFilename,
        'textDuringInitialization': textDuringInitialization.serialize(),
        'textDuringActiveSession': textDuringActiveSession.serialize(),
        'textDuringPauseSession': textDuringPauseSession.serialize(),
        'textDuringPause': textDuringPause.serialize(),
        'textDone': textDone.serialize(),
        'useHallOfFame': _useHallOfFame,
        'mustFollowForFaming': _mustFollowForFaming,
        'hallOfFameScrollVelocity': _hallOfFameScrollVelocity,
        'textNewcomersGreetings': textNewcomersGreetings.serialize(),
        'textUserHasConnectedGreetings': textUserHasConnectedGreetings.serialize(),
        'textWhitelist': textWhitelist.serialize(),
        'textBlacklist': textBlacklist.serialize(),
        'textHallOfFameTitle': textHallOfFameTitle.serialize(),
        'textHallOfFameName': textHallOfFameName.serialize(),
        'textHallOfFameToday': textHallOfFameToday.serialize(),
        'textHallOfFameAlltime': textHallOfFameAlltime.serialize(),
        'lastVisitedDirectory': _lastVisitedDirectory.path,
      };
}
