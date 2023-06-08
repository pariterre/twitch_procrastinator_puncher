import 'package:arrow_pad/arrow_pad.dart';
import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';
import 'package:twitch_pomorodo_timer/models/text_on_pomodoro.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';
import 'package:twitch_pomorodo_timer/providers/participants.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/color_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/dropmenu_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/file_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/int_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/plus_or_minus_list_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/string_selector_tile.dart';
import 'package:twitch_pomorodo_timer/screens/widgets/time_selector_tile.dart';
import 'package:twitch_pomorodo_timer/widgets/plus_or_minus.dart';

class ConfigurationBoard extends StatelessWidget {
  const ConfigurationBoard({
    super.key,
    required this.startTimerCallback,
    required this.pauseTimerCallback,
    required this.resetTimerCallback,
    required this.gainFocusCallback,
    required this.connectToTwitch,
  });

  final Function() startTimerCallback;
  final Function() pauseTimerCallback;
  final Function() resetTimerCallback;
  final Function(StopWatchStatus hasFocus) gainFocusCallback;
  final Function()? connectToTwitch;

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
    final appPreferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    return Column(
      children: [
        ColorSelectorTile(
            title: 'Background color',
            currentColor: ThemeColor().background,
            onChanged: (color) => appPreferences.backgroundColor = color),
        SizedBox(height: padding * 0.5),
        ColorSelectorTile(
            title: 'Text color on image',
            currentColor: ThemeColor().pomodoroText,
            onChanged: (color) => appPreferences.textColorPomodoro = color),
        SizedBox(height: padding * 0.5),
        ColorSelectorTile(
            title: 'Color of the hall of fame',
            currentColor: ThemeColor().hallOfFame,
            onChanged: (color) =>
                appPreferences.backgroundColorHallOfFame = color),
        SizedBox(height: padding * 0.5),
        ColorSelectorTile(
            title: 'Text color on the hall of fame',
            currentColor: ThemeColor().hallOfFameText,
            onChanged: (color) => appPreferences.textColorHallOfFame = color),
      ],
    );
  }

  Widget _buildController(context) {
    final preferences = AppPreferences.of(context);
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
        if (connectToTwitch != null && preferences.useHallOfFame)
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: padding),
              child: ElevatedButton(
                onPressed: connectToTwitch,
                style: ThemeButton.elevated,
                child: const Text(
                  'Connect to Twitch',
                  style: TextStyle(color: Colors.black),
                ),
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
            AppPreferences.of(context, listen: false).nbSessions = value;
            PomodoroStatus.of(context, listen: false).nbSessions = value;
          },
        ),
        SizedBox(height: padding),
        TimeSelectorTile(
          title: 'Session duration (mm:ss)',
          initialValue:
              AppPreferences.of(context, listen: false).sessionDuration,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).sessionDuration = value;
            PomodoroStatus.of(context, listen: false).focusSessionDuration =
                value;
          },
        ),
        SizedBox(height: padding),
        TimeSelectorTile(
          title: 'Pause duration (mm:ss)',
          initialValue: AppPreferences.of(context, listen: false).pauseDuration,
          onValidChange: (value) {
            AppPreferences.of(context, listen: false).pauseDuration = value;
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
            path: appPreferences.activeBackgroundImagePath,
            isImage: true,
            selectFileCallback: (filename) async =>
                await appPreferences.setActiveBackgroundImagePath(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Paused image',
            path: appPreferences.pauseBackgroundImagePath,
            isImage: true,
            selectFileCallback: (filename) async =>
                await appPreferences.setPauseBackgroundImagePath(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of active session',
            path: appPreferences.endActiveSessionSoundFilePath,
            isSound: true,
            selectFileCallback: (filename) async => await appPreferences
                .setEndActiveSessionSoundFilePath(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of pause',
            path: appPreferences.endPauseSessionSoundFilePath,
            isSound: true,
            selectFileCallback: (filename) async =>
                await appPreferences.setEndPauseSessionSoundFilePath(filename)),
        SizedBox(height: padding * 0.5),
        FileSelectorTile(
            title: 'Alarm end of working',
            path: appPreferences.endWorkingSoundFilePath,
            isSound: true,
            selectFileCallback: (filename) async =>
                await appPreferences.setWorkingSoundFilePath(filename)),
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
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during focus sessions',
          plainText: preferences.textDuringActiveSession,
          focus: StopWatchStatus.inSession,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during pause sessions',
          plainText: preferences.textDuringPauseSession,
          focus: StopWatchStatus.inPauseSession,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text during pauses',
          plainText: preferences.textDuringPause,
          focus: StopWatchStatus.paused,
        ),
        _buildStringSelectorTile(
          context,
          title: 'Text when done',
          plainText: preferences.textDone,
          focus: StopWatchStatus.done,
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
        PlusOrMinusListTile(
          title: const Text(
            'Scroll velocity',
            style: TextStyle(color: Colors.white),
          ),
          onTap: (selection) => preferences.hallOfFameScrollVelocity =
              selection == PlusOrMinusSelection.plus ? -100 : 100,
        ),
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
        _buildStringSelectorTile(
          context,
          title: 'Main title',
          plainText: preferences.textHallOfFameTitle,
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
        ),
      ],
    );
  }

  StringSelectorTile _buildStringSelectorTile(
    context, {
    required String title,
    required PlainText plainText,
    StopWatchStatus? focus,
    Function()? onTextComplete,
  }) {
    return StringSelectorTile(
      title: title,
      initialValue: plainText.text,
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
    );
  }
}
