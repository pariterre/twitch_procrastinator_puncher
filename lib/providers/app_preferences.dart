import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitch_procastinator_puncher/helpers/file_picker_interface.dart';
import 'package:twitch_procastinator_puncher/models/app_fonts.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_language.dart';

export 'package:twitch_procastinator_puncher/models/app_fonts.dart';

String get rootPath => Platform.isWindows ? r'C:\' : '/';

const Map<String, dynamic> _defaultValues = {
  'texts': 0,
  'nbSessions': 4,
  'nextTimeAskingForACoffee': 0,
  'managerSessionIndividually': false,
  'sessionDuration': 50 * 60,
  'pauseDuration': 10 * 60,
  'activeBackgroundImage': null,
  'pauseBackgroundImage': null,
  'endBackgroundImage': null,
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

  final PreferencedInt _nextTimeAskingForACoffee;

  // Session time
  PreferencedBool managerSessionIndividually;
  List<PreferencedDuration> sessionDurations;
  List<PreferencedDuration> pauseDurations;

  // Background image during the countdown
  PreferencedImageFile activeBackgroundImage;
  PreferencedImageFile pauseBackgroundImage;
  PreferencedImageFile endBackgroundImage;

  // Sound during count downd
  PreferencedSoundFile endActiveSessionSound;
  PreferencedSoundFile endPauseSessionSound;
  PreferencedSoundFile endWorkingSound;

  // Colors of the app
  PreferencedColor backgroundColor;
  PreferencedColor backgroundColorHallOfFame;

  // Foreground texts
  TextOnTimer textDuringInitialization;
  TextOnTimer textDuringActiveSession;
  TextOnTimer textDuringPauseSession;
  TextOnTimer textDuringPause;
  TextOnTimer textDone;

  AppFonts get fontPomodoro => textDuringInitialization.font;
  set fontPomodoro(AppFonts value) {
    textDuringInitialization.font = value;
    textDuringActiveSession.font = value;
    textDuringPauseSession.font = value;
    textDuringPause.font = value;
    textDone.font = value;
  }

  // Some options for the reward redemption
  List<RewardRedemptionPreferenced> rewardRedemptions;
  void newRewardRedemption() {
    rewardRedemptions.add(RewardRedemptionPreferenced());
    rewardRedemptions.last.onChanged = _save;
    _save();
  }

  void removeRewardRedemptionAt(int index) {
    rewardRedemptions.removeAt(index);
    _save();
  }

  // Some options for the hall of fame
  PreferencedBool saveToTextFile;
  PreferencedBool useHallOfFame;
  PreferencedBool mustFollowForFaming;

  PreferencedInt hallOfFameScrollVelocity;

  UnformattedPreferencedText textTimerHasStarted;
  UnformattedPreferencedText textTimerActiveSessionHasEnded;
  UnformattedPreferencedText textTimerPauseHasEnded;
  UnformattedPreferencedText textTimerWorkingHasEnded;
  UnformattedPreferencedText textNewcomersGreetings;
  UnformattedPreferencedText textUserHasConnectedGreetings;

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
  /// Returns true if the app should ask to buy me a coffee
  bool get shouldAskToBuyMeACoffee {
    if (_nextTimeAskingForACoffee.value == 0) setNextTimeAskingForACoffee();

    final isDue = DateTime.now().compareTo(DateTime.fromMillisecondsSinceEpoch(
            _nextTimeAskingForACoffee.value)) >
        0;

    if (isDue) {
      setNextTimeAskingForACoffee();
      return true;
    }

    return false;
  }

  ///
  /// Set the next time to ask for a coffee to my next birthday
  void setNextTimeAskingForACoffee() {
    _nextTimeAskingForACoffee.value =
        DateTime(DateTime.now().year + 1, 10, 17).millisecondsSinceEpoch;
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

  Future<void> exportWeb(context) async {
    if (!kIsWeb) throw 'exportWeb only works on web-based interface';

    const encoder = JsonEncoder.withIndent('\t');
    final text = encoder.convert(serialize(skipBinaryFiles: true));

    FilePickerInterface.instance
        .saveFile(context, data: text, filename: preferencesFilename);
  }

  Future<void> importWeb(context) async {
    if (!kIsWeb) throw 'importWeb only works on web-based interface';

    final result = await FilePickerInterface.instance.pickFile(context);
    if (result == null) return;

    final loadedPreferences = json.decode(utf8.decode(result));

    updateFromSerialized(loadedPreferences);
    _save();
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
    final nbSessions = await PreferencedInt.deserialize(
        previousPreferences?['nbSessions'], _defaultValues['nbSessions']);
    return AppPreferences._(
        nextTimeAskingForACoffee: await PreferencedInt.deserialize(
            previousPreferences?['nextTimeAskingForACoffee'],
            _defaultValues['nextTimeAskingForACoffee']),
        lastVisitedDirectory:
            Directory(previousPreferences?['lastVisitedDirectory'] ?? ''),
        texts: await PreferencedLanguage.deserialize(
            previousPreferences?['texts'], _defaultValues['texts']),
        nbSessions: nbSessions,
        managerSessionIndividually: await PreferencedBool.deserialize(
            previousPreferences?['managerSessionIndividually'],
            _defaultValues['managerSessionIndividually']),
        sessionDurations: (previousPreferences?['sessionDurations'] as List?)
                ?.map((e) => PreferencedDuration.deserializeSync(
                    e, _defaultValues['sessionDuration']))
                .toList() ??
            [
              for (int i = 0; i < nbSessions.value; i++)
                PreferencedDuration.deserializeSync(
                    null, _defaultValues['sessionDuration'])
            ],
        pauseDurations: (previousPreferences?['pauseDurations'] as List?)
                ?.map((e) => PreferencedDuration.deserializeSync(
                    e, _defaultValues['pauseDuration']))
                .toList() ??
            [
              for (int i = 0; i < nbSessions.value; i++)
                PreferencedDuration.deserializeSync(
                    null, _defaultValues['pauseDuration'])
            ],
        activeBackgroundImage: await PreferencedImageFile.deserialize(
            previousPreferences?['activeBackgroundImage']),
        pauseBackgroundImage: await PreferencedImageFile.deserialize(
            previousPreferences?['pauseBackgroundImage']),
        endBackgroundImage: await PreferencedImageFile.deserialize(
            previousPreferences?['endBackgroundImage']),
        endActiveSessionSound: await PreferencedSoundFile.deserialize(
            previousPreferences?['endActiveSessionSound']),
        endPauseSessionSound: await PreferencedSoundFile.deserialize(
            previousPreferences?['endPauseSessionSound']),
        endWorkingSound: await PreferencedSoundFile.deserialize(
            previousPreferences?['endWorkingSound']),
        backgroundColor: await PreferencedColor.deserialize(
            previousPreferences?['backgroundColor'],
            _defaultValues['backgroundColor']),
        backgroundColorHallOfFame:
            await PreferencedColor.deserialize(previousPreferences?['backgroundColorHallOfFame'], _defaultValues['backgroundColorHallOfFame']),
        fontPomodoro: previousPreferences?['fontPomodoro'] ?? _defaultValues['fontPomodoro'],
        textColorHallOfFame: previousPreferences?['textColorHallOfFame'] ?? _defaultValues['textColorHallOfFame'],
        textDuringInitialization: await TextOnTimer.deserialize(previousPreferences?['textDuringInitialization'], _defaultValues['textDuringInitialization']),
        textDuringActiveSession: await TextOnTimer.deserialize(previousPreferences?['textDuringActiveSession'], _defaultValues['textDuringActiveSession']),
        textDuringPauseSession: await TextOnTimer.deserialize(previousPreferences?['textDuringPauseSession'], _defaultValues['textDuringPauseSession']),
        textDuringPause: await TextOnTimer.deserialize(previousPreferences?['textDuringPause'], _defaultValues['textDuringPause']),
        textDone: await TextOnTimer.deserialize(previousPreferences?['textDone'], _defaultValues['textDone']),
        rewardRedemptions: (previousPreferences?['rewardRedemptions'] as List?)?.map((e) => RewardRedemptionPreferenced.deserializeSync(e)).toList() ?? [],
        saveToTextFile: await PreferencedBool.deserialize(previousPreferences?['saveToTextFile'], _defaultValues['saveToTextFile']),
        useHallOfFame: await PreferencedBool.deserialize(previousPreferences?['useHallOfFame'], _defaultValues['useHallOfFame']),
        mustFollowForFaming: await PreferencedBool.deserialize(previousPreferences?['mustFollowForFaming'], _defaultValues['mustFollowForFaming']),
        hallOfFameScrollVelocity: await PreferencedInt.deserialize(previousPreferences?['hallOfFameScrollVelocity'], _defaultValues['hallOfFameScrollVelocity']),
        textTimerHasStarted: await UnformattedPreferencedText.deserialize(previousPreferences?['textTimerHasStarted'], _defaultValues['textTimerHasStarted']),
        textTimerActiveSessionHasEnded: await UnformattedPreferencedText.deserialize(previousPreferences?['textTimerActiveSessionHasEnded'], _defaultValues['textTimerActiveSessionHasEnded']),
        textTimerPauseHasEnded: await UnformattedPreferencedText.deserialize(previousPreferences?['textTimerPauseHasEnded'], _defaultValues['textTimerPauseHasEnded']),
        textTimerWorkingHasEnded: await UnformattedPreferencedText.deserialize(previousPreferences?['textTimerWorkingHasEnded'], _defaultValues['textTimerWorkingHasEnded']),
        textNewcomersGreetings: await UnformattedPreferencedText.deserialize(previousPreferences?['textNewcomersGreetings'], _defaultValues['textNewcomersGreetings']),
        textUserHasConnectedGreetings: await UnformattedPreferencedText.deserialize(previousPreferences?['textUserHasConnectedGreetings'], _defaultValues['textUserHasConnectedGreetings']),
        textWhitelist: await PreferencedText.deserialize(previousPreferences?['textWhitelist']),
        textBlacklist: await PreferencedText.deserialize(previousPreferences?['textBlacklist']),
        fontHallOfFame: previousPreferences?['fontHallOfFame'] ?? _defaultValues['fontHallOfFame'],
        textHallOfFameTitle: await PreferencedText.deserialize(previousPreferences?['textHallOfFameTitle'], _defaultValues['textHallOfFameTitle']),
        textHallOfFameName: await PreferencedText.deserialize(previousPreferences?['textHallOfFameName'], _defaultValues['textHallOfFameName']),
        textHallOfFameToday: await PreferencedText.deserialize(previousPreferences?['textHallOfFameToday'], _defaultValues['textHallOfFameToday']),
        textHallOfFameAlltime: await PreferencedText.deserialize(previousPreferences?['textHallOfFameAlltime'], _defaultValues['textHallOfFameAlltime']),
        textHallOfFameTotal: await PreferencedText.deserialize(previousPreferences?['textHallOfFameTotal'], _defaultValues['textHallOfFameTotal']));
  }

  AppPreferences._({
    required Directory lastVisitedDirectory,
    required this.texts,
    required this.nbSessions,
    required PreferencedInt nextTimeAskingForACoffee,
    required this.managerSessionIndividually,
    required this.sessionDurations,
    required this.pauseDurations,
    required this.activeBackgroundImage,
    required this.pauseBackgroundImage,
    required this.endBackgroundImage,
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
    required this.rewardRedemptions,
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
  })  : _lastVisitedDirectory = lastVisitedDirectory,
        _nextTimeAskingForACoffee = nextTimeAskingForACoffee {
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
  Map<String, dynamic> serialize({bool skipBinaryFiles = false}) => {
        'lastVisitedDirectory': _lastVisitedDirectory.path,
        'texts': texts.serialize(),
        'nbSessions': nbSessions.serialize(),
        'nextTimeAskingForACoffee': _nextTimeAskingForACoffee.serialize(),
        'managerSessionIndividually': managerSessionIndividually.serialize(),
        'sessionDurations': sessionDurations.map((e) => e.serialize()).toList(),
        'pauseDurations': pauseDurations.map((e) => e.serialize()).toList(),
        'activeBackgroundImage':
            skipBinaryFiles ? null : activeBackgroundImage.serialize(),
        'pauseBackgroundImage':
            skipBinaryFiles ? null : pauseBackgroundImage.serialize(),
        'endBackgroundImage':
            skipBinaryFiles ? null : endBackgroundImage.serialize(),
        'endActiveSessionSound':
            skipBinaryFiles ? null : endActiveSessionSound.serialize(),
        'endPauseSessionSound':
            skipBinaryFiles ? null : endPauseSessionSound.serialize(),
        'endWorkingSound': skipBinaryFiles ? null : endWorkingSound.serialize(),
        'backgroundColor': backgroundColor.serialize(),
        'backgroundColorHallOfFame': backgroundColorHallOfFame.serialize(),
        'fontPomodoro': fontPomodoro.index,
        'textColorHallOfFame': textColorHallOfFame.value,
        'textDuringInitialization': textDuringInitialization.serialize(),
        'textDuringActiveSession': textDuringActiveSession.serialize(),
        'textDuringPauseSession': textDuringPauseSession.serialize(),
        'textDuringPause': textDuringPause.serialize(),
        'textDone': textDone.serialize(),
        'rewardRedemptions':
            rewardRedemptions.map((e) => e.serialize()).toList(),
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
  /// Reset the app configuration to their original values
  void reset() async {
    texts =
        await PreferencedLanguage.deserialize(null, _defaultValues['texts']);
    nbSessions =
        await PreferencedInt.deserialize(null, _defaultValues['nbSessions']);
    managerSessionIndividually = await PreferencedBool.deserialize(
        null, _defaultValues['managerSessionIndividually']);
    sessionDurations = [
      for (int i = 0; i < nbSessions.value; i++)
        PreferencedDuration.deserializeSync(
            null, _defaultValues['sessionDuration'])
    ];
    pauseDurations = [
      for (int i = 0; i < nbSessions.value; i++)
        PreferencedDuration.deserializeSync(
            null, _defaultValues['pauseDuration'])
    ];
    activeBackgroundImage = await PreferencedImageFile.deserialize(null);
    pauseBackgroundImage = await PreferencedImageFile.deserialize(null);
    endBackgroundImage = await PreferencedImageFile.deserialize(null);
    endActiveSessionSound = await PreferencedSoundFile.deserialize(null);
    endPauseSessionSound = await PreferencedSoundFile.deserialize(null);
    endWorkingSound = await PreferencedSoundFile.deserialize(null);
    backgroundColor = await PreferencedColor.deserialize(
        null, _defaultValues['backgroundColor']);
    backgroundColorHallOfFame = await PreferencedColor.deserialize(
        null, _defaultValues['backgroundColorHallOfFame']);
    textDuringInitialization = await TextOnTimer.deserialize(
        null, _defaultValues['textDuringInitialization']);
    textDuringActiveSession = await TextOnTimer.deserialize(
        null, _defaultValues['textDuringActiveSession']);
    textDuringPauseSession = await TextOnTimer.deserialize(
        null, _defaultValues['textDuringPauseSession']);
    textDuringPause =
        await TextOnTimer.deserialize(null, _defaultValues['textDuringPause']);
    textDone = await TextOnTimer.deserialize(null, _defaultValues['textDone']);
    rewardRedemptions = [];
    saveToTextFile = await PreferencedBool.deserialize(
        null, _defaultValues['saveToTextFile']);
    useHallOfFame = await PreferencedBool.deserialize(
        null, _defaultValues['useHallOfFame']);
    mustFollowForFaming = await PreferencedBool.deserialize(
        null, _defaultValues['mustFollowForFaming']);
    hallOfFameScrollVelocity = await PreferencedInt.deserialize(
        null, _defaultValues['hallOfFameScrollVelocity']);
    textTimerHasStarted = await UnformattedPreferencedText.deserialize(
        null, _defaultValues['textTimerHasStarted']);
    textTimerActiveSessionHasEnded =
        await UnformattedPreferencedText.deserialize(
            null, _defaultValues['textTimerActiveSessionHasEnded']);
    textTimerPauseHasEnded = await UnformattedPreferencedText.deserialize(
        null, _defaultValues['textTimerPauseHasEnded']);
    textTimerWorkingHasEnded = await UnformattedPreferencedText.deserialize(
        null, _defaultValues['textTimerWorkingHasEnded']);
    textNewcomersGreetings = await UnformattedPreferencedText.deserialize(
        null, _defaultValues['textNewcomersGreetings']);
    textUserHasConnectedGreetings =
        await UnformattedPreferencedText.deserialize(
            null, _defaultValues['textUserHasConnectedGreetings']);
    textWhitelist = await PreferencedText.deserialize(null);
    textBlacklist = await PreferencedText.deserialize(null);
    textHallOfFameTitle = await PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameTitle']);
    textHallOfFameName = await PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameName']);
    textHallOfFameToday = await PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameToday']);
    textHallOfFameAlltime = await PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameAlltime']);
    textHallOfFameTotal = await PreferencedText.deserialize(
        null, _defaultValues['textHallOfFameTotal']);

    _addAllCallbacks();

    // Special cases
    fontPomodoro = AppFonts.values[_defaultValues['fontPomodoro']];
    textColorHallOfFame = Color(_defaultValues['textColorHallOfFame']);
    fontHallOfFame = AppFonts.values[_defaultValues['fontHallOfFame']];

    _save();
  }

  ///
  /// Reset the app configuration to their original values
  void updateFromSerialized(map) async {
    texts = await PreferencedLanguage.deserialize(map['texts']);
    nbSessions = await PreferencedInt.deserialize(map['nbSessions']);
    managerSessionIndividually =
        await PreferencedBool.deserialize(map['managerSessionIndividually']);
    sessionDurations = (map['sessionDurations'] as List)
        .map((e) => PreferencedDuration.deserializeSync(e))
        .toList();
    pauseDurations = (map['pauseDurations'] as List)
        .map((e) => PreferencedDuration.deserializeSync(e))
        .toList();
    backgroundColor =
        await PreferencedColor.deserialize(map['backgroundColor']);
    backgroundColorHallOfFame =
        await PreferencedColor.deserialize(map['backgroundColorHallOfFame']);
    textDuringInitialization =
        await TextOnTimer.deserialize(map['textDuringInitialization']);
    textDuringActiveSession =
        await TextOnTimer.deserialize(map['textDuringActiveSession']);
    textDuringPauseSession =
        await TextOnTimer.deserialize(map['textDuringPauseSession']);
    textDuringPause = await TextOnTimer.deserialize(map['textDuringPause']);
    textDone = await TextOnTimer.deserialize(map['textDone']);
    rewardRedemptions = (map['rewardRedemptions'] as List?)
            ?.map((e) => RewardRedemptionPreferenced.deserializeSync(e))
            .toList() ??
        [];
    saveToTextFile = await PreferencedBool.deserialize(map['saveToTextFile']);
    useHallOfFame = await PreferencedBool.deserialize(map['useHallOfFame']);
    mustFollowForFaming =
        await PreferencedBool.deserialize(map['mustFollowForFaming']);
    hallOfFameScrollVelocity =
        await PreferencedInt.deserialize(map['hallOfFameScrollVelocity']);
    textTimerHasStarted = await UnformattedPreferencedText.deserialize(
        map['textTimerHasStarted']);
    textTimerActiveSessionHasEnded =
        await UnformattedPreferencedText.deserialize(
            map['textTimerActiveSessionHasEnded']);
    textTimerPauseHasEnded = await UnformattedPreferencedText.deserialize(
        map['textTimerPauseHasEnded']);
    textTimerWorkingHasEnded = await UnformattedPreferencedText.deserialize(
        map['textTimerWorkingHasEnded']);
    textNewcomersGreetings = await UnformattedPreferencedText.deserialize(
        map['textNewcomersGreetings']);
    textUserHasConnectedGreetings =
        await UnformattedPreferencedText.deserialize(
            map['textUserHasConnectedGreetings']);
    textWhitelist = await PreferencedText.deserialize(map['textWhitelist']);
    textBlacklist = await PreferencedText.deserialize(map['textBlacklist']);
    textHallOfFameTitle =
        await PreferencedText.deserialize(map['textHallOfFameTitle']);
    textHallOfFameName =
        await PreferencedText.deserialize(map['textHallOfFameName']);
    textHallOfFameToday =
        await PreferencedText.deserialize(map['textHallOfFameToday']);
    textHallOfFameAlltime =
        await PreferencedText.deserialize(map['textHallOfFameAlltime']);
    textHallOfFameTotal =
        await PreferencedText.deserialize(map['textHallOfFameTotal']);
  }

  void _addAllCallbacks() {
    // Set the necessary callback
    texts.onChanged = _save;
    nbSessions.onChanged = () async {
      if (sessionDurations.length < nbSessions.value) {
        for (int i = sessionDurations.length; i < nbSessions.value; i++) {
          sessionDurations.add(await PreferencedDuration.deserialize(
              sessionDurations.isNotEmpty
                  ? sessionDurations[0].value.inSeconds
                  : _defaultValues['sessionDuration']));
          sessionDurations.last.onChanged = _save;

          pauseDurations.add(await PreferencedDuration.deserialize(
              pauseDurations.isNotEmpty
                  ? pauseDurations[0].value.inSeconds
                  : _defaultValues['pauseDuration']));
          pauseDurations.last.onChanged = _save;
        }
      } else if (sessionDurations.length > nbSessions.value) {
        for (int i = sessionDurations.length - 1; i >= nbSessions.value; i--) {
          sessionDurations.removeAt(i);
          pauseDurations.removeAt(i);
        }
      } else {
        // Do nothing
      }
      _save();
    };
    _nextTimeAskingForACoffee.onChanged = _save;
    managerSessionIndividually.onChanged = _save;

    for (final duration in sessionDurations) {
      duration.onChanged = _save;
    }
    for (final duration in pauseDurations) {
      duration.onChanged = _save;
    }

    activeBackgroundImage.onChanged = _save;
    activeBackgroundImage.lastVisitedFolderCallback = _setLastVisited;
    pauseBackgroundImage.onChanged = _save;
    pauseBackgroundImage.lastVisitedFolderCallback = _setLastVisited;
    endBackgroundImage.onChanged = _save;
    endBackgroundImage.lastVisitedFolderCallback = _setLastVisited;

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

    for (var rewardRedemption in rewardRedemptions) {
      rewardRedemption.onChanged = _save;
    }

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
