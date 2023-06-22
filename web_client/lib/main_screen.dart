import 'dart:typed_data';

import 'package:common_lib/hall_of_fame.dart';
import 'package:common_lib/models/app_theme.dart';
import 'package:common_lib/pomodoro_timer.dart';
import 'package:common_lib/providers/app_preferences.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:common_lib/widgets/web_socket_holders.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BytesSource extends StreamAudioSource {
  final Uint8List _buffer;

  BytesSource(this._buffer) : super(tag: 'MyAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Returning the stream audio response with the parameters
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: (start ?? 0) - (end ?? _buffer.length),
      offset: start ?? 0,
      stream: Stream.fromIterable([_buffer.sublist(start ?? 0, end)]),
      contentType: 'audio/wav',
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const route = '/main-screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isInitialized = false;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Connect the callback of the timer
    final pomodoro = PomodoroStatus.of(context, listen: false);
    pomodoro.activeSessionHasFinishedGuiCallback = _activeSessionDone;
    pomodoro.pauseHasFinishedGuiCallback = _pauseSessionDone;
    pomodoro.finishedWorkingGuiCallback = _workingDone;
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  Future<void> _activeSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endActiveSessionSound.filename != null) {
      await _audioPlayer.setAudioSource(
          BytesSource(preferences.endActiveSessionSound.playableSource!),
          preload: false);
      await _audioPlayer.play();
    }
  }

  Future<void> _pauseSessionDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endPauseSessionSound.filename != null) {
      await _audioPlayer.setAudioSource(
          BytesSource(preferences.endPauseSessionSound.playableSource!),
          preload: false);
      await _audioPlayer.play();
    }
  }

  Future<void> _workingDone() async {
    final preferences = AppPreferences.of(context, listen: false);

    if (preferences.endWorkingSound.filename != null) {
      await _audioPlayer.setAudioSource(
          BytesSource(preferences.endWorkingSound.playableSource!),
          preload: false);
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final preferences = AppPreferences.of(context);
    final padding = ThemePadding.normal(context);

    final widget = Scaffold(
      backgroundColor: preferences.backgroundColor.value,
      body: WebSocketClientHolder(
        child: preferences.isConnectedToServer
            ? SizedBox(
                height: windowHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: padding),
                        const PomodoroTimer(
                            textWithFocus: StopWatchStatus.initializing),
                        SizedBox(height: padding),
                        if (preferences.useHallOfFame.value) const HallOfFame(),
                      ],
                    ),
                  ],
                ),
              )
            : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Connecting to configuration software\n'
                      'Please make sure the software is up and running!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
    isInitialized = true; // Prevent from calling setState on gainFocus
    return widget;
  }
}
