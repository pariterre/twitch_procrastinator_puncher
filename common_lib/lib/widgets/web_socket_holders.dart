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

  void initializedWebsocket() async {
    final channel = ws.WebSocket(Uri.parse(_serverUrl));

    channel.messages.listen((message) {
      final map = jsonDecode(message);

      final preferences = AppPreferences.of(context, listen: false);
      final participants = Participants.of(context, listen: false);
      final status = PomodoroStatus.of(context, listen: false);
      preferences.updateFromSerialized(map['preferences']);
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
    initializedWebsocket();
  }

  void initializedWebsocket() async {
    if (_socket != null) return;

    var webSocketTransformer = WebSocketTransformer();

    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv6, _port);
    server.transform(webSocketTransformer).listen((WebSocket webSocket) {
      log('Client has connected');
      _socket = webSocket;
      _sendAll();
    });
  }

  void _sendAll() {
    final preferences = AppPreferences.of(context);
    final participants = Participants.of(context);
    final status = PomodoroStatus.of(context);
    _socket!.add(json.encode({
      'preferences': preferences.serialize(),
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
