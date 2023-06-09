import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/participant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twitch_manager/twitch_manager.dart';

List<String> _extractUsersFromString(String value) {
  final List<String> out = value.split(';');

  // Remove trailling spaces
  for (var i = 0; i < out.length; i++) {
    out[i] = out[i].trim();
  }

  return out;
}

class Participants extends ChangeNotifier {
  TwitchManager? _twitchManager;
  set twitchManager(TwitchManager manager) {
    _twitchManager = manager;
    _checkWhoIsConnected();
    Timer.periodic(
        const Duration(minutes: 1), (Timer t) => _checkWhoIsConnected());
  }

  ///
  /// This is the callback that the GUI must register to update itself when
  /// a new user connected for the first time
  Function(Participant)? greetNewcomerCallback;

  ///
  /// This is the callback that the GUI must register to update itself when
  /// a user has connected
  Function(Participant)? greetUserHasConnectedCallback;

  ///
  /// If the participant must be a follower to be counted
  bool mustFollowForFaming;

  ///
  /// If any change occurred, web client should be notified
  bool shouldSendToWebClient = false;

  void addSessionDoneToAllConnected() {
    for (final user in all) {
      if (user.isConnected) {
        user.sessionsDoneToday += 1;
        user.sessionsDone += 1;
      }
    }
    disconnectAll(); // They will be reconnected automatically
    shouldSendToWebClient = true;
    _save();
    notifyListeners();
  }

  void disconnectAll() {
    for (final user in all) {
      user.disconnect();
    }
  }

  ///
  /// Number of sessions done all time
  int get sessionsDone => all.fold<int>(0, (prev, e) => prev + e.sessionsDone);

  ///
  /// Number of sessions done today
  int get sessionsDoneToday =>
      all.fold<int>(0, (prev, e) => prev + e.sessionsDoneToday);

  ///
  /// The blacklist removes specific users from the all list (and prevent them
  /// to connect)
  List<String> _whitelist;
  set whitelist(String value) {
    _whitelist = _extractUsersFromString(value);

    notifyListeners();
  }

  ///
  /// The blacklist removes specific users from the all list (and prevent them
  /// to connect)
  List<String> _blacklist;
  set blacklist(String value) {
    _blacklist = _extractUsersFromString(value);

    // Remove from the list all blacklisted users
    for (final username in _blacklist) {
      all.removeWhere((e) => e.username == username);
    }

    notifyListeners();
  }

  void _checkWhoIsConnected() async {
    if (!_twitchManager!.isConnected) return;

    final chatters =
        await _twitchManager!.api.fetchChatters(blacklist: _blacklist);
    if (chatters == null) return;

    final followers = await _twitchManager!.api.fetchFollowers();
    if (followers == null) return;

    bool hasChanged = false;

    // Remove users that are not followers (if must follow) and blacklisted
    for (var i = chatters.length - 1; i >= 0; i--) {
      final chatter = chatters[i];

      // If the chatter is whitelisted, never remove
      if (!_whitelist.contains(chatter)) {
        // If the chatter was blacklisted, or should (but does not) follow
        if (_blacklist.contains(chatter) ||
            (mustFollowForFaming && !followers.contains(chatter))) {
          chatters.removeWhere((e) => e == chatter);
          hasChanged = true;
        }
      }
    }

    // Connect new users
    final allUsernames = all.map((e) => e.username);
    for (final chatter in chatters) {
      // If the user is new to the channel
      if (!allUsernames.contains(chatter)) {
        final newParticipant = Participant(username: chatter);
        newParticipant.connect();
        all.add(newParticipant);
        hasChanged = true;

        if (greetNewcomerCallback != null) {
          greetNewcomerCallback!(newParticipant);
        }
      }

      final participant = all.firstWhere((e) => e.username == chatter);
      // If the user was not connected, connect them
      if (!participant.isConnected) {
        // Greet them if it the first connexion today but is not a newcomer
        if (!participant.wasPreviouslyConnected &&
            participant.sessionsDone > 0) {
          if (greetUserHasConnectedCallback != null) {
            greetUserHasConnectedCallback!(participant);
          }
        }

        participant.connect();
        hasChanged = true;
      }
    }

    if (hasChanged) {
      notifyListeners();
      shouldSendToWebClient = true;
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
  static Future<Participants> factory({
    bool reload = true,
    required bool mustFollowForFaming,
    required String whitelist,
    required String blacklist,
  }) async {
    Map<String, dynamic>? savedParticipants;
    late final Directory saveDir;
    if (kIsWeb) {
      saveDir = Directory('');
    } else {
      final documentDirectory = await getApplicationDocumentsDirectory();
      saveDir = Directory('${documentDirectory.path}/$twitchAppName');
      if (!(await saveDir.exists())) {
        await saveDir.create(recursive: true);
      }

      final savedFile = File('${saveDir.path}/$_saveFilename');

      if (reload && await savedFile.exists()) {
        try {
          savedParticipants = jsonDecode(await savedFile.readAsString());
        } catch (_) {
          savedParticipants = null;
        }
      }
    }

    return Participants._(
      all: savedParticipants?['participants']
              .map<Participant>((map) => Participant.deserialize(map))
              .toList() ??
          [],
      saveDir: saveDir.path,
      mustFollowForFaming: mustFollowForFaming,
      whitelist: whitelist,
      blacklist: blacklist,
    );
  }

  static Participants of(BuildContext context, {listen = true}) =>
      Provider.of<Participants>(context, listen: listen);

  Participants._({
    required this.all,
    required String saveDir,
    required this.mustFollowForFaming,
    required String whitelist,
    required String blacklist,
  })  : _saveDir = saveDir,
        _whitelist = [],
        _blacklist = [] {
    this.whitelist = whitelist; // Fill the whitelist
    this.blacklist = blacklist; // Fill the blacklist
  }

  Map<String, dynamic> serialize() =>
      {'participants': all.map((e) => e.serialize()).toList()};

  Map<String, dynamic> serializeForWebClient(bool initial) {
    final out =
        shouldSendToWebClient || initial ? serialize() : {'participants': null};
    shouldSendToWebClient = false;
    return out;
  }

  void updateWebClient(map) {
    if (map['participants'] == null) return;

    all.clear();
    for (final p in map['participants']) {
      all.add(Participant.deserialize(p));
    }
  }

  ///
  /// Save the current participants list to a file
  Future<void> _save() async {
    if (!kIsWeb) {
      final file = File(_savePath);
      const encoder = JsonEncoder.withIndent('\t');
      await file.writeAsString(encoder.convert(serialize()));
    }
    notifyListeners();
  }
}
