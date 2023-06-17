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
  if (kIsWeb) {
    _appDirectory = Directory('');
    return;
  }

  final appDir = await getApplicationDocumentsDirectory();
  _appDirectory = Directory('${appDir.path}/$twitchAppName');
  if (!(await _appDirectory!.exists())) {
    await _appDirectory!.create(recursive: true);
  }
}

const preferencesFilename = 'preferences.json';
const textExportFilename = 'timer.txt';
const twitchAppName = 'ProcrastinatorPuncher';
const twitchAppId = 'mcysoxq3vitdjwcqn71f8opz11cyex';
const twitchRedirect = 'http://localhost:3000';
const twitchScope = [
  TwitchScope.chatRead,
  TwitchScope.chatEdit,
  TwitchScope.chatters,
  TwitchScope.readFollowers,
  TwitchScope.readSubscribers,
];
