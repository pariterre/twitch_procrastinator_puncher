import 'dart:convert';
import 'dart:io';

import 'package:common_lib/models/app_fonts.dart';
import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:common_lib/models/preferenced_language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:common_lib/models/app_fonts.dart';

String get rootPath => Platform.isWindows ? r'C:\' : '/';

const Map<String, dynamic> _defaultValues = {
  'texts': 0,
  'nbSessions': 4,
  'sessionDuration': 50 * 60,
  'pauseDuration': 10 * 60,
  'activeBackgroundImage': null,
  'pauseBackgroundImage': null,
  'endActiveSessionSound': null,
  'endPauseSessionSound': null,
  'endWorkingSound': null,
  'backgroundColor': 0x00FFFFFF,
  'backgroundColorHallOfFame': 0xFF2D4AA8,
  'fontPomodoro': 1,
  'textColorHallOfFame': 0xFFFFFFFF,
  'textDuringInitialization': 'Welcome!',
  'textDuringActiveSession': r'Session {session}/{nbSessions}\n{timer}!',
  'textDuringPauseSession': r'Pause\n{timer}!',
  'textDuringPause': r'Pause!',
  'textDone': r'Congratulation!',
  'saveToTextFile': false,
  'useHallOfFame': true,
  'mustFollowForFaming': true,
  'hallOfFameScrollVelocity': 2000,
  'textTimerHasStarted': r'The session has started! Have a good work!',
  'textTimerActiveSessionHasEnded':
      r'The session {session} is done! Well done :)',
  'textTimerPauseHasEnded':
      'A new session has started, let\'s get back to work!',
  'textTimerWorkingHasEnded':
      r'We are done! Good job everyone, we have done {doneToday} sessions today, for a grand total of {done}!',
  'textNewcomersGreetings':
      r'Welcome to {username} who has joined for the first time!',
  'textUserHasConnectedGreetings':
      r'Welcome back to {username} who has joined us!',
  'textWhitelist': null,
  'textBlacklist': null,
  'fontHallOfFame': 1,
  'textHallOfFameTitle': 'Hall of fame',
  'textHallOfFameName': 'Name of the viewers',
  'textHallOfFameToday': 'Today',
  'textHallOfFameAlltime': 'All time',
  'textHallOfFameTotal': 'Total',
};

class AppPreferences with ChangeNotifier {
  static String get _savepath => '${appDirectory.path}/$preferencesFilename';

  // Everything related to the language
  PreferencedLanguage texts;

  // If the current AppPreferences is connected to the server (only relevent for
  // the web client side)
  bool isConnectedToServer = false;

  // Last visited directory when selecting a file
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

  TextToChat textTimerHasStarted;
  TextToChat textTimerActiveSessionHasEnded;
  TextToChat textTimerPauseHasEnded;
  TextToChat textTimerWorkingHasEnded;
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
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(preferencesFilename, jsonEncode(serialize()));
    } else {
      final file = File(_savepath);
      const encoder = JsonEncoder.withIndent('\t');
      await file.writeAsString(encoder.convert(serialize()));
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
    Future<String?> readPreferences() async {
      // Read the previously saved preference file if it exists
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(preferencesFilename);
      } else {
        final preferencesFile = File(_savepath);
        return await preferencesFile.readAsString();
      }
    }

    final preferencesAsString = await readPreferences();
    Map<String, dynamic>? previousPreferences;
    if (reload && preferencesAsString != null) {
      try {
        previousPreferences = jsonDecode(preferencesAsString);
      } catch (_) {
        previousPreferences = null;
      }
    }

    // Call the real constructor
    return AppPreferences._(
        lastVisitedDirectory:
            Directory(previousPreferences?['lastVisitedDirectory'] ?? ''),
        texts: PreferencedLanguage.deserialize(
            previousPreferences?['texts'], _defaultValues['texts']),
        nbSessions: PreferencedInt.deserialize(
            previousPreferences?['nbSessions'], _defaultValues['nbSessions']),
        sessionDuration: PreferencedDuration.deserialize(
            previousPreferences?['sessionDuration'],
            _defaultValues['sessionDuration']),
        pauseDuration: PreferencedDuration.deserialize(
            previousPreferences?['pauseDuration'],
            _defaultValues['pauseDuration']),
        activeBackgroundImage: PreferencedImageFile.deserialize(
            previousPreferences?['activeBackgroundImage']),
        pauseBackgroundImage: PreferencedImageFile.deserialize(
            previousPreferences?['pauseBackgroundImage']),
        endActiveSessionSound: PreferencedSoundFile.deserialize(
            previousPreferences?['endActiveSessionSound']),
        endPauseSessionSound: PreferencedSoundFile.deserialize(
            previousPreferences?['endPauseSessionSound']),
        endWorkingSound: PreferencedSoundFile.deserialize(
            previousPreferences?['endWorkingSound']),
        backgroundColor: PreferencedColor.deserialize(
            previousPreferences?['backgroundColor'],
            _defaultValues['backgroundColor']),
        backgroundColorHallOfFame: PreferencedColor.deserialize(
            previousPreferences?['backgroundColorHallOfFame'],
            _defaultValues['backgroundColorHallOfFame']),
        fontPomodoro: previousPreferences?['fontPomodoro'] ?? _defaultValues['fontPomodoro'],
        textColorHallOfFame: previousPreferences?['textColorHallOfFame'] ?? _defaultValues['textColorHallOfFame'],
        textDuringInitialization: TextOnPomodoro.deserialize(previousPreferences?['textDuringInitialization'], _defaultValues['textDuringInitialization']),
        textDuringActiveSession: TextOnPomodoro.deserialize(previousPreferences?['textDuringActiveSession'], _defaultValues['textDuringActiveSession']),
        textDuringPauseSession: TextOnPomodoro.deserialize(previousPreferences?['textDuringPauseSession'], _defaultValues['textDuringPauseSession']),
        textDuringPause: TextOnPomodoro.deserialize(previousPreferences?['textDuringPause'], _defaultValues['textDuringPause']),
        textDone: TextOnPomodoro.deserialize(previousPreferences?['textDone'], _defaultValues['textDone']),
        saveToTextFile: PreferencedBool.deserialize(previousPreferences?['saveToTextFile'], _defaultValues['saveToTextFile']),
        useHallOfFame: PreferencedBool.deserialize(previousPreferences?['useHallOfFame'], _defaultValues['useHallOfFame']),
        mustFollowForFaming: PreferencedBool.deserialize(previousPreferences?['mustFollowForFaming'], _defaultValues['mustFollowForFaming']),
        hallOfFameScrollVelocity: PreferencedInt.deserialize(previousPreferences?['hallOfFameScrollVelocity'], _defaultValues['hallOfFameScrollVelocity']),
        textTimerHasStarted: TextToChat.deserialize(previousPreferences?['textTimerHasStarted'], _defaultValues['textTimerHasStarted']),
        textTimerActiveSessionHasEnded: TextToChat.deserialize(previousPreferences?['textTimerActiveSessionHasEnded'], _defaultValues['textTimerActiveSessionHasEnded']),
        textTimerPauseHasEnded: TextToChat.deserialize(previousPreferences?['textTimerPauseHasEnded'], _defaultValues['textTimerPauseHasEnded']),
        textTimerWorkingHasEnded: TextToChat.deserialize(previousPreferences?['textTimerWorkingHasEnded'], _defaultValues['textTimerWorkingHasEnded']),
        textNewcomersGreetings: TextToChat.deserialize(previousPreferences?['textNewcomersGreetings'], _defaultValues['textNewcomersGreetings']),
        textUserHasConnectedGreetings: TextToChat.deserialize(previousPreferences?['textUserHasConnectedGreetings'], _defaultValues['textUserHasConnectedGreetings']),
        textWhitelist: PreferencedText.deserialize(previousPreferences?['textWhitelist']),
        textBlacklist: PreferencedText.deserialize(previousPreferences?['textBlacklist']),
        fontHallOfFame: previousPreferences?['fontHallOfFame'] ?? _defaultValues['fontHallOfFame'],
        textHallOfFameTitle: PreferencedText.deserialize(previousPreferences?['textHallOfFameTitle'], _defaultValues['textHallOfFameTitle']),
        textHallOfFameName: PreferencedText.deserialize(previousPreferences?['textHallOfFameName'], _defaultValues['textHallOfFameName']),
        textHallOfFameToday: PreferencedText.deserialize(previousPreferences?['textHallOfFameToday'], _defaultValues['textHallOfFameToday']),
        textHallOfFameAlltime: PreferencedText.deserialize(previousPreferences?['textHallOfFameAlltime'], _defaultValues['textHallOfFameAlltime']),
        textHallOfFameTotal: PreferencedText.deserialize(previousPreferences?['textHallOfFameTotal'], _defaultValues['textHallOfFameTotal']));
  }

  AppPreferences._({
    required Directory lastVisitedDirectory,
    required this.texts,
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
    required this.textTimerHasStarted,
    required this.textTimerActiveSessionHasEnded,
    required this.textTimerPauseHasEnded,
    required this.textTimerWorkingHasEnded,
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
  }) : _lastVisitedDirectory = lastVisitedDirectory {
    _addAllCallbacks();

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
        'lastVisitedDirectory': _lastVisitedDirectory.path,
        'texts': texts.serialize(),
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
        'textTimerHasStarted': textTimerHasStarted.serialize(),
        'textTimerActiveSessionHasEnded':
            textTimerActiveSessionHasEnded.serialize(),
        'textTimerPauseHasEnded': textTimerPauseHasEnded.serialize(),
        'textTimerWorkingHasEnded': textTimerWorkingHasEnded.serialize(),
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

  ///
  /// Serialize all the values
  Map<String, dynamic> serializeForWebClient(bool initial) {
    final out = <String, dynamic>{};
    if (initial || nbSessions.shouldSendToWebClient) {
      out['nbSessions'] = nbSessions.serialize();
      nbSessions.shouldSendToWebClient = false;
    }
    if (initial || sessionDuration.shouldSendToWebClient) {
      out['sessionDuration'] = sessionDuration.serialize();
      sessionDuration.shouldSendToWebClient = false;
    }
    if (initial || pauseDuration.shouldSendToWebClient) {
      out['pauseDuration'] = pauseDuration.serialize();
      pauseDuration.shouldSendToWebClient = false;
    }
    if (initial || activeBackgroundImage.shouldSendToWebClient) {
      out['activeBackgroundImage'] =
          activeBackgroundImage.serialize(withRawFile: true);
      activeBackgroundImage.shouldSendToWebClient = false;
    }
    if (initial || pauseBackgroundImage.shouldSendToWebClient) {
      out['pauseBackgroundImage'] =
          pauseBackgroundImage.serialize(withRawFile: true);
      pauseBackgroundImage.shouldSendToWebClient = false;
    }
    if (initial || endActiveSessionSound.shouldSendToWebClient) {
      out['endActiveSessionSound'] =
          endActiveSessionSound.serialize(withRawFile: true);
      endActiveSessionSound.shouldSendToWebClient = false;
    }
    if (initial || endPauseSessionSound.shouldSendToWebClient) {
      out['endPauseSessionSound'] =
          endPauseSessionSound.serialize(withRawFile: true);
      endPauseSessionSound.shouldSendToWebClient = false;
    }
    if (initial || endWorkingSound.shouldSendToWebClient) {
      out['endWorkingSound'] = endWorkingSound.serialize(withRawFile: true);
      endWorkingSound.shouldSendToWebClient = false;
    }
    if (initial || backgroundColor.shouldSendToWebClient) {
      out['backgroundColor'] = backgroundColor.serialize();
      backgroundColor.shouldSendToWebClient = false;
    }
    if (initial || backgroundColorHallOfFame.shouldSendToWebClient) {
      out['backgroundColorHallOfFame'] = backgroundColorHallOfFame.serialize();
      backgroundColorHallOfFame.shouldSendToWebClient = false;
    }
    out['fontPomodoro'] = fontPomodoro.index;
    out['textColorHallOfFame'] = textColorHallOfFame.value;
    if (initial || textDuringInitialization.shouldSendToWebClient) {
      out['textDuringInitialization'] = textDuringInitialization.serialize();
      textDuringInitialization.shouldSendToWebClient = false;
    }
    if (initial || textDuringActiveSession.shouldSendToWebClient) {
      out['textDuringActiveSession'] = textDuringActiveSession.serialize();
      textDuringActiveSession.shouldSendToWebClient = false;
    }
    if (initial || textDuringPauseSession.shouldSendToWebClient) {
      out['textDuringPauseSession'] = textDuringPauseSession.serialize();
      textDuringPauseSession.shouldSendToWebClient = false;
    }
    if (initial || textDuringPause.shouldSendToWebClient) {
      out['textDuringPause'] = textDuringPause.serialize();
      textDuringPause.shouldSendToWebClient = false;
    }
    if (initial || textDone.shouldSendToWebClient) {
      out['textDone'] = textDone.serialize();
      textDone.shouldSendToWebClient = false;
    }
    if (initial || useHallOfFame.shouldSendToWebClient) {
      out['useHallOfFame'] = useHallOfFame.serialize();
      useHallOfFame.shouldSendToWebClient = false;
    }
    if (initial || hallOfFameScrollVelocity.shouldSendToWebClient) {
      out['hallOfFameScrollVelocity'] = hallOfFameScrollVelocity.serialize();
      hallOfFameScrollVelocity.shouldSendToWebClient = false;
    }
    out['fontHallOfFame'] = fontHallOfFame.index;
    if (initial || textHallOfFameTitle.shouldSendToWebClient) {
      out['textHallOfFameTitle'] = textHallOfFameTitle.serialize();
      textHallOfFameTitle.shouldSendToWebClient = false;
    }
    if (initial || textHallOfFameName.shouldSendToWebClient) {
      out['textHallOfFameName'] = textHallOfFameName.serialize();
      textHallOfFameName.shouldSendToWebClient = false;
    }
    if (initial || textHallOfFameToday.shouldSendToWebClient) {
      out['textHallOfFameToday'] = textHallOfFameToday.serialize();
      textHallOfFameToday.shouldSendToWebClient = false;
    }
    if (initial || textHallOfFameAlltime.shouldSendToWebClient) {
      out['textHallOfFameAlltime'] = textHallOfFameAlltime.serialize();
      textHallOfFameAlltime.shouldSendToWebClient = false;
    }
    if (initial || textHallOfFameTotal.shouldSendToWebClient) {
      out['textHallOfFameTotal'] = textHallOfFameTotal.serialize();
      textHallOfFameTotal.shouldSendToWebClient = false;
    }

    return out;
  }

  void updateWebClient(map) {
    if (map?['nbSessions'] != null) {
      nbSessions = PreferencedInt.deserialize(map['nbSessions']);
    }
    if (map?['sessionDuration'] != null) {
      sessionDuration = PreferencedDuration.deserialize(map['sessionDuration']);
    }
    if (map?['pauseDuration'] != null) {
      pauseDuration = PreferencedDuration.deserialize(map['pauseDuration']);
    }

    if (map?['activeBackgroundImage'] != null) {
      activeBackgroundImage =
          PreferencedImageFile.deserialize(map['activeBackgroundImage']);
    }
    if (map?['pauseBackgroundImage'] != null) {
      pauseBackgroundImage =
          PreferencedImageFile.deserialize(map['pauseBackgroundImage']);
    }

    if (map?['endActiveSessionSound'] != null) {
      endActiveSessionSound =
          PreferencedSoundFile.deserialize(map['endActiveSessionSound']);
    }
    if (map?['endPauseSessionSound'] != null) {
      endPauseSessionSound =
          PreferencedSoundFile.deserialize(map['endPauseSessionSound']);
    }
    if (map?['endWorkingSound'] != null) {
      endWorkingSound =
          PreferencedSoundFile.deserialize(map['endWorkingSound']);
    }

    if (map?['backgroundColor'] != null) {
      backgroundColor = PreferencedColor.deserialize(map['backgroundColor']);
    }
    if (map?['backgroundColorHallOfFame'] != null) {
      backgroundColorHallOfFame =
          PreferencedColor.deserialize(map['backgroundColorHallOfFame']);
    }

    fontPomodoro = AppFonts.values[map['fontPomodoro']];
    textColorHallOfFame = Color(map['textColorHallOfFame']);
    if (map?['textDuringInitialization'] != null) {
      textDuringInitialization =
          TextOnPomodoro.deserialize(map['textDuringInitialization']);
    }
    if (map?['textDuringActiveSession'] != null) {
      textDuringActiveSession =
          TextOnPomodoro.deserialize(map['textDuringActiveSession']);
    }
    if (map?['textDuringPauseSession'] != null) {
      textDuringPauseSession =
          TextOnPomodoro.deserialize(map['textDuringPauseSession']);
    }
    if (map?['textDuringPause'] != null) {
      textDuringPause = TextOnPomodoro.deserialize(map['textDuringPause']);
    }
    if (map?['textDone'] != null) {
      textDone = TextOnPomodoro.deserialize(map['textDone']);
    }

    if (map?['useHallOfFame'] != null) {
      useHallOfFame = PreferencedBool.deserialize(map['useHallOfFame']);
    }
    if (map?['hallOfFameScrollVelocity'] != null) {
      hallOfFameScrollVelocity =
          PreferencedInt.deserialize(map['hallOfFameScrollVelocity']);
    }
    fontHallOfFame = AppFonts.values[map['fontHallOfFame']];
    if (map?['textHallOfFameTitle'] != null) {
      textHallOfFameTitle =
          PreferencedText.deserialize(map['textHallOfFameTitle']);
    }
    if (map?['textHallOfFameName'] != null) {
      textHallOfFameName =
          PreferencedText.deserialize(map?['textHallOfFameName']);
    }
    if (map?['textHallOfFameToday'] != null) {
      textHallOfFameToday =
          PreferencedText.deserialize(map['textHallOfFameToday']);
    }
    if (map?['textHallOfFameAlltime'] != null) {
      textHallOfFameAlltime =
          PreferencedText.deserialize(map['textHallOfFameAlltime']);
    }
    if (map?['textHallOfFameTotal'] != null) {
      textHallOfFameTotal =
          PreferencedText.deserialize(map['textHallOfFameTotal']);
    }

    isConnectedToServer = true;
    notifyListeners();
  }

  ///
  /// Reset the app configuration to their original values
  void reset() async {
    texts = PreferencedLanguage.deserialize(null, _defaultValues['texts']);
    nbSessions = PreferencedInt.deserialize(null, _defaultValues['nbSessions']);
    sessionDuration = PreferencedDuration.deserialize(
        null, _defaultValues['sessionDuration']);
    pauseDuration =
        PreferencedDuration.deserialize(null, _defaultValues['pauseDuration']);
    activeBackgroundImage = PreferencedImageFile.deserialize(null);
    pauseBackgroundImage = PreferencedImageFile.deserialize(null);
    endActiveSessionSound = PreferencedSoundFile.deserialize(null);
    endPauseSessionSound = PreferencedSoundFile.deserialize(null);
    endWorkingSound = PreferencedSoundFile.deserialize(null);
    backgroundColor =
        PreferencedColor.deserialize(null, _defaultValues['backgroundColor']);
    backgroundColorHallOfFame = PreferencedColor.deserialize(
        null, _defaultValues['backgroundColorHallOfFame']);
    textDuringInitialization = TextOnPomodoro.deserialize(
        null, _defaultValues['textDuringInitialization']);
    textDuringActiveSession = TextOnPomodoro.deserialize(
        null, _defaultValues['textDuringActiveSession']);
    textDuringPauseSession = TextOnPomodoro.deserialize(
        null, _defaultValues['textDuringPauseSession']);
    textDuringPause =
        TextOnPomodoro.deserialize(null, _defaultValues['textDuringPause']);
    textDone = TextOnPomodoro.deserialize(null, _defaultValues['textDone']);
    saveToTextFile =
        PreferencedBool.deserialize(null, _defaultValues['saveToTextFile']);
    useHallOfFame =
        PreferencedBool.deserialize(null, _defaultValues['useHallOfFame']);
    mustFollowForFaming = PreferencedBool.deserialize(
        null, _defaultValues['mustFollowForFaming']);
    hallOfFameScrollVelocity = PreferencedInt.deserialize(
        null, _defaultValues['hallOfFameScrollVelocity']);
    textTimerHasStarted =
        TextToChat.deserialize(null, _defaultValues['textTimerHasStarted']);
    textTimerActiveSessionHasEnded = TextToChat.deserialize(
        null, _defaultValues['textTimerActiveSessionHasEnded']);
    textTimerPauseHasEnded =
        TextToChat.deserialize(null, _defaultValues['textTimerPauseHasEnded']);
    textTimerWorkingHasEnded = TextToChat.deserialize(
        null, _defaultValues['textTimerWorkingHasEnded']);
    textNewcomersGreetings =
        TextToChat.deserialize(null, _defaultValues['textNewcomersGreetings']);
    textUserHasConnectedGreetings = TextToChat.deserialize(
        null, _defaultValues['textUserHasConnectedGreetings']);
    textWhitelist = PreferencedText.deserialize(null);
    textBlacklist = PreferencedText.deserialize(null);
    textHallOfFameTitle = PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameTitle']);
    textHallOfFameName =
        PreferencedText.deserialize(null, _defaultValues['textHallOfFameName']);
    textHallOfFameToday = PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameToday']);
    textHallOfFameAlltime = PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameAlltime']);
    textHallOfFameTotal = PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameTotal']);

    _addAllCallbacks();

    // Special cases
    fontPomodoro = AppFonts.values[_defaultValues['fontPomodoro']];
    textColorHallOfFame = Color(_defaultValues['textColorHallOfFame']);
    fontHallOfFame = AppFonts.values[_defaultValues['fontHallOfFame']];

    _save();
  }

  void _addAllCallbacks() {
    // Set the necessary callback
    texts.onChanged = _save;
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

    textTimerHasStarted.onChanged = _save;
    textTimerActiveSessionHasEnded.onChanged = _save;
    textTimerPauseHasEnded.onChanged = _save;
    textTimerWorkingHasEnded.onChanged = _save;
    textNewcomersGreetings.onChanged = _save;
    textUserHasConnectedGreetings.onChanged = _save;
    textBlacklist.onChanged = _save;

    hallOfFameScrollVelocity.onChanged = _save;
    textHallOfFameTitle.onChanged = _save;
    textHallOfFameName.onChanged = _save;
    textHallOfFameToday.onChanged = _save;
    textHallOfFameAlltime.onChanged = _save;
    textHallOfFameTotal.onChanged = _save;
  }
}
