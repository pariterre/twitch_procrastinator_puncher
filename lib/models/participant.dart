import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';

class Participant {
  TwitchUser user;
  int sessionsDone;
  int sessionsDoneToday;
  bool _wasPreviouslyConnected = false;
  bool get wasPreviouslyConnected => _wasPreviouslyConnected;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  TimeOfDay? connectedSince;

  Participant({
    required this.user,
    this.sessionsDone = 0,
    this.sessionsDoneToday = 0,
  });

  void connect() {
    _isConnected = true;
    connectedSince = TimeOfDay.now();
    _wasPreviouslyConnected = true;
  }

  void disconnect() {
    _isConnected = false;
    connectedSince = null;
  }

  static Participant deserialize(map) => Participant(
      user: TwitchUser(
        id: map['user_id'] ?? '-1',
        login: map['login'] ?? '-1',
        displayName: map['username'] ?? '-1',
      ),
      sessionsDone: map['sessionDone'],
      sessionsDoneToday: map['sessionsDoneToday'] ?? 0);

  Map<String, dynamic> serialize() => {
        'user_id': user.id,
        'login': user.login,
        'username': user.displayName,
        'sessionDone': sessionsDone,
        'sessionsDoneToday': sessionsDoneToday,
      };
}
