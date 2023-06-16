import 'dart:convert';
import 'dart:io';

import 'package:common_lib/models/app_fonts.dart';
import 'package:common_lib/models/app_theme.dart';
import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

export 'package:common_lib/models/app_fonts.dart';

String _path(Directory directory, String filename) =>
    '${directory.path}/$filename';

String get rootPath => Platform.isWindows ? r'C:\' : '/';

class AppPreferences with ChangeNotifier {
  // Path to save data folder and file
  Directory _saveDirectory;
  Directory get saveDirectory => _saveDirectory;
  String get _savePath => _path(saveDirectory, preferencesFilename);

  Directory _lastVisitedDirectory = Directory('');
  Directory get lastVisitedDirectory => _lastVisitedDirectory;

  // Number of total session
  PreferencedInt nbSessions;

  // Session time
  PreferencedDuration sessionDuration;
  PreferencedDuration pauseDuration;

  // Background image during the countdown
  PreferencedImageFile activeBackgroundImage;
  PreferencedImageFile pauseBackgroundImage;

  // Sound during count downd
  PreferencedSoundFile endActiveSessionSound;
  PreferencedSoundFile endPauseSessionSound;
  PreferencedSoundFile endWorkingSound;

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

  bool _saveToTextFile;
  bool get saveToTextFile => _saveToTextFile;
  set saveToTextFile(bool value) {
    _saveToTextFile = value;
    _save();
  }

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

  PreferencedText textWhitelist;
  PreferencedText textBlacklist;
  PreferencedText textHallOfFameTitle;
  PreferencedText textHallOfFameName;
  PreferencedText textHallOfFameToday;
  PreferencedText textHallOfFameAlltime;
  PreferencedText textHallOfFameTotal;

  ///
  /// Save the current preferences to a file
  void _save() async {
    if (!kIsWeb) {
      final file = File(_savePath);
      await file.writeAsString(json.encode(serialize()));
    }
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
    late final Directory directory;
    if (kIsWeb) {
      directory = Directory('');
    } else {
      final documentDirectory = await getApplicationDocumentsDirectory();
      directory = Directory('${documentDirectory.path}/$twitchAppName');
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
    }

    final preferencesFile = File(_path(directory, preferencesFilename));
    Map<String, dynamic>? previousPreferences;
    if (!kIsWeb && reload && await preferencesFile.exists()) {
      try {
        previousPreferences = jsonDecode(await preferencesFile.readAsString());
      } catch (_) {
        previousPreferences = null;
      }
    }

    // Call the real constructor
    return AppPreferences._(
        directory: directory,
        nbSessions:
            PreferencedInt.deserialize(previousPreferences?['nbSessions'], 0),
        sessionDuration: PreferencedDuration.deserialize(
            previousPreferences?['sessionDuration'], 0),
        pauseDuration: PreferencedDuration.deserialize(
            previousPreferences?['pauseDuration'], 0),
        activeBackgroundImage: PreferencedImageFile.deserialize(
            directory, previousPreferences?['activeBackgroundImage']),
        pauseBackgroundImage: PreferencedImageFile.deserialize(
            directory, previousPreferences?['pauseBackgroundImage']),
        endActiveSessionSound: PreferencedSoundFile.deserialize(
            directory, previousPreferences?['endActiveSessionSound']),
        endPauseSessionSound: PreferencedSoundFile.deserialize(
            directory, previousPreferences?['endPauseSessionSound']),
        endWorkingSound: PreferencedSoundFile.deserialize(
            directory, previousPreferences?['endWorkingSound']),
        backgroundColor: previousPreferences?['backgroundColor'] ?? 0xFFFFFFFF,
        fontPomodoro: previousPreferences?['fontPomodoro'] ?? 0,
        backgroundColorHallOfFame:
            previousPreferences?['backgroundColorHallOfFame'] ?? 0xFF2D4AA8,
        textColorHallOfFame:
            previousPreferences?['textColorHallOfFame'] ?? 0xFF000000,
        textDuringInitialization: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringInitialization'], 'Welcome!'),
        textDuringActiveSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringActiveSession'],
            r'Session {currentSession}/{maxSessions}\n{timer}!'),
        textDuringPauseSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPauseSession'], r'Pause\n{timer}!'),
        textDuringPause: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPause'], r'Pause!'),
        textDone: TextOnPomodoro.deserialize(
            previousPreferences?['textDone'], r'Congratulation!'),
        saveToTextFile: previousPreferences?['saveToTextFile'] ?? false,
        useHallOfFame: previousPreferences?['useHallOfFame'] ?? true,
        mustFollowForFaming:
            previousPreferences?['mustFollowForFaming'] ?? true,
        hallOfFameScrollVelocity:
            previousPreferences?['hallOfFameScrollVelocity'] ?? 2000,
        textNewcomersGreetings: TextToChat.deserialize(
            previousPreferences?['textNewcomersGreetings'],
            r'Welcome to {username} who has joined for the first time!'),
        textUserHasConnectedGreetings: TextToChat.deserialize(previousPreferences?['textUserHasConnectedGreetings'], r'Welcome back to {username} who has joined us!'),
        textWhitelist: PreferencedText.deserialize(previousPreferences?['textWhitelist']),
        textBlacklist: PreferencedText.deserialize(previousPreferences?['textBlacklist']),
        fontHallOfFame: previousPreferences?['fontHallOfFame'] ?? 0,
        textHallOfFameTitle: PreferencedText.deserialize(previousPreferences?['textHallOfFameTitle'], 'Hall of fame'),
        textHallOfFameName: PreferencedText.deserialize(previousPreferences?['textHallOfFameName'], 'Name of the viewers'),
        textHallOfFameToday: PreferencedText.deserialize(previousPreferences?['textHallOfFameToday'], 'Today'),
        textHallOfFameAlltime: PreferencedText.deserialize(previousPreferences?['textHallOfFameAlltime'], 'All time'),
        textHallOfFameTotal: PreferencedText.deserialize(previousPreferences?['textHallOfFameTotal'], 'Total'),
        lastVisitedDirectory: Directory(previousPreferences?['lastVisitedDirectory'] ?? directory.path));
  }

  AppPreferences._({
    required Directory directory,
    required this.nbSessions,
    required this.sessionDuration,
    required this.pauseDuration,
    required this.activeBackgroundImage,
    required this.pauseBackgroundImage,
    required this.endActiveSessionSound,
    required this.endPauseSessionSound,
    required this.endWorkingSound,
    required int backgroundColor,
    required int fontPomodoro,
    required int backgroundColorHallOfFame,
    required int textColorHallOfFame,
    required this.textDuringInitialization,
    required this.textDuringActiveSession,
    required this.textDuringPauseSession,
    required this.textDuringPause,
    required this.textDone,
    required bool saveToTextFile,
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
  })  : _saveDirectory = directory,
        _backgroundColor = Color(backgroundColor),
        _fontPomodoro = AppFonts.values[fontPomodoro],
        _backgroundColorHallOfFame = Color(backgroundColorHallOfFame),
        _textColorHallOfFame = Color(textColorHallOfFame),
        _saveToTextFile = saveToTextFile,
        _useHallOfFame = useHallOfFame,
        _mustFollowForFaming = mustFollowForFaming,
        _hallOfFameScrollVelocity = hallOfFameScrollVelocity,
        _fontHallOfFame = AppFonts.values[fontHallOfFame],
        _lastVisitedDirectory = lastVisitedDirectory {
    // Set the necessary callback
    nbSessions.onChanged = _save;

    sessionDuration.onChanged = _save;
    pauseDuration.onChanged = _save;

    activeBackgroundImage.onChanged = _save;
    activeBackgroundImage.lastVisitedFolderCallback = _setLastVisited;
    pauseBackgroundImage.onChanged = _save;
    pauseBackgroundImage.lastVisitedFolderCallback = _setLastVisited;

    endActiveSessionSound.onChanged = _save;
    endActiveSessionSound.lastVisitedFolderCallback = _setLastVisited;
    endPauseSessionSound.onChanged = _save;
    endPauseSessionSound.lastVisitedFolderCallback = _setLastVisited;
    endWorkingSound.onChanged = _save;
    endWorkingSound.lastVisitedFolderCallback = _setLastVisited;

    textDuringInitialization.onChanged = _save;
    textDuringActiveSession.onChanged = _save;
    textDuringPauseSession.onChanged = _save;
    textDuringPause.onChanged = _save;
    textDone.onChanged = _save;
    textNewcomersGreetings.onChanged = _save;
    textUserHasConnectedGreetings.onChanged = _save;
    textBlacklist.onChanged = _save;
    textHallOfFameTitle.onChanged = _save;
    textHallOfFameName.onChanged = _save;
    textHallOfFameToday.onChanged = _save;
    textHallOfFameAlltime.onChanged = _save;
    textHallOfFameTotal.onChanged = _save;

    // Force the repainting of the colors
    this.backgroundColor = _backgroundColor;
    this.backgroundColorHallOfFame = _backgroundColorHallOfFame;
    this.textColorHallOfFame = _textColorHallOfFame;
  }

  // INTERNAL METHODS
  ///
  /// Copy a file and return the name of the new file
  void _setLastVisited(Directory path) {
    _lastVisitedDirectory = path;
  }

  ///
  /// Serialize all the values
  Map<String, dynamic> serialize() => {
        'directory': saveDirectory.path,
        'nbSessions': nbSessions.serialize(),
        'sessionDuration': sessionDuration.serialize(),
        'pauseDuration': pauseDuration.serialize(),
        'activeBackgroundImage': activeBackgroundImage.serialize(),
        'pauseBackgroundImage': pauseBackgroundImage.serialize(),
        'endActiveSessionSound': endActiveSessionSound.serialize(),
        'endPauseSessionSound': endPauseSessionSound.serialize(),
        'endWorkingSound': endWorkingSound.serialize(),
        'backgroundColor': _backgroundColor.value,
        'fontPomodoro': _fontPomodoro.index,
        'backgroundColorHallOfFame': _backgroundColorHallOfFame.value,
        'textColorHallOfFame': _textColorHallOfFame.value,
        'textDuringInitialization': textDuringInitialization.serialize(),
        'textDuringActiveSession': textDuringActiveSession.serialize(),
        'textDuringPauseSession': textDuringPauseSession.serialize(),
        'textDuringPause': textDuringPause.serialize(),
        'textDone': textDone.serialize(),
        'saveToTextFile': _saveToTextFile,
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

  void updateFromSerialized(map) {
    nbSessions = PreferencedInt.deserialize(map['nbSessions']);
    sessionDuration = PreferencedDuration.deserialize(map['sessionDuration']);
    pauseDuration = PreferencedDuration.deserialize(map['pauseDuration']);
    _saveDirectory = Directory(map['directory']);
    activeBackgroundImage = PreferencedImageFile.deserialize(
        saveDirectory, map['activeBackgroundImageFilename']);
    pauseBackgroundImage = PreferencedImageFile.deserialize(
        saveDirectory, map['pauseBackgroundImageFilename']);
    endActiveSessionSound = PreferencedSoundFile(
        saveDirectory, map['endActiveSessionSoundFilename']);
    endPauseSessionSound =
        PreferencedSoundFile(saveDirectory, map['endPauseSessionSound']);
    endWorkingSound =
        PreferencedSoundFile(saveDirectory, map['endWorkingSound']);
    backgroundColor = Color(map['backgroundColor']);
    fontPomodoro = AppFonts.values[map['fontPomodoro']];
    backgroundColorHallOfFame = Color(map['backgroundColorHallOfFame']);
    textColorHallOfFame = Color(map['textColorHallOfFame']);
    textDuringInitialization =
        TextOnPomodoro.deserialize(map['textDuringInitialization']);
    textDuringActiveSession =
        TextOnPomodoro.deserialize(map['textDuringActiveSession']);
    textDuringPauseSession =
        TextOnPomodoro.deserialize(map['textDuringPauseSession']);
    textDuringPause = TextOnPomodoro.deserialize(map['textDuringPause']);
    textDone = TextOnPomodoro.deserialize(map['textDone']);
    saveToTextFile = map['saveToTextFile'];
    useHallOfFame = map['useHallOfFame'];
    mustFollowForFaming = map['mustFollowForFaming'];
    hallOfFameScrollVelocity = map['hallOfFameScrollVelocity'];
    textNewcomersGreetings =
        TextToChat.deserialize(map['textNewcomersGreetings']);
    textUserHasConnectedGreetings =
        TextToChat.deserialize(map['textUserHasConnectedGreetings']);
    textWhitelist = PreferencedText.deserialize(map['textWhitelist']);
    textBlacklist = PreferencedText.deserialize(map['textBlacklist']);
    fontHallOfFame = AppFonts.values[map['fontHallOfFame']];
    textHallOfFameTitle =
        PreferencedText.deserialize(map['textHallOfFameTitle']);
    textHallOfFameName =
        PreferencedText.deserialize(map?['textHallOfFameName']);
    textHallOfFameToday =
        PreferencedText.deserialize(map['textHallOfFameToday']);
    textHallOfFameAlltime =
        PreferencedText.deserialize(map['textHallOfFameAlltime']);
    textHallOfFameTotal =
        PreferencedText.deserialize(map['textHallOfFameTotal']);
    _lastVisitedDirectory = Directory(map['lastVisitedDirectory']);
  }
}
