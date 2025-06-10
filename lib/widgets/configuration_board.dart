import 'dart:io';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:dropdown_model_list/drop_down/model.dart';
import 'package:dropdown_model_list/drop_down/select_drop_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/enums.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';
import 'package:twitch_procastinator_puncher/models/reward_redemption.dart';
import 'package:twitch_procastinator_puncher/models/twitch_status.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';
import 'package:twitch_procastinator_puncher/screens/main_screen.dart';
import 'package:twitch_procastinator_puncher/widgets/animated_expanding_card.dart';
import 'package:twitch_procastinator_puncher/widgets/are_you_sure_dialog.dart';
import 'package:twitch_procastinator_puncher/widgets/bool_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/checkbox_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/color_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/dropmenu_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/file_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/info_tooltip.dart';
import 'package:twitch_procastinator_puncher/widgets/int_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/language_selector.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/string_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/time_selector_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({
    super.key,
    required this.startTimerCallback,
    required this.pauseTimerCallback,
    required this.resetTimerCallback,
    required this.gainFocusCallback,
    required this.connectToTwitch,
    required this.twitchStatus,
    required this.onRewardRedemptionSaved,
  });

  final Function() startTimerCallback;
  final Function() pauseTimerCallback;
  final Function() resetTimerCallback;
  final Function(StopWatchStatus hasFocus) gainFocusCallback;
  final Function()? connectToTwitch;
  final TwitchStatus twitchStatus;
  final Function(
      {required int index,
      required TypesOfModification modification}) onRewardRedemptionSaved;

  void _setTimer(AppPreferences preferences, BuildContext context) {
    // We can set the timer without check as this method only set if the stop watch never ran
    PomodoroStatus.of(context, listen: false).setTimer(
        preferences.usePreSessionCountdown.value
            ? preferences.preSessionCountdownDuration.value
            : preferences.sessionDurations[0].value);
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Container(
      width: windowHeight * 0.5,
      decoration: BoxDecoration(color: ThemeColor().configurationBoard),
      padding: EdgeInsets.only(bottom: padding),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context),
            SizedBox(height: windowHeight * 0.02),
            SizedBox(
              height: windowHeight * 0.63,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInformation(context),
                    const Divider(),
                    _buildController(context),
                    const Divider(),
                    _buildTimerConfiguration(context),
                    const Divider(),
                    _buildTextOnImage(context),
                    const Divider(),
                    _buildChatMessages(context),
                    const Divider(),
                    _buildChatBotResponse(context),
                    const Divider(),
                    _buildRewardRedemption(context, onRewardRedemptionSaved),
                    const Divider(),
                    _buildHallOfFameOptions(context),
                    const Divider(),
                    _buildReset(context),
                    const Divider(),
                    _buildSupportingMe(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);
    final preferences = AppPreferences.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LanguageSelector(),
            SizedBox(width: padding * 2),
            if (!kIsWeb)
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white)),
                padding: EdgeInsets.symmetric(
                    horizontal: padding / 4, vertical: padding / 5),
                child: InkWell(
                  onTap: () async {
                    final answer = await showDialog<bool>(
                        context: context,
                        builder: (context) => AreYouSureDialog(
                            title: preferences.texts.miscQuitTitle,
                            content: preferences.texts.miscQuitContent));
                    if (answer == null || !answer) return;

                    exit(0);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: windowHeight * 0.02,
                  ),
                ),
              ),
          ],
        ),
        Center(
          child: Text(
            preferences.texts.titleMain,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontSize: ThemeSize.text(context) * 1.20,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInformation(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return kIsWeb
        ? Text(
            preferences.texts.titleDescriptionWeb,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontSize: ThemeSize.text(context)),
          )
        : Wrap(
            children: [
              Text(preferences.texts.titleDescriptionDesktop,
                  style: TextStyle(
                      color: ThemeColor().configurationText,
                      fontSize: ThemeSize.text(context))),
              InkWell(
                  onTap: () async {
                    await launchUrl(Uri.parse(webClientSite));
                  },
                  child: Text(
                    webClientSite,
                    style: TextStyle(
                        color: ThemeColor().configurationText,
                        fontSize: ThemeSize.text(context),
                        decoration: TextDecoration.underline),
                  )),
            ],
          );
  }

  Widget _buildController(context) {
    final preferences = AppPreferences.of(context);
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      initialExpandedState: true,
      header: Text(preferences.texts.controllerTitle,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontWeight: FontWeight.bold,
              fontSize: ThemeSize.text(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed:
                    pomodoro.stopWatchStatus == StopWatchStatus.initializing ||
                            pomodoro.stopWatchStatus == StopWatchStatus.paused
                        ? startTimerCallback
                        : pauseTimerCallback,
                style: ThemeButton.elevated,
                child: Text(
                  pomodoro.stopWatchStatus == StopWatchStatus.initializing
                      ? preferences.texts.controllerStartTimer
                      : pomodoro.stopWatchStatus == StopWatchStatus.paused
                          ? preferences.texts.controllerResumeTimer
                          : preferences.texts.controllerPauseTimer,
                  style: TextStyle(
                      color: Colors.black, fontSize: ThemeSize.text(context)),
                ),
              ),
              ElevatedButton(
                onPressed: resetTimerCallback,
                style: ThemeButton.elevated,
                child: Text(
                  preferences.texts.controllerResetTimer,
                  style: TextStyle(
                      color: Colors.black, fontSize: ThemeSize.text(context)),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                  width: 150,
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(
                        labelText:
                            preferences.texts.controllerSelectCurrentSession,
                        labelStyle: TextStyle(
                            color: ThemeColor().configurationText,
                            fontSize: ThemeSize.text(context))),
                    onChanged: (value) {
                      final session = int.tryParse(value);
                      if (session == null) return;

                      pomodoro.currentSession = session - 1; // 0-indexed
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: ThemeColor().configurationText),
                  )),
              SizedBox(
                  width: 100,
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: InputDecoration(
                        labelText: preferences.texts.controllerSelectDuration,
                        labelStyle: TextStyle(
                            color: ThemeColor().configurationText,
                            fontSize: ThemeSize.text(context))),
                    inputFormatters: [TimeOnlyInputFormatter()],
                    onChanged: (value) {
                      if (!TimeOnlyInputFormatter.isValid(value)) return;
                      final minutes = TimeOnlyInputFormatter.getMinutes(value);
                      final seconds = TimeOnlyInputFormatter.getSeconds(value);
                      final duration =
                          Duration(minutes: minutes, seconds: seconds);
                      if (duration.inSeconds == 0) return;

                      pomodoro.timer = duration;
                    },
                    style: TextStyle(color: ThemeColor().configurationText),
                  )),
            ],
          ),
          if (twitchStatus != TwitchStatus.initializing &&
              connectToTwitch != null)
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: padding),
                child: ElevatedButton(
                  onPressed: () async {
                    final answer = await showDialog<bool>(
                        context: context,
                        builder: (context) => AreYouSureDialog(
                              title: preferences
                                  .texts.controllerReconnectTwitchConfirm,
                              content: preferences
                                  .texts.controllerReconnectTwitchContent,
                            ));
                    if (answer == null || !answer) return;

                    connectToTwitch!();
                  },
                  style: ThemeButton.elevated,
                  child: Text(
                      twitchStatus == TwitchStatus.connected
                          ? preferences.texts.controllerReconnectTwitch
                          : preferences.texts.controllerConnectTwitch,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ThemeSize.text(context))),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerConfiguration(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    /// This method creates the duo active an pause durations. If the switch
    /// for preparing the duration individually is set to false, then changing
    /// the value of one of which should change the value of all the others.
    /// This information is carried by [setAllDurationsOnChanged].
    Widget buildActiveAndPauseDurations(
        {required int index,
        required bool setAllDurationsOnChanged,
        required bool showPauseDuration}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!setAllDurationsOnChanged)
            Text(preferences.texts.controllerSessionIndexed(index + 1),
                style: TextStyle(
                    color: ThemeColor().configurationText,
                    fontWeight: FontWeight.bold,
                    fontSize: ThemeSize.text(context))),
          TimeSelectorTile(
            title: setAllDurationsOnChanged
                ? preferences.texts.controllerSessionsDuration
                : preferences.texts.controllerSessionDuration,
            initialValue: preferences.sessionDurations[index],
            onValidChange: (value) {
              if (setAllDurationsOnChanged) {
                for (final duration in preferences.sessionDurations) {
                  duration.set(value);
                }
              } else {
                preferences.sessionDurations[index].set(value);
              }

              _setTimer(preferences, context);
            },
          ),
          if (showPauseDuration)
            Padding(
              padding: EdgeInsets.only(top: padding),
              child: TimeSelectorTile(
                title: setAllDurationsOnChanged
                    ? preferences.texts.controllerPausesDuration
                    : preferences.texts.controllerPauseDuration,
                initialValue: AppPreferences.of(context, listen: false)
                    .pauseDurations[index],
                onValidChange: (value) {
                  if (setAllDurationsOnChanged) {
                    for (final duration in preferences.pauseDurations) {
                      duration.set(value);
                    }
                  } else {
                    preferences.pauseDurations[index].set(value);
                  }
                },
              ),
            ),
          SizedBox(height: 2 * padding),
        ],
      );
    }

    return AnimatedExpandingCard(
      header: Text(preferences.texts.controllerConfigurationTitle,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontWeight: FontWeight.bold,
              fontSize: ThemeSize.text(context))),
      child: Column(
        children: [
          IntSelectorTile(
            title: preferences.texts.controllerNumberOfSession,
            initialValue: preferences.nbSessions.value,
            onValidChange: (value) => preferences.nbSessions.set(value),
          ),
          SizedBox(height: padding),
          BoolSelectorTile(
              title: preferences.texts.controllerUseCountdownBeforeStarting,
              value: preferences.usePreSessionCountdown.value,
              onChanged: (bool value) {
                preferences.usePreSessionCountdown.value = value;
                _setTimer(preferences, context);
              }),
          if (preferences.usePreSessionCountdown.value)
            TimeSelectorTile(
              title: preferences.texts.controllerCountdownBeforeStarting,
              initialValue: preferences.preSessionCountdownDuration,
              onValidChange: (value) {
                preferences.preSessionCountdownDuration.set(value);
                _setTimer(preferences, context);
              },
            ),
          SizedBox(height: padding),
          BoolSelectorTile(
              title: preferences.texts.controllerSessionIndividually,
              value: preferences.managerSessionIndividually.value,
              onChanged: (bool value) =>
                  preferences.managerSessionIndividually.value = value),
          if (!preferences.managerSessionIndividually.value)
            buildActiveAndPauseDurations(
                index: 0,
                setAllDurationsOnChanged: true,
                showPauseDuration: true),
          if (preferences.managerSessionIndividually.value) ...[
            for (int i = 0; i < preferences.nbSessions.value; i++)
              buildActiveAndPauseDurations(
                  index: i,
                  setAllDurationsOnChanged: false,
                  showPauseDuration: i != preferences.nbSessions.value - 1)
          ],
          ColorSelectorTile(
              title: preferences.texts.miscBackgroundColor,
              tooltipMessage: preferences.texts.miscBackgroundColorTooltip,
              currentColor: preferences.backgroundColor.value,
              onChanged: (color) => preferences.backgroundColor.set(color)),
          SizedBox(height: 2 * padding),
          _buildImageSelectors(context),
        ],
      ),
    );
  }

  Widget _buildImageSelectors(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        FileSelectorTile(
          title: preferences.texts.filesCountdownImage,
          file: preferences.countdownBackgroundImage,
          onFileSelected: (data) async {
            if (data == null) return;

            if (kIsWeb) {
              await preferences.countdownBackgroundImage.setFileFromRaw(data);
            } else {
              await preferences.countdownBackgroundImage.setFile(data);
            }
          },
          onFileDeleted: preferences.countdownBackgroundImage.clear,
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              preferences.countdownBackgroundImage.size += 0.1;
            } else {
              preferences.countdownBackgroundImage.size -= 0.1;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesActiveImage,
          file: preferences.activeBackgroundImage,
          onFileSelected: (data) async {
            if (data == null) return;

            if (kIsWeb) {
              await preferences.activeBackgroundImage.setFileFromRaw(data);
            } else {
              await preferences.activeBackgroundImage.setFile(data);
            }
          },
          onFileDeleted: preferences.activeBackgroundImage.clear,
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              preferences.activeBackgroundImage.size += 0.1;
            } else {
              preferences.activeBackgroundImage.size -= 0.1;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesPauseImage,
          file: preferences.pauseBackgroundImage,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.pauseBackgroundImage.setFileFromRaw(data);
            } else {
              await preferences.pauseBackgroundImage.setFile(data);
            }
          },
          onFileDeleted: preferences.pauseBackgroundImage.clear,
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              preferences.pauseBackgroundImage.size += 0.05;
            } else {
              preferences.pauseBackgroundImage.size -= 0.05;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesEndImage,
          file: preferences.endBackgroundImage,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.endBackgroundImage.setFileFromRaw(data);
            } else {
              await preferences.endBackgroundImage.setFile(data);
            }
          },
          onFileDeleted: preferences.endBackgroundImage.clear,
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              preferences.endBackgroundImage.size += 0.05;
            } else {
              preferences.endBackgroundImage.size -= 0.05;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesCountdownSound,
          file: preferences.endCountdownSound,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.endCountdownSound.setFileFromRaw(data);
            } else {
              await preferences.endCountdownSound.setFile(data);
            }
          },
          onFileDeleted: preferences.endCountdownSound.clear,
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesEndActiveSound,
          file: preferences.endActiveSessionSound,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.endActiveSessionSound.setFileFromRaw(data);
            } else {
              await preferences.endActiveSessionSound.setFile(data);
            }
          },
          onFileDeleted: preferences.endActiveSessionSound.clear,
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesEndPauseSound,
          file: preferences.endPauseSessionSound,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.endPauseSessionSound.setFileFromRaw(data);
            } else {
              await preferences.endPauseSessionSound.setFile(data);
            }
          },
          onFileDeleted: preferences.endPauseSessionSound.clear,
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: preferences.texts.filesEndWorkingSound,
          file: preferences.endWorkingSound,
          onFileSelected: (data) async {
            if (kIsWeb) {
              await preferences.endWorkingSound.setFileFromRaw(data);
            } else {
              await preferences.endWorkingSound.setFile(data);
            }
          },
          onFileDeleted: preferences.endWorkingSound.clear,
        ),
      ],
    );
  }

  void _moveText(
      context, Function(Offset) textPointer, PressDirection direction) {
    final windowHeight = MediaQuery.of(context).size.height;
    switch (direction) {
      case PressDirection.up:
        textPointer(Offset(0, -windowHeight * 0.01));
        return;
      case PressDirection.right:
        textPointer(Offset(windowHeight * 0.01, 0));
        return;
      case PressDirection.down:
        textPointer(Offset(0, windowHeight * 0.01));
        return;
      case PressDirection.left:
        textPointer(Offset(-windowHeight * 0.01, 0));
        return;
    }
  }

  Widget _buildTextOnImage(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Row(children: [
        Text(
          preferences.texts.timerTextsTitle,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontWeight: FontWeight.bold,
              fontSize: ThemeSize.text(context)),
        ),
        SizedBox(width: padding),
        InfoTooltip(message: preferences.texts.timerTextsTitleTooltip),
      ]),
      child: Column(
        children: [
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerTextsIntroduction,
            plainText: preferences.textDuringInitialization,
            focus: StopWatchStatus.initializing,
            initialColor: preferences.textDuringInitialization.color,
            onColorChanged: (color) =>
                preferences.textDuringInitialization.color = color,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerPreSessionCountdown,
            plainText: preferences.textDuringPreSessionCountdown,
            focus: StopWatchStatus.inPreSessionCountdown,
            initialColor: preferences.textDuringPreSessionCountdown.color,
            onColorChanged: (color) =>
                preferences.textDuringPreSessionCountdown.color = color,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerTextsSessions,
            plainText: preferences.textDuringActiveSession,
            focus: StopWatchStatus.inSession,
            initialColor: preferences.textDuringActiveSession.color,
            onColorChanged: (color) =>
                preferences.textDuringActiveSession.color = color,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerTextsPauses,
            plainText: preferences.textDuringPauseSession,
            focus: StopWatchStatus.inPauseSession,
            initialColor: preferences.textDuringPauseSession.color,
            onColorChanged: (color) =>
                preferences.textDuringPauseSession.color = color,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerTextsTimerPauses,
            plainText: preferences.textDuringPause,
            focus: StopWatchStatus.paused,
            initialColor: preferences.textDuringPause.color,
            onColorChanged: (color) =>
                preferences.textDuringPause.color = color,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.timerTextsAllDone,
            plainText: preferences.textDone,
            focus: StopWatchStatus.done,
            initialColor: preferences.textDone.color,
            onColorChanged: (color) => preferences.textDone.color = color,
          ),
          SizedBox(height: padding),
          DropMenuSelectorTile<AppFonts>(
              title: preferences.texts.miscFont,
              value: preferences.fontPomodoro,
              items: AppFonts.values
                  .map<DropdownMenuItem<AppFonts>>(
                      (e) => DropdownMenuItem<AppFonts>(
                          value: e,
                          child: Padding(
                            padding: EdgeInsets.only(left: padding),
                            child: Text(e.name, style: e.style()),
                          )))
                  .toList(),
              onChanged: (value) => preferences.fontPomodoro = value!),
          SizedBox(height: padding),
          if (!kIsWeb)
            CheckboxTile(
              title: preferences.texts.timerTextsExport,
              tooltipMessage: preferences.texts.timerTextsExportTooltip,
              value: preferences.saveToTextFile.value,
              onChanged: (value) {
                preferences.saveToTextFile.set(value!);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRewardRedemption(
      BuildContext context,
      Function({required int index, required TypesOfModification modification})
          onRewardRedemptionSaved) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Row(
        children: [
          Text(
            preferences.texts.rewardRedemptionTitle,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context)),
          ),
          SizedBox(width: padding),
          InfoTooltip(message: preferences.texts.rewardRedemptionTitleTooltip),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...preferences.rewardRedemptions
            .asMap()
            .keys
            .map((index) => _buildRewardRedemptionSelectorTile(
                  context,
                  hint:
                      '${preferences.texts.rewardRedemptionLabel} ${index + 1}',
                  reward: preferences.rewardRedemptions[index],
                  onSaved: ({required TypesOfModification modification}) =>
                      onRewardRedemptionSaved(
                          index: index, modification: modification),
                )),
        Center(
          child: ElevatedButton(
              onPressed: () => AppPreferences.of(context, listen: false)
                  .newRewardRedemption(),
              style: ThemeButton.elevated,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, color: Colors.green),
                  Text(
                    preferences.texts.rewardRedemptionAddButton,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black, fontSize: ThemeSize.text(context)),
                  ),
                ],
              )),
        ),
      ]),
    );
  }

  Widget _buildHallOfFameOptions(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final participants = Participants.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Row(
        children: [
          Text(
            preferences.texts.hallOfFameTitle,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context)),
          ),
          SizedBox(width: padding),
          InfoTooltip(message: preferences.texts.hallOfFameTitleTooltip),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (kIsWeb)
          Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ThemeButton.elevated,
                    onPressed: () => Participants.of(context, listen: false)
                        .exportWeb(context),
                    child: Text(
                      preferences.texts.hallOfFameExport,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ThemeSize.text(context)),
                    )),
                ElevatedButton(
                  style: ThemeButton.elevated,
                  onPressed: () async {
                    final participants =
                        Participants.of(context, listen: false);
                    final answer = await showDialog<bool>(
                        context: context,
                        builder: (context) => AreYouSureDialog(
                            title: preferences
                                .texts.hallOfFameImportAreYouSureTitle,
                            content: preferences
                                .texts.hallOfFameImportAreYouSureContent));
                    if (answer == null || !answer) return;

                    if (!context.mounted) return;
                    participants.importWeb(context);
                  },
                  child: Text(
                    preferences.texts.hallOfFameImport,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black, fontSize: ThemeSize.text(context)),
                  ),
                ),
              ],
            ),
          ),
        CheckboxTile(
          title: preferences.texts.hallOfFameUsage,
          value: preferences.useHallOfFame.value,
          onChanged: (value) => preferences.useHallOfFame.set(value!),
        ),
        SizedBox(height: padding),
        CheckboxTile(
          title: preferences.texts.hallOfFameMustFollow,
          tooltipMessage: preferences.texts.hallOfFameMustFollowTooltip,
          value: preferences.mustFollowForFaming.value,
          onChanged: (value) {
            preferences.mustFollowForFaming.set(value!);
            participants.mustFollowForFaming = value;
          },
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameWhiteListed,
          plainText: preferences.textWhitelist,
          onTextComplete: () =>
              participants.whitelist = preferences.textWhitelist.text,
        ),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameBlackListed,
          plainText: preferences.textBlacklist,
          onTextComplete: () =>
              participants.blacklist = preferences.textBlacklist.text,
        ),
        SizedBox(height: padding),
        SizedBox(height: padding),
        ColorSelectorTile(
            title: preferences.texts.hallOfFameBackgroundColor,
            currentColor: preferences.backgroundColorHallOfFame.value,
            onChanged: (color) =>
                preferences.backgroundColorHallOfFame.set(color)),
        SizedBox(height: padding),
        DropMenuSelectorTile<AppFonts>(
            title: preferences.texts.miscFont,
            value: preferences.fontHallOfFame,
            items: AppFonts.values
                .map<DropdownMenuItem<AppFonts>>(
                    (e) => DropdownMenuItem<AppFonts>(
                        value: e,
                        child: Padding(
                          padding: EdgeInsets.only(left: padding),
                          child: Text(
                            e.name,
                            style: e.style(),
                          ),
                        )))
                .toList(),
            onChanged: (value) => preferences.fontHallOfFame = value!),
        SizedBox(height: padding),
        ColorSelectorTile(
            title: preferences.texts.hallOfFameTextColor,
            currentColor: preferences.textColorHallOfFame,
            onChanged: (color) => preferences.textColorHallOfFame = color),
        SizedBox(height: padding),
        PlusOrMinusTile(
          title: preferences.texts.hallOfFameScollingSpeed,
          onTap: (selection) => preferences.hallOfFameScrollVelocity.set(
              preferences.hallOfFameScrollVelocity.value +
                  (selection == PlusOrMinusSelection.plus ? -100 : 100)),
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameTextTitleMain,
          plainText: preferences.textHallOfFameTitle,
        ),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameTextTitleViewers,
          plainText: preferences.textHallOfFameName,
        ),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameTextTitleToday,
          plainText: preferences.textHallOfFameToday,
        ),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameTextTitleInAll,
          plainText: preferences.textHallOfFameAlltime,
        ),
        _buildStringSelectorTile(
          context,
          title: preferences.texts.hallOfFameTextTitleGrandTotal,
          plainText: preferences.textHallOfFameTotal,
        ),
      ]),
    );
  }

  Widget _buildReset(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Text(preferences.texts.miscTitle,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontWeight: FontWeight.bold,
              fontSize: ThemeSize.text(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kIsWeb)
            Padding(
              padding: EdgeInsets.only(bottom: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => AppPreferences.of(context, listen: false)
                        .exportWeb(context),
                    style: ThemeButton.elevated,
                    child: Text(
                      textAlign: TextAlign.center,
                      preferences.texts.miscExportButton,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ThemeSize.text(context)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final preferences =
                          AppPreferences.of(context, listen: false);

                      final answer = await showDialog<bool>(
                          context: context,
                          builder: (context) => AreYouSureDialog(
                              title:
                                  preferences.texts.miscImportAreYouSureTitle,
                              content: preferences
                                  .texts.micsImportAreYouSureContent));
                      if (answer == null || !answer) return;

                      if (!context.mounted) return;
                      await preferences.importWeb(context);

                      navigator.pushReplacementNamed(MainScreen.route);
                    },
                    style: ThemeButton.elevated,
                    child: Text(
                      textAlign: TextAlign.center,
                      preferences.texts.miscImportButton,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: ThemeSize.text(context)),
                    ),
                  ),
                ],
              ),
            ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final answer = await showDialog<bool>(
                  context: context,
                  builder: (context) => AreYouSureDialog(
                    title: preferences.texts.miscResetConfirmTitle,
                    content: preferences.texts.miscResetConfirm,
                  ),
                );
                if (answer == null || !answer) return;
                preferences.reset();
                navigator.pushReplacementNamed(MainScreen.route);
              },
              style: ThemeButton.elevated,
              child: Text(
                preferences.texts.miscResetButton,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black, fontSize: ThemeSize.text(context)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSupportingMe(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(preferences.texts.supportingMeTitle,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context))),
        const SizedBox(height: 8),
        Text(
          preferences.texts.supportingMeText,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontSize: ThemeSize.text(context)),
        ),
        const SizedBox(height: 8),
        InkWell(
            onTap: () async {
              await launchUrl(Uri.parse(buyMeACoffeeLink));
            },
            child: Text(
              buyMeACoffeeLink,
              style: TextStyle(
                  color: ThemeColor().configurationText,
                  fontSize: ThemeSize.text(context),
                  decoration: TextDecoration.underline),
            ))
      ],
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Row(
        children: [
          Text(
            preferences.texts.chatTitle,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context)),
          ),
          SizedBox(width: padding),
          InfoTooltip(message: preferences.texts.chatTitleTooltip),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatTimerHasStarted,
            plainText: preferences.textTimerHasStarted,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatTimerPreSessionCountdownHasEnded,
            plainText: preferences.textTimerPreSessionCountdownHasEnded,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatTimerSessionHasEnded,
            plainText: preferences.textTimerActiveSessionHasEnded,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatTimerPauseHasEnded,
            plainText: preferences.textTimerPauseHasEnded,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatTimerWorkingHasEnded,
            plainText: preferences.textTimerWorkingHasEnded,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatNewcomerGreetings,
            plainText: preferences.textNewcomersGreetings,
          ),
          _buildStringSelectorTile(
            context,
            title: preferences.texts.chatUserHasConnected,
            plainText: preferences.textUserHasConnectedGreetings,
          ),
        ],
      ),
    );
  }

  Widget _buildChatBotResponse(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return AnimatedExpandingCard(
      header: Row(
        children: [
          Text(
            preferences.texts.chatbotTitle,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context)),
          ),
          SizedBox(width: padding),
          InfoTooltip(message: preferences.texts.chatbotTitleTooltip),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...preferences.automaticResponses
              .asMap()
              .keys
              .map((index) => _buildAutomaticResponseTile(
                    context,
                    hint: '${preferences.texts.chatbotLabel} ${index + 1}',
                    automaticResponses: preferences.automaticResponses[index],
                    onDeleted: () =>
                        preferences.removeAutomaticResponseAt(index),
                  )),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: padding),
              child: ElevatedButton(
                  onPressed: () => AppPreferences.of(context, listen: false)
                      .newAutomaticResponse(),
                  style: ThemeButton.elevated,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.green),
                      Text(
                        preferences.texts.chatbotAddNew,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: ThemeSize.text(context)),
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStringSelectorTile(
    context, {
    required String title,
    required PreferencedText plainText,
    StopWatchStatus? focus,
    Function()? onTextComplete,
    Color? initialColor,
    Function(Color)? onColorChanged,
  }) {
    return StringSelectorTile(
      title: title,
      initialText: plainText.text,
      onFocusChanged: focus == null && onTextComplete == null
          ? null
          : (gainedFocus) {
              if (focus != null && gainedFocus) gainFocusCallback(focus);
              if (onTextComplete != null && !gainedFocus) onTextComplete();
            },
      onTextChanged: (String value) {
        plainText.text = value;
        if (focus != null) gainFocusCallback(focus);
      },
      onSizeChanged: plainText.runtimeType == TextOnTimer
          ? (direction) {
              (plainText as TextOnTimer).increaseSize(
                  direction == PlusOrMinusSelection.plus ? 0.01 : -0.01);
              if (focus != null) gainFocusCallback(focus);
            }
          : null,
      onMoveText: plainText.runtimeType == TextOnTimer
          ? (direction) {
              _moveText(
                  context, (plainText as TextOnTimer).addToOffset, direction);
              if (focus != null) gainFocusCallback(focus);
            }
          : null,
      initialColor: initialColor,
      onColorChanged: onColorChanged,
    );
  }

  Widget _buildRewardRedemptionSelectorTile(
    context, {
    required String hint,
    required RewardRedemptionPreferenced reward,
    required Function({required TypesOfModification modification}) onSaved,
  }) {
    final padding = ThemePadding.normal(context);
    final texts = AppPreferences.of(context, listen: false).texts;

    return Padding(
      padding: EdgeInsets.only(bottom: 2 * padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: StringSelectorTile(
                  key: ValueKey(reward.hashCode),
                  title: hint,
                  initialText: reward.title,
                  onTextChanged: (String value) => reward.title = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                    onPressed: reward.isSavedToTwitch
                        ? null
                        : () => onSaved(
                            modification: reward.rewardId == null
                                ? TypesOfModification.created
                                : TypesOfModification.updated),
                    icon: Icon(Icons.save,
                        color: reward.isSavedToTwitch ? null : Colors.white)),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: padding),
            child: IntSelectorTile(
              key: ValueKey(reward.hashCode),
              title: texts.rewardRedemptionCost,
              initialValue: reward.cost,
              onValidChange: (int value) => reward.cost = value,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: padding),
            child: StringSelectorTile(
              key: ValueKey(reward.hashCode),
              title: texts.rewardRedemptionChatbotAnswer,
              initialText: reward.chatbotAnswer,
              onTextChanged: (String value) => reward.chatbotAnswer = value,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SelectDropList(
                    key: ValueKey(reward.hashCode),
                    paddingTop: padding / 2,
                    heightBottomContainer:
                        20 + (RewardRedemption.values.length - 1) * 42,
                    itemSelected: OptionItem(
                        id: reward.rewardRedemption.index.toString(),
                        title: reward.rewardRedemption.name(context)),
                    dropListModel: DropListModel(RewardRedemption.values
                        .where((e) => e != RewardRedemption.none)
                        .map(
                          (e) => OptionItem(
                              id: e.index.toString(), title: e.name(context)),
                        )
                        .toList()),
                    showIcon: false,
                    showArrowIcon: true,
                    onOptionSelected: (value) => reward.rewardRedemption =
                        RewardRedemption.values[int.parse(value.id!)]),
              ),
              IconButton(
                  onPressed: () =>
                      onSaved(modification: TypesOfModification.deleted),
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
          const SizedBox(width: 300, child: Divider(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAutomaticResponseTile(
    context, {
    required String hint,
    required AutomaticReponsePreferenced automaticResponses,
    required Function() onDeleted,
  }) {
    final padding = ThemePadding.normal(context);
    final texts = AppPreferences.of(context, listen: false).texts;

    return Padding(
      padding: EdgeInsets.only(bottom: 2 * padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: StringSelectorTile(
                  key: ValueKey(automaticResponses.hashCode),
                  title: hint,
                  initialText: automaticResponses.command,
                  onTextChanged: (String value) =>
                      automaticResponses.command = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: IconButton(
                    onPressed: () => onDeleted(),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    )),
              )
            ],
          ),
          StringSelectorTile(
            key: ValueKey(automaticResponses.hashCode + 1),
            title: texts.chatbotAnswer,
            initialText: automaticResponses.answer.text,
            onTextChanged: (String value) =>
                automaticResponses.answer = UnformattedPreferencedText(value),
          ),
        ],
      ),
    );
  }
}
