import 'dart:io';

import 'package:common_lib/models/app_fonts.dart';
import 'package:common_lib/models/config.dart';
import 'package:common_lib/models/helpers.dart';
import 'package:common_lib/models/participant.dart';
import 'package:common_lib/providers/pomodoro_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

enum FileType { image, sound }

abstract class PreferencedElement {
  PreferencedElement({this.onChanged});

  bool shouldSendToWebClient = false;
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
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _value.toString();
  }
}

class PreferencedBool extends PreferencedElement {
  @override
  PreferencedBool(this._value);

  void set(bool value) {
    this.value = value;
  }

  bool serialize() {
    return _value;
  }

  static PreferencedBool deserialize(map, [bool defaultValue = false]) =>
      PreferencedBool(map ?? defaultValue);

  bool _value;
  bool get value => _value;
  set value(bool value) {
    _value = value;
    shouldSendToWebClient = true;
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
    shouldSendToWebClient = true;
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
    shouldSendToWebClient = true;
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
  PreferencedFile.fromPath(String? filepath, {this.lastVisitedFolderCallback})
      : _file = filepath == null ? null : File(filepath).readAsBytesSync(),
        _filename = filepath == null ? null : basename(filepath);

  @override
  PreferencedFile.fromRaw(
    Uint8List? rawFile, {
    String? filename,
  })  : _file = rawFile,
        _filename = filename;
  Function(Directory)? lastVisitedFolderCallback;

  Map<String, dynamic> serialize({withRawFile = false}) {
    return {
      'filename': _filename,
      'rawFile': withRawFile ? _file : null,
    };
  }

  String? _filename;
  String? get filename => _filename;

  Uint8List? _file;
  Future<void> setFile(File? originalFile) async {
    _file = originalFile == null
        ? null
        : await (await _copyFile(originalFile)).readAsBytes();
    _filename = originalFile == null ? null : basename(originalFile.path);
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
    if (originalFile != null && lastVisitedFolderCallback != null) {
      lastVisitedFolderCallback!(originalFile.parent);
    }
  }

  @override
  String toString() {
    return _filename ?? '';
  }

  ///
  /// Copy a file and return the name of the new file
  Future<File> _copyFile(File original) async {
    final targetPath = '${appDirectory.path}/${basename(original.path)}';
    return await original.copy(targetPath);
  }
}

class PreferencedImageFile extends PreferencedFile {
  @override
  FileType get fileType => FileType.image;

  PreferencedImageFile.fromRaw(Uint8List? rawFile,
      {String? filename, double? size})
      : _size = size ?? 1,
        _image = rawFile != null
            ? Image.memory(rawFile)
            : filename != null && !kIsWeb
                ? Image.file(File('${appDirectory.path}/$filename'))
                : null,
        super.fromRaw(rawFile, filename: filename);

  @override
  Future<void> setFile(File? originalFile) async {
    _image = originalFile == null ? null : Image.file(originalFile);
    super.setFile(originalFile);
  }

  Image? _image;
  Image? get image => _image;

  double _size;
  double get size => _size;
  set size(double value) {
    _size = value;
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
  }

  @override
  Map<String, dynamic> serialize({withRawFile = false}) {
    return super.serialize(withRawFile: withRawFile)..addAll({'size': _size});
  }

  static PreferencedImageFile deserialize(map) => PreferencedImageFile.fromRaw(
        map?['rawFile'] != null
            ? Uint8List.fromList((map?['rawFile'] as List).cast<int>())
            : map?['filename'] != null
                ? File('${appDirectory.path}/${map?['filename']}')
                    .readAsBytesSync()
                : null,
        filename: map?['filename'],
        size: map?['size'],
      );
}

class PreferencedSoundFile extends PreferencedFile {
  PreferencedSoundFile.fromRaw(Uint8List? rawFile, {String? filename})
      : super.fromRaw(rawFile, filename: filename);

  @override
  FileType get fileType => FileType.sound;

  static PreferencedSoundFile deserialize(map) => PreferencedSoundFile.fromRaw(
        map?['rawFile'] != null
            ? Uint8List.fromList((map?['rawFile'] as List).cast<int>())
            : map?['filename'] != null
                ? File('${appDirectory.path}/${map?['filename']}')
                    .readAsBytesSync()
                : null,
        filename: map?['filename'],
      );
}

class PreferencedText extends PreferencedElement {
  String _text;
  Color _color;
  AppFonts _font;

  String get text => _text;
  set text(String value) {
    _text = value;
    shouldSendToWebClient = true;
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
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
  }

  AppFonts get font => _font;
  set font(AppFonts value) {
    _font = value;
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
  }

  static PreferencedText deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    final color = Color(map?['color'] ?? 0xFF000000);
    final font = AppFonts.values[map?['font'] ?? 0];
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
    shouldSendToWebClient = true;
    if (onChanged != null) onChanged!();
  }

  double get size => _size;
  void increaseSize(double value) {
    _size += value;
    shouldSendToWebClient = true;
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
