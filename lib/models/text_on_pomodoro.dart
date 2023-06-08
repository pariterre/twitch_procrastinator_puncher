import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/helpers.dart';
import 'package:twitch_pomorodo_timer/models/participant.dart';
import 'package:twitch_pomorodo_timer/providers/pomodoro_status.dart';

class PlainText {
  String _text;
  Color _color;
  Function()? saveCallback;

  String get text => _text;
  set text(String value) {
    _text = value;
    if (saveCallback != null) saveCallback!();
  }

  PlainText({
    required String text,
    this.saveCallback,
    required Color color,
  })  : _text = text,
        _color = color;

  Color get color => _color;
  set color(Color value) {
    _color = value;
    if (saveCallback != null) saveCallback!();
  }

  static PlainText deserialize(
    Map<String, dynamic>? map, {
    required String defaultText,
  }) {
    final text = map?['text'] ?? defaultText;
    final color = Color(map?['color'] ?? 0xFFFFFFFF);
    return PlainText(text: text, color: color);
  }

  Map<String, dynamic> serialize() => {
        'text': _text,
        'color': _color.value,
      };
}

class TextToChat extends PlainText {
  TextToChat({required super.text}) : super(color: Colors.white);

  String formattedText(BuildContext context, Participant participant) {
    return text
        .replaceAll('{username}', participant.username)
        .replaceAll('{total}', participant.doneInAll.toString())
        .replaceAll(r'\n', '\n');
  }

  static TextToChat deserialize(
    Map<String, dynamic>? map, {
    required String defaultText,
  }) {
    final text = map?['text'] ?? defaultText;
    return TextToChat(text: text);
  }
}

class TextOnPomodoro extends PlainText {
  Offset _offset;
  double _size;

  TextOnPomodoro({
    required super.text,
    required Offset offset,
    required double size,
    required super.color,
    super.saveCallback,
  })  : _offset = offset,
        _size = size;

  // Foreground text during active session
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
    final color = Color(map?['color'] ?? 0xFFFFFFFF);
    return TextOnPomodoro(
        text: text,
        offset: Offset(offset[0], offset[1]),
        size: size,
        color: color);
  }

  @override
  Map<String, dynamic> serialize() => super.serialize()
    ..addAll({
      'offset': [_offset.dx, _offset.dy],
      'size': _size,
    });
}
