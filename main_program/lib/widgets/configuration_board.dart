import 'package:arrow_pad/arrow_pad.dart';
import 'package:common_lib/models/app_theme.dart';
import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/preferenced_element.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/participants.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/twitch_status.dart';
import 'package:twitch_procastinator_puncher/widgets/color_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/dropmenu_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/file_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/int_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus_list_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/string_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/time_selector_tile.dart';

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({
    super.key,
    required this.startTimerCallback,
    required this.pauseTimerCallback,
    required this.resetTimerCallback,
    required this.gainFocusCallback,
    required this.connectToTwitch,
    required this.twitchStatus,
  });

  final Function() startTimerCallback;
  final Function() pauseTimerCallback;
  final Function() resetTimerCallback;
  final Function(StopWatchStatus hasFocus) gainFocusCallback;
  final Function()? connectToTwitch;
  final TwitchStatus twitchStatus;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Container(
      width: windowHeight * 0.5,
      height: windowHeight * 0.7,
      decoration: BoxDecoration(color: ThemeColor().configurationBoard),
      padding: EdgeInsets.only(bottom: padding),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildController(context),
              const Divider(),
              _buildTimerConfiguration(context),
              const Divider(),
              _buildImageSelectors(context),
              const Divider(),
              _buildColorPickers(context),
              const Divider(),
              _buildTextOnImage(context),
              const Divider(),
              _buildHallOfFame(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPickers(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return ColorSelectorTile(
        title: 'Background color',
        currentColor: preferences.backgroundColor.value,
        onChanged: (color) => preferences.backgroundColor.set(color));
  }

  Widget _buildController(context) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final padding = ThemePadding.normal(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pomodoro controller',
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold)),
        SizedBox(height: padding),
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
                    ? 'Start timer'
                    : pomodoro.stopWatchStatus == StopWatchStatus.paused
                        ? 'Resume timer'
                        : 'Pause timer',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: resetTimerCallback,
              style: ThemeButton.elevated,
              child: const Text(
                'Reset timer',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        if (twitchStatus != TwitchStatus.initializing &&
            connectToTwitch != null)
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: padding),
              child: ElevatedButton(
                onPressed: connectToTwitch,
                style: ThemeButton.elevated,
                child: Text(
                    twitchStatus == TwitchStatus.connected
                        ? 'Reconnect to Twitch'
                        : 'Connect to Twitch',
                    style: const TextStyle(color: Colors.black)),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildTimerConfiguration(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        IntSelectorTile(
          title: 'Number of sessions',
          initialValue: AppPreferences.of(context, listen: false).nbSessions,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).nbSessions.set(value);
            PomodoroStatus.of(context, listen: false).nbSessions = value;
          },
        ),
        SizedBox(height: padding),
        TimeSelectorTile(
          title: 'Session duration (mm:ss)',
          initialValue:
              AppPreferences.of(context, listen: false).sessionDuration,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false)
                .sessionDuration
                .set(value);
            PomodoroStatus.of(context, listen: false).focusSessionDuration =
                value;
          },
        ),
        SizedBox(height: padding),
        TimeSelectorTile(
          title: 'Pause duration (mm:ss)',
          initialValue: AppPreferences.of(context, listen: false).pauseDuration,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).pauseDuration.set(value);
            PomodoroStatus.of(context, listen: false).pauseSessionDuration =
                value;
          },
        ),
      ],
    );
  }

  Widget _buildImageSelectors(BuildContext context) {
    final appPreferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        FileSelectorTile(
          title: 'Active image',
          file: appPreferences.activeBackgroundImage,
          selectFileCallback: (filename) async =>
              await appPreferences.activeBackgroundImage.setFile(filename),
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              appPreferences.activeBackgroundImage.size += 0.1;
            } else {
              appPreferences.activeBackgroundImage.size -= 0.1;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
          title: 'Paused image',
          file: appPreferences.pauseBackgroundImage,
          selectFileCallback: (filename) async =>
              await appPreferences.pauseBackgroundImage.setFile(filename),
          onSizeChanged: (direction) {
            if (direction == PlusOrMinusSelection.plus) {
              appPreferences.pauseBackgroundImage.size += 0.05;
            } else {
              appPreferences.pauseBackgroundImage.size -= 0.05;
            }
          },
        ),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of active session',
            file: appPreferences.endActiveSessionSound,
            selectFileCallback: (filename) async =>
                await appPreferences.endActiveSessionSound.setFile(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of pause',
            file: appPreferences.endPauseSessionSound,
            selectFileCallback: (filename) async =>
                await appPreferences.endPauseSessionSound.setFile(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of working',
            file: appPreferences.endWorkingSound,
            selectFileCallback: (filename) async =>
                await appPreferences.endWorkingSound.setFile(filename)),
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

    return Column(
      children: [
        Row(children: [
          Text(
            'Text to print on the images',
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(width: padding),
          const Tooltip(
            message:
                'The following tag can be used to access some interesting\n'
                'information to display:\n'
                '    {currentSession} is the current session\n'
                '    {maxSessions} is the max sessions\n'
                '    {timer} is the timer\n'
                '    {sessionDuration} is the time of the focus sessions\n'
                '    {pauseDuration} is the time of the pauses\n'
                '    \\n is a linebreak',
            child: Icon(
              Icons.info,
              color: Colors.white,
            ),
          ),
        ]),
        SizedBox(height: padding),
        DropMenuSelectorTile<AppFonts>(
            title: 'Font',
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
        _buildStringSelectorTile(
          context,
          title: 'Text during initialization',
          plainText: preferences.textDuringInitialization,
          focus: StopWatchStatus.initializing,
          initialColor: preferences.textDuringInitialization.color,
          onColorChanged: (color) =>
              preferences.textDuringInitialization.color = color,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during focus sessions',
          plainText: preferences.textDuringActiveSession,
          focus: StopWatchStatus.inSession,
          initialColor: preferences.textDuringActiveSession.color,
          onColorChanged: (color) =>
              preferences.textDuringActiveSession.color = color,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during pause sessions',
          plainText: preferences.textDuringPauseSession,
          focus: StopWatchStatus.inPauseSession,
          initialColor: preferences.textDuringPauseSession.color,
          onColorChanged: (color) =>
              preferences.textDuringPauseSession.color = color,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during pauses',
          plainText: preferences.textDuringPause,
          focus: StopWatchStatus.paused,
          initialColor: preferences.textDuringPause.color,
          onColorChanged: (color) => preferences.textDuringPause.color = color,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text when done',
          plainText: preferences.textDone,
          focus: StopWatchStatus.done,
          initialColor: preferences.textDone.color,
          onColorChanged: (color) => preferences.textDone.color = color,
        ),
        SizedBox(height: padding),
        CheckboxListTile(
          title: Row(
            children: [
              const Text(
                'Export to a file',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: padding),
              Tooltip(
                message:
                    'If this is ticked, then a file with the printed message\n'
                    'on the imsage is updated too.\n'
                    'This allows to access the current state of the timer outside\n'
                    'of this software. The file is in:\n'
                    '${preferences.saveDirectory.path}/$textExportFilename',
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              )
            ],
          ),
          visualDensity: VisualDensity.compact,
          value: preferences.saveToTextFile,
          onChanged: (value) {
            preferences.saveToTextFile = value!;
          },
        ),
      ],
    );
  }

  Widget _buildHallOfFame(BuildContext context) {
    final preferences = AppPreferences.of(context);
    final participants = Participants.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hall of fame',
              style: TextStyle(
                  color: ThemeColor().configurationText,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(width: padding),
            const Tooltip(
              message:
                  'The Hall of fame necessitate that you connected to Twitch.\n\n'
                  'To personalize the message that are sent to the chat,\n'
                  'you can use these tags:\n'
                  '    {username} is the name of a user\n'
                  '    {total} number of sessions previously done\n'
                  '    \\n is a linebreak',
              child: Icon(
                Icons.info,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        CheckboxListTile(
          title: const Text(
            'Use hall of fame',
            style: TextStyle(color: Colors.white),
          ),
          visualDensity: VisualDensity.compact,
          value: preferences.useHallOfFame,
          onChanged: (value) => preferences.useHallOfFame = value!,
        ),
        SizedBox(height: padding),
        CheckboxListTile(
          title: Row(
            children: [
              const Text(
                'Must be a follower to register',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: padding),
              const Tooltip(
                message:
                    'If the users must be a follower of your channel to be \n'
                    'added to the current worker list.\n'
                    'Warning, setting this to false can result in a lot of\n'
                    'users being added due to the large amount of bots\n'
                    'navigating on Twitch.\n\n'
                    'The white and black list can be used to bypass the\n'
                    'must follow requirements.\n'
                    '    Whitelisted users will be added in all cases\n'
                    '    Blacklisted users won\'t be added even if they are\n'
                    'followers (typically, you want to add all your chatbots\n'
                    'to that list).',
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                ),
              )
            ],
          ),
          visualDensity: VisualDensity.compact,
          value: preferences.mustFollowForFaming,
          onChanged: (value) {
            preferences.mustFollowForFaming = value!;
            participants.mustFollowForFaming = value;
          },
        ),
        _buildStringSelectorTile(
          context,
          title: 'Newcomer greetings',
          plainText: preferences.textNewcomersGreetings,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'User has connected',
          plainText: preferences.textUserHasConnectedGreetings,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Whitelisted users (semicolon separated)',
          plainText: preferences.textWhitelist,
          onTextComplete: () =>
              participants.whitelist = preferences.textWhitelist.text,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Blacklisted users (semicolon separated)',
          plainText: preferences.textBlacklist,
          onTextComplete: () =>
              participants.blacklist = preferences.textBlacklist.text,
        ),
        SizedBox(height: padding),
        ColorSelectorTile(
            title: 'Color of the hall of fame',
            currentColor: preferences.backgroundColorHallOfFame.value,
            onChanged: (color) =>
                preferences.backgroundColorHallOfFame.set(color)),
        SizedBox(height: padding),
        DropMenuSelectorTile<AppFonts>(
            title: 'Font',
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
            title: 'Text color on the hall of fame',
            currentColor: preferences.textColorHallOfFame,
            onChanged: (color) => preferences.textColorHallOfFame = color),
        SizedBox(height: padding),
        PlusOrMinusListTile(
          title: const Text(
            'Scroll velocity',
            style: TextStyle(color: Colors.white),
          ),
          onTap: (selection) => preferences.hallOfFameScrollVelocity =
              selection == PlusOrMinusSelection.plus ? -100 : 100,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Main title',
          plainText: preferences.textHallOfFameTitle,
          initialColor: preferences.textHallOfFameTitle.color,
          onColorChanged: (color) =>
              preferences.textHallOfFameTitle.color = color,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Viewers names title',
          plainText: preferences.textHallOfFameName,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Today title',
          plainText: preferences.textHallOfFameToday,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'All time title',
          plainText: preferences.textHallOfFameAlltime,
        ),
        SizedBox(height: padding),
        _buildStringSelectorTile(
          context,
          title: 'Total done',
          plainText: preferences.textHallOfFameTotal,
          initialColor: preferences.textHallOfFameTotal.color,
          onColorChanged: (color) =>
              preferences.textHallOfFameTotal.color = color,
        ),
      ],
    );
  }

  StringSelectorTile _buildStringSelectorTile(
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
      onSizeChanged: plainText.runtimeType == TextOnPomodoro
          ? (direction) {
              (plainText as TextOnPomodoro).increaseSize(
                  direction == PlusOrMinusSelection.plus ? 0.01 : -0.01);
              if (focus != null) gainFocusCallback(focus);
            }
          : null,
      onMoveText: plainText.runtimeType == TextOnPomodoro
          ? (direction) {
              _moveText(context, (plainText as TextOnPomodoro).addToOffset,
                  direction);
              if (focus != null) gainFocusCallback(focus);
            }
          : null,
      initialColor: initialColor,
      onColorChanged: onColorChanged,
    );
  }
}
