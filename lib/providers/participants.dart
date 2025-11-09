import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_procastinator_puncher/helpers/file_picker_interface.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/participant.dart';

List<String> _extractUsersFromString(String value) {
  final List<String> out = value.split(';');

  // Remove trailling spaces
  for (var i = 0; i < out.length; i++) {
    out[i] = out[i].trim();
  }

  return out;
}

class Participants extends ChangeNotifier {
  TwitchAppManager? _twitchManager;
  set twitchManager(TwitchAppManager manager) {
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

  void addSessionDoneToAllConnected() {
    for (final user in all) {
      if (user.isConnected) {
        user.sessionsDoneToday += 1;
        user.sessionsDone += 1;
      }
    }
    disconnectAll(); // They will be reconnected automatically
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
  List<String>? _blacklist;
  set blacklist(String value) {
    _blacklist = value.isEmpty ? null : _extractUsersFromString(value);

    // Remove from the list all blacklisted users
    for (final identifier in (_blacklist ?? [])) {
      all.removeWhere((e) => (e.user.displayName == identifier ||
          e.user.login == identifier ||
          e.user.id == identifier));
    }

    notifyListeners();
  }

  void _checkWhoIsConnected() async {
    if (!_twitchManager!.isConnected) return;

    final chatters =
        (await _twitchManager!.api.fetchChatters(blacklist: _blacklist))
            ?.toList();
    if (chatters == null) return;

    final followers =
        (await _twitchManager!.api.fetchFollowers(includeStreamer: true))
            ?.toList();
    if (followers == null) return;

    bool hasChanged = false;

    // Remove users that are not followers (if must follow) and blacklisted
    for (var i = chatters.length - 1; i >= 0; i--) {
      final chatter = chatters[i];

      // If the chatter is whitelisted, never remove
      if (!_whitelist.has(chatter)) {
        // If the chatter was blacklisted, or should (but does not) follow
        if ((_blacklist?.has(chatter) ?? false) ||
            (mustFollowForFaming && !followers.has(user: chatter))) {
          chatters.removeWhere((e) => e == chatter);
          hasChanged = true;
        }
      }
    }

    // Connect new users
    // final allUsernames = all.map((e) => e.user.displayName);
    for (final chatter in chatters) {
      // Try to find the participant by login (which is unmutable)
      var participant =
          all.firstWhereOrNull((e) => e.user.login == chatter.login);

      // Check if the participant can be found by display name (old version)
      if (participant == null) {
        participant = all
            .firstWhereOrNull((e) => e.user.displayName == chatter.displayName);
        if (participant != null) {
          // If we have found a display name but not a login, it means it is a
          // participant saved with an old version. So overwrite it with
          // the new user object
          participant.user = chatter;
        }
      }

      // If the user is still not found then they are a newcomer
      if (participant == null) {
        participant = Participant(user: chatter);
        participant.connect();
        all.add(participant);
        hasChanged = true;

        if (greetNewcomerCallback != null) {
          greetNewcomerCallback!(participant);
        }
      }

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
    }
  }

  final List<Participant> all;

  List<Participant> get connected =>
      all.map((e) => e.isConnected ? e : null).nonNulls.toList();

  static const _saveFilename = 'participants.json';
  String get _savePath => '${appDirectory.path}/$_saveFilename';

  ///
  /// Main constructor of the Participants. [reload] will used previously saved
  /// file
  static Future<Participants> factory({
    bool reload = true,
    required bool mustFollowForFaming,
    required String whitelist,
    required String blacklist,
  }) async {
    Future<String?> readParticipantFromDisk() async {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_saveFilename);
      } else {
        final saveDir = appDirectory;
        if (!(await saveDir.exists())) {
          await saveDir.create(recursive: true);
        }

        final savedFile = File('${saveDir.path}/$_saveFilename');
        if (!(await savedFile.exists())) return null;

        return await savedFile.readAsString();
      }
    }

    final participantsAsString = await readParticipantFromDisk();
    Map<String, dynamic>? savedParticipants;
    if (reload && participantsAsString != null) {
      try {
        savedParticipants = jsonDecode(participantsAsString);
      } catch (_) {
        savedParticipants = null;
      }
    }

    final participants = (savedParticipants?['participants'] as List?)
            ?.map<Participant>((map) => Participant.deserialize(map))
            .toList() ??
        [];
    for (final participant in participants) {
      participant.sessionsDoneToday = 0;
    }

    return Participants._(
      all: participants,
      mustFollowForFaming: mustFollowForFaming,
      whitelist: whitelist,
      blacklist: blacklist,
    );
  }

  static Participants of(BuildContext context, {listen = true}) =>
      Provider.of<Participants>(context, listen: listen);

  Participants._({
    required this.all,
    required this.mustFollowForFaming,
    required String whitelist,
    required String blacklist,
  })  : _whitelist = [],
        _blacklist = [] {
    this.whitelist = whitelist; // Fill the whitelist
    this.blacklist = blacklist; // Fill the blacklist
  }

  Map<String, dynamic> serialize() =>
      {'participants': all.map((e) => e.serialize()).toList()};

  ///
  /// Save the current participants list to a file
  Future<void> _save() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_saveFilename, jsonEncode(serialize()));
    } else {
      final file = File(_savePath);
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(serialize()));
    }
    notifyListeners();
  }

  Future<void> exportWeb(context) async {
    if (!kIsWeb) throw 'exportWeb only works on web-based interface';

    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(serialize());
    FilePickerInterface.instance
        .saveFile(context, data: text, filename: _saveFilename);
  }

  Future<void> importWeb(context) async {
    if (!kIsWeb) throw 'importWeb only works on web-based interface';

    final result = await FilePickerInterface.instance.pickFile(context);
    if (result == null) return;

    final loadedParticipants = json.decode(utf8.decode(result));

    final participants = (loadedParticipants?['participants'] as List?)
            ?.map<Participant>((map) => Participant.deserialize(map))
            .toList() ??
        [];

    all.clear();
    for (final participant in participants) {
      participant.sessionsDoneToday = 0;
      all.add(participant);
    }

    _save();
  }
}
