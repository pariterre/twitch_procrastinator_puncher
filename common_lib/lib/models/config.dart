import 'package:twitch_manager/twitch_manager.dart';

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
