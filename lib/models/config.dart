import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twitch_manager/twitch_manager.dart';

Directory? _appDirectory;
Directory get appDirectory {
  if (_appDirectory == null) {
    throw 'Please call \'declareAppDirectory\' at least '
        'once before trying to get \'appDirectory\'';
  }
  return _appDirectory!;
}

Future<void> declareAppDirectory() async {
  if (!kIsWeb) {
    final appDir = await getApplicationDocumentsDirectory();
    _appDirectory = Directory('${appDir.path}/$twitchAppName');
    if (!(await _appDirectory!.exists())) {
      await _appDirectory!.create(recursive: true);
    }
  }
}

const webClientSite = 'https://procrastinatorpuncher.pariterre.net';
const buyMeACoffeeLink = 'https://www.buymeacoffee.com/pariterre';
const preferencesFilename = 'preferences.json';
const textExportFilename = 'timer.txt';
const twitchAppName = 'ProcrastinatorPuncher';
const twitchAppId = 'mcysoxq3vitdjwcqn71f8opz11cyex';
const twitchScope = [
  TwitchScope.chatRead,
  TwitchScope.chatEdit,
  TwitchScope.chatters,
  TwitchScope.readFollowers,
  TwitchScope.readModerator,
  TwitchScope.rewardRedemption,
];

final twitchDebugPanelOptions = TwitchDebugPanelOptions(
  chatters: [
    TwitchChatterMock(displayName: 'Streamer', isModerator: true),
    TwitchChatterMock(displayName: 'Moderator 1', isModerator: true),
    TwitchChatterMock(displayName: 'Moderator 2', isModerator: true),
    TwitchChatterMock(displayName: 'Viewer 1'),
    TwitchChatterMock(displayName: 'Viewer 2'),
  ],
  chatMessages: const ['!startTimer', '!pauseTimer', '!resetTimer'],
  redemptionRewardEvents: [
    TwitchEventMock(rewardRedemption: 'Plus de plaisir!', cost: 5000),
  ],
);
const bool isTwitchMockActive = false;
