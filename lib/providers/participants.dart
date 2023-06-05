import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_manager/twitch_manager.dart';
import 'package:twitch_pomorodo_timer/models/config.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';

class Participants extends ChangeNotifier {
  TwitchManager? _twitchManager;
  set twitchManager(TwitchManager manager) {
    _twitchManager = manager;
    Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _checkWhoIsConnected());
  }

  Function(String)? newUserHasConnected;

  List<String> _blacklist = [];
  set blacklist(String value) {
    _blacklist = value.split(';');
  }

  void _checkWhoIsConnected() async {
    final chatters =
        await _twitchManager!.api.fetchChatters(blacklist: _blacklist);
    debugPrint(chatters?.toString());
    if (chatters == null) return;

    // Disconnect users that are not connected anymore
    for (final user in all) {
      if (!chatters.contains(user.username)) {
        user.connect();
      }
    }

    // Connect new users
    final allUsernames = all.map((e) => e.username);
    for (final chatter in chatters) {
      if (!allUsernames.contains(chatter)) {
        final newParticipant = Participant(username: chatter);
        newParticipant.connect();
        all.add(newParticipant);
        if (newUserHasConnected != null) newUserHasConnected!(chatter);
      }
    }
  }

  final List<Participant> all;

  List<Participant> get connected =>
      all.map((e) => e.isConnected ? e : null).nonNulls.toList();

  final String _saveDir;
  static const _saveFilename = 'participants.json';
  String get _savePath => '$_saveDir/$_saveFilename';

  ///
  /// Main constructor of the Participants. [reload] will used previously saved
  /// file
  static Future<Participants> factory({bool reload = true}) async {
    final documentDirectory = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${documentDirectory.path}/$twitchAppName');
    if (!(await saveDir.exists())) {
      await saveDir.create(recursive: true);
    }

    final savedFile = File('${saveDir.path}/$_saveFilename');
    Map<String, dynamic>? savedParticipants;
    if (reload && await savedFile.exists()) {
      try {
        savedParticipants = jsonDecode(await savedFile.readAsString());
      } catch (_) {
        savedParticipants = null;
      }
    }
    return Participants._(
        all: savedParticipants?['participants']
                .map<Participant>((map) => Participant.deserialize(map))
                .toList() ??
            [],
        saveDir: saveDir.path);
  }

  static Participants of(BuildContext context, {listen = true}) =>
      Provider.of<Participants>(context, listen: listen);

  Participants._({required this.all, required String saveDir})
      : _saveDir = saveDir;

  Map<String, dynamic> serialize() =>
      {'participants': all.map((e) => e.serialize()).toList()};

  ///
  /// Save the current participants list to a file
  Future<void> save() async {
    final file = File(_savePath);
    await file.writeAsString(json.encode(serialize()));
    notifyListeners();
  }
}
