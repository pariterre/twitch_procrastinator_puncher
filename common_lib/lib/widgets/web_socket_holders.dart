import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/participants.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_client/web_socket_client.dart' as ws;

const _port = 8080;
const _serverUrl = 'ws://localhost:$_port';

class WebSocketClientHolder extends StatefulWidget {
  const WebSocketClientHolder({super.key, required this.child});
  final Widget child;

  @override
  State<WebSocketClientHolder> createState() => _WebSocketClientHolderState();
}

class _WebSocketClientHolderState extends State<WebSocketClientHolder> {
  @override
  void initState() {
    super.initState();
    initializedWebsocket();
  }

  bool initializing = true;
  void initializedWebsocket() async {
    final channel = ws.WebSocket(Uri.parse(_serverUrl));

    initializing = true;
    channel.messages.listen((message) {
      final map = jsonDecode(message);

      if (initializing) {
        if (map?['answerType'] != 'initial') {
          channel.send(jsonEncode({'command': 'initializing'}));
          return;
        }
        initializing = false;
      }

      final preferences = AppPreferences.of(context, listen: false);
      final participants = Participants.of(context, listen: false);
      final status = PomodoroStatus.of(context, listen: false);
      preferences.updateWebClient(map['preferences']);
      participants.updateFromSerialized(map['participants']);
      status.updateFromSerialized(map['status']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class WebSocketServerHolder extends StatefulWidget {
  const WebSocketServerHolder({super.key, required this.child});
  final Widget child;

  @override
  State<WebSocketServerHolder> createState() => _WebSocketServerHolderState();
}

class _WebSocketServerHolderState extends State<WebSocketServerHolder> {
  WebSocket? _socket;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializedWebSocket();
  }

  void _initializedWebSocket() async {
    if (_socket != null) return;

    var webSocketTransformer = WebSocketTransformer();

    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv6, _port);
    server.transform(webSocketTransformer).listen((WebSocket webSocket) {
      log('Client has connected');
      _socket = webSocket;
      _socket!.listen(_listenToWebClient);
      _sendAll(initial: true);
    });
  }

  void _listenToWebClient(message) {
    final map = jsonDecode(message);
    // Invalid formatting
    if (map?['command'] == null) return;

    if (map!['command'] == 'initializing') {
      _sendAll(initial: true);
    }
  }

  void _sendAll({initial = false}) {
    final preferences = AppPreferences.of(context, listen: !initial);
    final participants = Participants.of(context, listen: !initial);
    final status = PomodoroStatus.of(context, listen: !initial);

    _socket!.add(json.encode({
      'answerType': initial ? 'initial' : 'normal',
      'preferences': preferences.serializeForWebClient(initial),
      'participants': participants.serialize(),
      'status': status.serialize(),
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_socket != null) _sendAll();

    return widget.child;
  }
}
