import 'package:flutter/material.dart';
import 'package:common_lib/models/helpers.dart';
import 'package:common_lib/models/participant.dart';
import 'package:common_lib/providers/pomodoro_status.dart';

abstract class PreferencedElement {
  PreferencedElement({this.onChanged});

  Function()? onChanged;

  static PreferencedElement deserialize() => throw UnimplementedError();
}

class PreferencedInt extends PreferencedElement {
  @override
  PreferencedInt(this._value);

  void set(int value) {
    this.value = value;
  }

  int serialize() {
    return _value;
  }

  static PreferencedInt deserialize(map, [int defaultValue = 0]) =>
      PreferencedInt(map ?? defaultValue);

  int _value;
  int get value => _value;
  set value(int value) {
    _value = value;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _value.toString();
  }
}

class PreferencedText extends PreferencedElement {
  String _text;
  Color _color;

  String get text => _text;
  set text(String value) {
    _text = value;
    if (onChanged != null) onChanged!();
  }

  PreferencedText(
    String text, {
    super.onChanged,
    required Color color,
  })  : _text = text,
        _color = color;

  Color get color => _color;
  set color(Color value) {
    _color = value;
    if (onChanged != null) onChanged!();
  }

  static PreferencedText deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    final color = Color(map?['color'] ?? 0xFF000000);
    return PreferencedText(text, color: color);
  }

  Map<String, dynamic> serialize() => {'text': _text, 'color': _color.value};
}

class TextToChat extends PreferencedText {
  TextToChat(String text) : super(text, color: Colors.white);

  String formattedText(BuildContext context, Participant participant) {
    return text
        .replaceAll('{username}', participant.username)
        .replaceAll('{total}', participant.doneInAll.toString())
        .replaceAll(r'\n', '\n');
  }

  static TextToChat deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    return TextToChat(text);
  }
}

class TextOnPomodoro extends PreferencedText {
  Offset _offset;
  double _size;

  TextOnPomodoro(
    String text, {
    required Offset offset,
    required double size,
    required super.color,
    super.onChanged,
  })  : _offset = offset,
        _size = size,
        super(text);

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
    if (onChanged != null) onChanged!();
  }

  double get size => _size;
  void increaseSize(double value) {
    _size += value;
    if (onChanged != null) onChanged!();
  }

  static TextOnPomodoro deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    final offset = map?['offset'] ?? [0.0, 0.0];
    final size = map?['size'] ?? 1.0;
    final color = Color(map?['color'] ?? 0xFFFFFFFF);
    return TextOnPomodoro(text,
        offset: Offset(offset[0], offset[1]), size: size, color: color);
  }

  @override
  Map<String, dynamic> serialize() => super.serialize()
    ..addAll({
      'offset': [_offset.dx, _offset.dy],
      'size': _size,
    });
}
