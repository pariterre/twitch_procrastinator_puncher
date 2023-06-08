import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_pomorodo_timer/models/app_fonts.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';

export 'package:twitch_pomorodo_timer/models/app_fonts.dart';

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

  // Sound at end of sessions
  String? _endActiveSessionSoundFilename;
  String? get endActiveSessionSoundFilePath =>
      _endActiveSessionSoundFilename == null
          ? null
          : _path(preferencesDirectory, _endActiveSessionSoundFilename!);
  Future<void> setEndActiveSessionSoundFilePath(String? value) async {
    if (value == null) {
      _endActiveSessionSoundFilename = null;
    } else {
      _endActiveSessionSoundFilename = await _copyFile(original: value);
    }
    _save();
  }

  // Sound at end of pause
  String? _endPauseSessionSoundFilename;
  String? get endPauseSessionSoundFilePath =>
      _endPauseSessionSoundFilename == null
          ? null
          : _path(preferencesDirectory, _endPauseSessionSoundFilename!);
  Future<void> setEndPauseSessionSoundFilePath(String? value) async {
    if (value == null) {
      _endPauseSessionSoundFilename = null;
    } else {
      _endPauseSessionSoundFilename = await _copyFile(original: value);
    }
    _save();
  }

  // Sound at end of pause
  String? _endWorkingSoundFilename;
  String? get endWorkingSoundFilePath => _endWorkingSoundFilename == null
      ? null
      : _path(preferencesDirectory, _endWorkingSoundFilename!);
  Future<void> setWorkingSoundFilePath(String? value) async {
    if (value == null) {
      _endWorkingSoundFilename = null;
    } else {
      _endWorkingSoundFilename = await _copyFile(original: value);
    }
    _save();
  }

  // Colors of the app
  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    ThemeColor().background = _backgroundColor;
    _save();
  }

  AppFonts _fontPomodoro;
  AppFonts get fontPomodoro => _fontPomodoro;
  set fontPomodoro(AppFonts value) {
    _fontPomodoro = value;
    _save();
  }

  Color _backgroundColorHallOfFame;
  Color get backgroundColorHallOfFame => _backgroundColorHallOfFame;
  set backgroundColorHallOfFame(Color value) {
    _backgroundColorHallOfFame = value;
    ThemeColor().hallOfFame = backgroundColorHallOfFame;
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

  AppFonts _fontHallOfFame;
  AppFonts get fontHallOfFame => _fontHallOfFame;
  set fontHallOfFame(AppFonts value) {
    _fontHallOfFame = value;
    _save();
  }

  Color _textColorHallOfFame;
  Color get textColorHallOfFame => _textColorHallOfFame;
  set textColorHallOfFame(Color value) {
    _textColorHallOfFame = value;
    ThemeColor().hallOfFameText = textColorHallOfFame;
    _save();
  }

  PlainText textWhitelist;
  PlainText textBlacklist;
  PlainText textHallOfFameTitle;
  PlainText textHallOfFameName;
  PlainText textHallOfFameToday;
  PlainText textHallOfFameAlltime;
  PlainText textHallOfFameTotal;

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
    // Read the previously saved preference file if it exists
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

    // Call the real constructor
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
        endActiveSessionSoundFilename:
            previousPreferences?['endActiveSessionSoundFilename'],
        endPauseSessionSoundFilename:
            previousPreferences?['endPauseSessionSoundFilename'],
        endWorkingSoundFilename:
            previousPreferences?['endWorkingSoundFilename'],
        backgroundColor: previousPreferences?['backgroundColor'] ?? 0xFF00FF00,
        fontPomodoro: previousPreferences?['fontPomodoro'] ?? 0,
        backgroundColorHallOfFame:
            previousPreferences?['backgroundColorHallOfFame'] ?? 0xFF2D4AA8,
        textColorHallOfFame:
            previousPreferences?['textColorHallOfFame'] ?? 0xFFFFFFFF,
        textDuringInitialization: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringInitialization'],
            defaultText: 'Welcome!'),
        textDuringActiveSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringActiveSession'],
            defaultText: r'Session {currentSession}/{maxSessions}\n{timer}!'),
        textDuringPauseSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPauseSession'],
            defaultText: r'Pause\n{timer}!'),
        textDuringPause: TextOnPomodoro.deserialize(previousPreferences?['textDuringPause'],
            defaultText: r'Pause!'),
        textDone: TextOnPomodoro.deserialize(previousPreferences?['textDone'],
            defaultText: r'Congratulation!'),
        useHallOfFame: previousPreferences?['useHallOfFame'] ?? true,
        mustFollowForFaming: previousPreferences?['mustFollowForFaming'] ?? true,
        hallOfFameScrollVelocity: previousPreferences?['hallOfFameScrollVelocity'] ?? 2000,
        textNewcomersGreetings: TextToChat.deserialize(previousPreferences?['textNewcomersGreetings'], defaultText: r'Welcome to {username} who has joined for the first time!'),
        textUserHasConnectedGreetings: TextToChat.deserialize(previousPreferences?['textUserHasConnectedGreetings'], defaultText: r'Welcome back to {username} who has joined us!'),
        textWhitelist: PlainText.deserialize(previousPreferences?['textWhitelist'], defaultText: r''),
        textBlacklist: PlainText.deserialize(previousPreferences?['textBlacklist'], defaultText: r''),
        fontHallOfFame: previousPreferences?['fontHallOfFame'] ?? 0,
        textHallOfFameTitle: PlainText.deserialize(previousPreferences?['textHallOfFameTitle'], defaultText: r'Hall of fame'),
        textHallOfFameName: PlainText.deserialize(previousPreferences?['textHallOfFameName'], defaultText: r'Name of the viewers'),
        textHallOfFameToday: PlainText.deserialize(previousPreferences?['textHallOfFameToday'], defaultText: r'Today'),
        textHallOfFameAlltime: PlainText.deserialize(previousPreferences?['textHallOfFameAlltime'], defaultText: r'All time'),
        textHallOfFameTotal: PlainText.deserialize(previousPreferences?['textHallOfFameTotal'], defaultText: r'Total'),
        lastVisitedDirectory: Directory(previousPreferences?['lastVisitedDirectory'] ?? documentDirectory.path));
  }

  AppPreferences._({
    required int nbSessions,
    required Duration sessionDuration,
    required Duration pauseDuration,
    required Directory directory,
    required String? activeBackgroundImageFilename,
    required String? pauseBackgroundImageFilename,
    required String? endActiveSessionSoundFilename,
    required String? endPauseSessionSoundFilename,
    required String? endWorkingSoundFilename,
    required int backgroundColor,
    required int fontPomodoro,
    required int backgroundColorHallOfFame,
    required int textColorHallOfFame,
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
    required int fontHallOfFame,
    required this.textHallOfFameTitle,
    required this.textHallOfFameName,
    required this.textHallOfFameToday,
    required this.textHallOfFameAlltime,
    required this.textHallOfFameTotal,
    required Directory lastVisitedDirectory,
  })  : _nbSessions = nbSessions,
        _sessionDuration = sessionDuration,
        _pauseDuration = pauseDuration,
        preferencesDirectory = directory,
        _activeBackgroundImageFilename = activeBackgroundImageFilename,
        _pauseBackgroundImageFilename = pauseBackgroundImageFilename,
        _endActiveSessionSoundFilename = endActiveSessionSoundFilename,
        _endPauseSessionSoundFilename = endPauseSessionSoundFilename,
        _endWorkingSoundFilename = endWorkingSoundFilename,
        _backgroundColor = Color(backgroundColor),
        _fontPomodoro = AppFonts.values[fontPomodoro],
        _backgroundColorHallOfFame = Color(backgroundColorHallOfFame),
        _textColorHallOfFame = Color(textColorHallOfFame),
        _useHallOfFame = useHallOfFame,
        _mustFollowForFaming = mustFollowForFaming,
        _hallOfFameScrollVelocity = hallOfFameScrollVelocity,
        _fontHallOfFame = AppFonts.values[fontHallOfFame],
        _lastVisitedDirectory = lastVisitedDirectory {
    // Set the necessary callback
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
    textHallOfFameTotal.saveCallback = _save;

    // Force the repainting of the colors
    this.backgroundColor = _backgroundColor;
    this.backgroundColorHallOfFame = _backgroundColorHallOfFame;
    this.textColorHallOfFame = _textColorHallOfFame;
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
        'endActiveSessionSoundFilename': _endActiveSessionSoundFilename,
        'endPauseSessionSoundFilename': _endPauseSessionSoundFilename,
        'endWorkingSoundFilename': _endWorkingSoundFilename,
        'backgroundColor': _backgroundColor.value,
        'fontPomodoro': _fontPomodoro.index,
        'backgroundColorHallOfFame': _backgroundColorHallOfFame.value,
        'textColorHallOfFame': _textColorHallOfFame.value,
        'textDuringInitialization': textDuringInitialization.serialize(),
        'textDuringActiveSession': textDuringActiveSession.serialize(),
        'textDuringPauseSession': textDuringPauseSession.serialize(),
        'textDuringPause': textDuringPause.serialize(),
        'textDone': textDone.serialize(),
        'useHallOfFame': _useHallOfFame,
        'mustFollowForFaming': _mustFollowForFaming,
        'hallOfFameScrollVelocity': _hallOfFameScrollVelocity,
        'textNewcomersGreetings': textNewcomersGreetings.serialize(),
        'textUserHasConnectedGreetings':
            textUserHasConnectedGreetings.serialize(),
        'textWhitelist': textWhitelist.serialize(),
        'textBlacklist': textBlacklist.serialize(),
        'fontHallOfFame': _fontHallOfFame.index,
        'textHallOfFameTitle': textHallOfFameTitle.serialize(),
        'textHallOfFameName': textHallOfFameName.serialize(),
        'textHallOfFameToday': textHallOfFameToday.serialize(),
        'textHallOfFameAlltime': textHallOfFameAlltime.serialize(),
        'textHallOfFameTotal': textHallOfFameTotal.serialize(),
        'lastVisitedDirectory': _lastVisitedDirectory.path,
      };
}
