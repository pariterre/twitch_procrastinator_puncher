import 'package:flutter/material.dart';

class Participant {
  String username;
  int doneInAll;
  int doneToday;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  TimeOfDay? connectedSince;

  Participant({
    required this.username,
    this.doneInAll = 0,
    this.doneToday = 0,
  });

  void connect() {
    _isConnected = true;
    connectedSince = TimeOfDay.now();
  }

  void disconnect() {
    _isConnected = false;
    connectedSince = null;
  }

  static Participant deserialize(map) =>
      Participant(username: map['username'], doneInAll: map['sessionDone']);

  Map<String, dynamic> serialize() => {
        'username': username,
        'sessionDone': doneInAll,
      };
}
