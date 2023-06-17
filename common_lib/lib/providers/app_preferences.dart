import 'dart:convert';
import 'dart:io';

import 'package:common_lib/models/app_fonts.dart';
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
  PreferencedColor backgroundColor;
  PreferencedColor backgroundColorHallOfFame;

  // Foreground texts
  TextOnPomodoro textDuringInitialization;
  TextOnPomodoro textDuringActiveSession;
  TextOnPomodoro textDuringPauseSession;
  TextOnPomodoro textDuringPause;
  TextOnPomodoro textDone;

  AppFonts get fontPomodoro => textDuringInitialization.font;
  set fontPomodoro(AppFonts value) {
    textDuringInitialization.font = value;
    textDuringActiveSession.font = value;
    textDuringPauseSession.font = value;
    textDuringPause.font = value;
    textDone.font = value;
  }

  // Some options
  PreferencedBool saveToTextFile;
  PreferencedBool useHallOfFame;
  PreferencedBool mustFollowForFaming;

  PreferencedInt hallOfFameScrollVelocity;

  TextToChat textNewcomersGreetings;
  TextToChat textUserHasConnectedGreetings;

  PreferencedText textWhitelist;
  PreferencedText textBlacklist;
  PreferencedText textHallOfFameTitle;
  PreferencedText textHallOfFameName;
  PreferencedText textHallOfFameToday;
  PreferencedText textHallOfFameAlltime;
  PreferencedText textHallOfFameTotal;

  AppFonts get fontHallOfFame => textHallOfFameTitle.font;
  set fontHallOfFame(AppFonts value) {
    textHallOfFameTitle.font = value;
    textHallOfFameName.font = value;
    textHallOfFameToday.font = value;
    textHallOfFameAlltime.font = value;
    textHallOfFameTotal.font = value;
  }

  Color get textColorHallOfFame => textHallOfFameTitle.color;
  set textColorHallOfFame(Color value) {
    textHallOfFameTitle.color = value;
    textHallOfFameName.color = value;
    textHallOfFameToday.color = value;
    textHallOfFameAlltime.color = value;
    textHallOfFameTotal.color = value;
  }

  ///
  /// Save the current preferences to a file
  void _save() async {
    if (!kIsWeb) {
      final file = File('${_saveDirectory.path}/$preferencesFilename');
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
        lastVisitedDirectory: Directory(
            previousPreferences?['lastVisitedDirectory'] ?? directory.path),
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
        backgroundColor: PreferencedColor.deserialize(
            previousPreferences?['backgroundColor'], 0xFFFFFFFF),
        backgroundColorHallOfFame: PreferencedColor.deserialize(
            previousPreferences?['backgroundColorHallOfFame'], 0xFF2D4AA8),
        fontPomodoro: previousPreferences?['fontPomodoro'] ?? 0,
        textColorHallOfFame:
            previousPreferences?['textColorHallOfFame'] ?? 0xFF000000,
        textDuringInitialization: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringInitialization'], 'Welcome!'),
        textDuringActiveSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringActiveSession'],
            r'Session {currentSession}/{maxSessions}\n{timer}!'),
        textDuringPauseSession: TextOnPomodoro.deserialize(
            previousPreferences?['textDuringPauseSession'], r'Pause\n{timer}!'),
        textDuringPause:
            TextOnPomodoro.deserialize(previousPreferences?['textDuringPause'], r'Pause!'),
        textDone: TextOnPomodoro.deserialize(previousPreferences?['textDone'], r'Congratulation!'),
        saveToTextFile: PreferencedBool.deserialize(previousPreferences?['saveToTextFile'], false),
        useHallOfFame: PreferencedBool.deserialize(previousPreferences?['useHallOfFame'], true),
        mustFollowForFaming: PreferencedBool.deserialize(previousPreferences?['mustFollowForFaming'], true),
        hallOfFameScrollVelocity: PreferencedInt.deserialize(previousPreferences?['hallOfFameScrollVelocity'], 2000),
        textNewcomersGreetings: TextToChat.deserialize(previousPreferences?['textNewcomersGreetings'], r'Welcome to {username} who has joined for the first time!'),
        textUserHasConnectedGreetings: TextToChat.deserialize(previousPreferences?['textUserHasConnectedGreetings'], r'Welcome back to {username} who has joined us!'),
        textWhitelist: PreferencedText.deserialize(previousPreferences?['textWhitelist']),
        textBlacklist: PreferencedText.deserialize(previousPreferences?['textBlacklist']),
        fontHallOfFame: previousPreferences?['fontHallOfFame'] ?? 0,
        textHallOfFameTitle: PreferencedText.deserialize(previousPreferences?['textHallOfFameTitle'], 'Hall of fame'),
        textHallOfFameName: PreferencedText.deserialize(previousPreferences?['textHallOfFameName'], 'Name of the viewers'),
        textHallOfFameToday: PreferencedText.deserialize(previousPreferences?['textHallOfFameToday'], 'Today'),
        textHallOfFameAlltime: PreferencedText.deserialize(previousPreferences?['textHallOfFameAlltime'], 'All time'),
        textHallOfFameTotal: PreferencedText.deserialize(previousPreferences?['textHallOfFameTotal'], 'Total'));
  }

  AppPreferences._({
    required Directory directory,
    required Directory lastVisitedDirectory,
    required this.nbSessions,
    required this.sessionDuration,
    required this.pauseDuration,
    required this.activeBackgroundImage,
    required this.pauseBackgroundImage,
    required this.endActiveSessionSound,
    required this.endPauseSessionSound,
    required this.endWorkingSound,
    required this.backgroundColor,
    required this.backgroundColorHallOfFame,
    required int fontPomodoro,
    required int textColorHallOfFame,
    required this.textDuringInitialization,
    required this.textDuringActiveSession,
    required this.textDuringPauseSession,
    required this.textDuringPause,
    required this.textDone,
    required this.saveToTextFile,
    required this.useHallOfFame,
    required this.mustFollowForFaming,
    required this.hallOfFameScrollVelocity,
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
  })  : _saveDirectory = directory,
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

    backgroundColor.onChanged = _save;
    backgroundColorHallOfFame.onChanged = _save;

    textDuringInitialization.onChanged = _save;
    textDuringActiveSession.onChanged = _save;
    textDuringPauseSession.onChanged = _save;
    textDuringPause.onChanged = _save;
    textDone.onChanged = _save;

    saveToTextFile.onChanged = _save;
    useHallOfFame.onChanged = _save;
    mustFollowForFaming.onChanged = _save;

    hallOfFameScrollVelocity.onChanged = _save;
    textNewcomersGreetings.onChanged = _save;
    textUserHasConnectedGreetings.onChanged = _save;
    textBlacklist.onChanged = _save;

    textHallOfFameTitle.onChanged = _save;
    textHallOfFameName.onChanged = _save;
    textHallOfFameToday.onChanged = _save;
    textHallOfFameAlltime.onChanged = _save;
    textHallOfFameTotal.onChanged = _save;

    // Force the repainting of the colors
    this.fontPomodoro = AppFonts.values[fontPomodoro];
    this.fontHallOfFame = AppFonts.values[fontHallOfFame];
    this.textColorHallOfFame = Color(textColorHallOfFame);
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
        'lastVisitedDirectory': _lastVisitedDirectory.path,
        'nbSessions': nbSessions.serialize(),
        'sessionDuration': sessionDuration.serialize(),
        'pauseDuration': pauseDuration.serialize(),
        'activeBackgroundImage': activeBackgroundImage.serialize(),
        'pauseBackgroundImage': pauseBackgroundImage.serialize(),
        'endActiveSessionSound': endActiveSessionSound.serialize(),
        'endPauseSessionSound': endPauseSessionSound.serialize(),
        'endWorkingSound': endWorkingSound.serialize(),
        'backgroundColor': backgroundColor.serialize(),
        'backgroundColorHallOfFame': backgroundColorHallOfFame.serialize(),
        'fontPomodoro': fontPomodoro.index,
        'textColorHallOfFame': textColorHallOfFame.value,
        'textDuringInitialization': textDuringInitialization.serialize(),
        'textDuringActiveSession': textDuringActiveSession.serialize(),
        'textDuringPauseSession': textDuringPauseSession.serialize(),
        'textDuringPause': textDuringPause.serialize(),
        'textDone': textDone.serialize(),
        'saveToTextFile': saveToTextFile.serialize(),
        'useHallOfFame': useHallOfFame.serialize(),
        'mustFollowForFaming': mustFollowForFaming.serialize(),
        'hallOfFameScrollVelocity': hallOfFameScrollVelocity.serialize(),
        'textNewcomersGreetings': textNewcomersGreetings.serialize(),
        'textUserHasConnectedGreetings':
            textUserHasConnectedGreetings.serialize(),
        'textWhitelist': textWhitelist.serialize(),
        'textBlacklist': textBlacklist.serialize(),
        'fontHallOfFame': fontHallOfFame.index,
        'textHallOfFameTitle': textHallOfFameTitle.serialize(),
        'textHallOfFameName': textHallOfFameName.serialize(),
        'textHallOfFameToday': textHallOfFameToday.serialize(),
        'textHallOfFameAlltime': textHallOfFameAlltime.serialize(),
        'textHallOfFameTotal': textHallOfFameTotal.serialize(),
      };

  void updateFromSerialized(map) {
    _saveDirectory = Directory(map['directory']);
    _lastVisitedDirectory = Directory(map['lastVisitedDirectory']);

    nbSessions = PreferencedInt.deserialize(map['nbSessions']);
    sessionDuration = PreferencedDuration.deserialize(map['sessionDuration']);
    pauseDuration = PreferencedDuration.deserialize(map['pauseDuration']);

    activeBackgroundImage = PreferencedImageFile.deserialize(
        saveDirectory, map['activeBackgroundImageFilename']);
    pauseBackgroundImage = PreferencedImageFile.deserialize(
        saveDirectory, map['pauseBackgroundImageFilename']);

    endActiveSessionSound = PreferencedSoundFile.deserialize(
        saveDirectory, map['endActiveSessionSoundFilename']);
    endPauseSessionSound = PreferencedSoundFile.deserialize(
        saveDirectory, map['endPauseSessionSound']);
    endWorkingSound =
        PreferencedSoundFile.deserialize(saveDirectory, map['endWorkingSound']);

    backgroundColor = PreferencedColor.deserialize(map['backgroundColor']);
    backgroundColorHallOfFame =
        PreferencedColor.deserialize(map['backgroundColorHallOfFame']);

    fontPomodoro = AppFonts.values[map['fontPomodoro']];
    textColorHallOfFame = Color(map['textColorHallOfFame']);
    textDuringInitialization =
        TextOnPomodoro.deserialize(map['textDuringInitialization']);
    textDuringActiveSession =
        TextOnPomodoro.deserialize(map['textDuringActiveSession']);
    textDuringPauseSession =
        TextOnPomodoro.deserialize(map['textDuringPauseSession']);
    textDuringPause = TextOnPomodoro.deserialize(map['textDuringPause']);
    textDone = TextOnPomodoro.deserialize(map['textDone']);
    saveToTextFile = PreferencedBool.deserialize(map['saveToTextFile']);
    useHallOfFame = PreferencedBool.deserialize(map['useHallOfFame']);
    mustFollowForFaming =
        PreferencedBool.deserialize(map['mustFollowForFaming']);
    hallOfFameScrollVelocity =
        PreferencedInt.deserialize(map['hallOfFameScrollVelocity']);
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
  }
}
