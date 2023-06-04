import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/helpers.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class TextOnPomodoro {
  String _text;
  Offset _offset;
  double _size;
  Function()? saveCallback;

  TextOnPomodoro({
    required String text,
    required Offset offset,
    required double size,
    this.saveCallback,
  })  : _text = text,
        _offset = offset,
        _size = size;

  // Foreground text during active session
  String get text => _text;
  String formattedText(BuildContext context) {
    final pomodoro = PomodoroStatus.of(context, listen: false);
    return text
        .replaceAll(
            '{currentSession}', (pomodoro.currentSession + 1).toString())
        .replaceAll('{maxSessions}', pomodoro.nbSessions.toString())
        .replaceAll('{timer}', durationAsString(pomodoro.timer))
        .replaceAll('{sessionDuration}',
            durationAsString(pomodoro.focusSessionDuration))
        .replaceAll(
            '{pauseDuration}', durationAsString(pomodoro.pauseSessionDuration))
        .replaceAll(r'\n', '\n');
  }

  set text(String value) {
    _text = value;
    if (saveCallback != null) saveCallback!();
  }

  // Offset of the text on the screen
  Offset get offset => _offset;
  void addToOffset(Offset offset) {
    _offset += offset;
    if (saveCallback != null) saveCallback!();
  }

  double get size => _size;
  void increaseSize(double value) {
    _size += value;
    if (saveCallback != null) saveCallback!();
  }

  static TextOnPomodoro deserialize(
    Map<String, dynamic>? map, {
    required String defaultText,
  }) {
    final text = map?['text'] ?? defaultText;
    final offset = map?['offset'] ?? [0.0, 0.0];
    final size = map?['size'] ?? 1.0;
    return TextOnPomodoro(
        text: text, offset: Offset(offset[0], offset[1]), size: size);
  }

  Map<String, dynamic> serialize() => {
        'text': _text,
        'offset': [_offset.dx, _offset.dy],
        'size': _size,
      };
}
