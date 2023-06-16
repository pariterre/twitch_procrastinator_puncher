import 'dart:io';

import 'package:common_lib/models/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:common_lib/models/helpers.dart';
import 'package:common_lib/models/participant.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:path/path.dart';

enum FileType { image, sound }

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

class PreferencedColor extends PreferencedElement {
  @override
  PreferencedColor(this._value);

  void set(Color value) {
    this.value = value;
  }

  int serialize() {
    return _value.value;
  }

  static PreferencedColor deserialize(map, [int defaultValue = 0xFF000000]) =>
      PreferencedColor(Color(map ?? defaultValue));

  Color _value;
  Color get value => _value;
  set value(Color value) {
    _value = value;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _value.toString();
  }
}

class PreferencedDuration extends PreferencedElement {
  @override
  PreferencedDuration(this._value);

  void set(Duration value) {
    this.value = value;
  }

  int serialize() {
    return _value.inSeconds;
  }

  static PreferencedDuration deserialize(map, [int defaultValue = 0]) =>
      PreferencedDuration(Duration(seconds: map ?? defaultValue));

  Duration _value;
  Duration get value => _value;
  set value(Duration value) {
    _value = value;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _value.toString();
  }
}

abstract class PreferencedFile extends PreferencedElement {
  FileType get fileType;

  @override
  PreferencedFile(this.savepath, String? file, [this.lastVisitedFolderCallback])
      : _file = file == null ? null : File('${savepath.path}/$file');
  final Directory savepath;
  Function(Directory)? lastVisitedFolderCallback;

  Map<String, dynamic> serialize() {
    return {'filename': _file == null ? null : basename(_file!.path)};
  }

  File? _file;
  File? get file => _file;
  String? get filepath => _file == null ? null : _file!.path;
  String? get filename => _file == null ? null : basename(_file!.path);
  Future<void> setFile(File? originalFile) async {
    _file = originalFile == null ? null : await _copyFile(originalFile);
    if (onChanged != null) onChanged!();
    if (originalFile != null && lastVisitedFolderCallback != null) {
      lastVisitedFolderCallback!(originalFile.parent);
    }
  }

  @override
  String toString() {
    return _file == null ? '' : basename(_file!.path);
  }

  ///
  /// Copy a file and return the name of the new file
  Future<File> _copyFile(File original) async {
    final targetPath = '${savepath.path}/${basename(original.path)}';
    return await original.copy(targetPath);
  }
}

class PreferencedImageFile extends PreferencedFile {
  @override
  FileType get fileType => FileType.image;

  PreferencedImageFile(super.savepath, super.file, {double? size})
      : _size = size ?? 1;

  double _size;
  double get size => _size;
  set size(double value) {
    _size = value;
    if (onChanged != null) onChanged!();
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()..addAll({'size': _size});
  }

  static PreferencedImageFile deserialize(Directory savepath, map) =>
      PreferencedImageFile(savepath, map?['filename'], size: map?['size']);
}

class PreferencedSoundFile extends PreferencedFile {
  PreferencedSoundFile(super.savepath, super.file);

  @override
  FileType get fileType => FileType.sound;

  static PreferencedSoundFile deserialize(Directory savepath, map) =>
      PreferencedSoundFile(savepath, map?['filename']);
}

class PreferencedText extends PreferencedElement {
  String _text;
  Color _color;
  AppFonts _font;

  String get text => _text;
  set text(String value) {
    _text = value;
    if (onChanged != null) onChanged!();
  }

  PreferencedText(
    String text, {
    super.onChanged,
    required Color color,
    AppFonts? font,
  })  : _text = text,
        _color = color,
        _font = font ?? AppFonts.alegreya;

  Color get color => _color;
  set color(Color value) {
    _color = value;
    if (onChanged != null) onChanged!();
  }

  AppFonts get font => _font;
  set font(AppFonts value) {
    _font = value;
    if (onChanged != null) onChanged!();
  }

  static PreferencedText deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    final color = Color(map?['color'] ?? 0xFF000000);
    final font = AppFonts.values[map?['font']];
    return PreferencedText(text, color: color, font: font);
  }

  Map<String, dynamic> serialize() =>
      {'text': _text, 'color': _color.value, 'font': _font.index};
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
