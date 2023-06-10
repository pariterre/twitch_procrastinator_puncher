import 'package:twitch_manager/twitch_manager.dart';

const preferencesFilename = 'preferences.json';
const textExportFilename = 'timer.txt';
const twitchAppName = 'ProcrastinationPuncher';
const twitchAppId = '961slpawos2f9a2me1mxdyolwtanoo';
const twitchRedirect = 'http://localhost:3000';
const twitchScope = [
  TwitchScope.chatRead,
  TwitchScope.chatEdit,
  TwitchScope.chatters,
  TwitchScope.readFollowers,
  TwitchScope.readSubscribers,
];
