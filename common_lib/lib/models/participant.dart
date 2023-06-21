import 'package:flutter/material.dart';

class Participant {
  String username;
  int sessionsDone;
  int sessionsDoneToday;
  bool _wasPreviouslyConnected = false;
  bool get wasPreviouslyConnected => _wasPreviouslyConnected;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  TimeOfDay? connectedSince;

  Participant({
    required this.username,
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

  static Participant deserialize(map) =>
      Participant(username: map['username'], sessionsDone: map['sessionDone']);

  Map<String, dynamic> serialize() => {
        'username': username,
        'sessionDone': sessionsDone,
      };
}
