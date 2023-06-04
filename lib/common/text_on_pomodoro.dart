import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class TextOnPomodoro {
  String _text;
  Offset _offset;
  Function()? saveCallback;

  TextOnPomodoro({
    required String text,
    required Offset offset,
    this.saveCallback,
  })  : _text = text,
        _offset = offset;

  // Foreground text during active session
  String get text => _text;
  String formattedText(BuildContext context) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    return text
        .replaceAll('{timer}', durationAsString(pomodoro.timer))
        .replaceAll(r'\n', '\n')
        .replaceAll('{currentSession}', pomodoro.currentSession.toString())
        .replaceAll('{maxSessions}', pomodoro.nbSessions.toString());
  }

  set text(String value) {
    _text = value;
    if (saveCallback != null) saveCallback!();
  }

  // Foreground text during active session
  Offset get offset => _offset;
  void addToOffset(Offset offset) {
    _offset += offset;
    if (saveCallback != null) saveCallback!();
  }

  static TextOnPomodoro deserialize(
    Map<String, dynamic>? map, {
    required String defaultText,
  }) {
    final text = map?['text'] ?? defaultText;
    final offset = map?['offset'] ?? [0.0, 0.0];
    return TextOnPomodoro(text: text, offset: Offset(offset[0], offset[1]));
  }

  Map<String, dynamic> serialize() => {
        'text': _text,
        'offset': [_offset.dx, _offset.dy]
      };
}
