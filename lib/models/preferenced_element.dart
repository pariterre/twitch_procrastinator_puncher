import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:twitch_procastinator_puncher/models/config.dart';
import 'package:twitch_procastinator_puncher/models/helpers.dart';
import 'package:twitch_procastinator_puncher/models/participant.dart';
import 'package:twitch_procastinator_puncher/models/reward_redemption.dart';
import 'package:twitch_procastinator_puncher/providers/app_preferences.dart';
import 'package:twitch_procastinator_puncher/providers/participants.dart';
import 'package:twitch_procastinator_puncher/providers/pomodoro_status.dart';

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

  static Future<PreferencedInt> deserialize(map,
          [int defaultValue = 0]) async =>
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

class PreferencedBool extends PreferencedElement {
  @override
  PreferencedBool(this._value);

  void set(bool value) {
    this.value = value;
  }

  bool serialize() {
    return _value;
  }

  static Future<PreferencedBool> deserialize(map,
          [bool defaultValue = false]) async =>
      PreferencedBool(map ?? defaultValue);

  bool _value;
  bool get value => _value;
  set value(bool value) {
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

  static Future<PreferencedColor> deserialize(map,
          [int defaultValue = 0xFF000000]) async =>
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

  static Future<PreferencedDuration> deserialize(map,
          [int defaultValue = 0]) async =>
      PreferencedDuration(Duration(seconds: map ?? defaultValue));

  static PreferencedDuration deserializeSync(map, [int defaultValue = 0]) =>
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

  PreferencedFile({Uint8List? raw, String? filepath})
      : _raw = raw,
        _filepath = filepath;

  Map<String, dynamic> serialize() => kIsWeb
      ? {'raw': _raw?.map<int>((e) => e).toList()}
      : {'filepath': _filepath};

  bool get hasFile => _raw != null;

  String? _filepath;
  String? get filename => _filepath == null ? null : basename(_filepath!);

  Uint8List? _raw;
  Future<void> setFileFromRaw(Uint8List raw, {String? filepath}) async {
    // Contrary to [setFile], it does not copy the original file anywhere
    _raw = raw;
    _filepath = filepath;
    if (onChanged != null) onChanged!();
  }

  ///
  /// This is a callback that is called whenever a file is set using [setFile].
  /// It is the programmer responsability to register to this callback.
  Function(Directory)? lastVisitedFolderCallback;

  Future<void> setFile(File originalFile) async {
    _raw = await (await _copyFile(originalFile)).readAsBytes();
    _filepath = originalFile.path;
    if (onChanged != null) onChanged!();
    if (lastVisitedFolderCallback != null) {
      lastVisitedFolderCallback!(originalFile.parent);
    }
  }

  void clear() {
    _raw = null;
    _filepath = null;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return filename ?? '';
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

  PreferencedImageFile() : super();

  PreferencedImageFile.fromRaw(Uint8List raw, {String? filepath, double? size})
      : _size = size ?? 1,
        super(raw: raw, filepath: filepath) {
    if (_raw != null) _image = Image.memory(_raw!);
  }

  static Future<PreferencedImageFile> fromPath(String filepath,
      {double? size}) async {
    final raw = await (kIsWeb
        ? PickedFile(filepath).readAsBytes()
        : File(filepath).readAsBytes());
    return PreferencedImageFile.fromRaw(raw, filepath: filepath, size: size);
  }

  @override
  Future<void> setFileFromRaw(Uint8List raw, {String? filepath, double? size}) {
    _image = Image.memory(raw);

    return super.setFileFromRaw(raw, filepath: filepath);
  }

  @override
  Future<void> setFile(File originalFile) async {
    _image = Image.file(originalFile);
    super.setFile(originalFile);
  }

  Image? _image;
  Image? get image => _image;

  double _size = 1;
  double get size => _size;
  set size(double value) {
    _size = value;
    if (onChanged != null) onChanged!();
  }

  @override
  Map<String, dynamic> serialize() {
    return super.serialize()..addAll({'size': _size});
  }

  static Future<PreferencedImageFile> deserialize(map) async {
    if (kIsWeb) {
      final raw = map?['raw'];
      if (raw == null) return PreferencedImageFile();

      return PreferencedImageFile.fromRaw(
          Uint8List.fromList((raw as List).map<int>((e) => e).toList()),
          size: map?['size']);
    } else {
      final filepath = map?['filepath'];
      if (filepath == null) return PreferencedImageFile();
      return await PreferencedImageFile.fromPath(filepath, size: map?['size']);
    }
  }

  @override
  void clear() {
    _size = 1;
    super.clear();
  }
}

class PreferencedSoundFile extends PreferencedFile {
  static Future<PreferencedSoundFile> fromPath(String filepath) async {
    final raw = await (kIsWeb
        ? PickedFile(filepath).readAsBytes()
        : File(filepath).readAsBytes());
    return PreferencedSoundFile.fromRaw(raw, filepath: filepath);
  }

  PreferencedSoundFile() : super();

  PreferencedSoundFile.fromRaw(Uint8List raw, {String? filepath})
      : super(raw: raw, filepath: filepath);

  @override
  FileType get fileType => FileType.sound;

  Source? get playableSource {
    if (_raw == null) return null;

    if (kIsWeb) {
      return UrlSource(
          Uri.dataFromBytes(_raw!, mimeType: 'audio/mpeg').toString());
    } else {
      return DeviceFileSource(_filepath!);
    }
  }

  static Future<PreferencedSoundFile> deserialize(map) async {
    if (kIsWeb) {
      final raw = map?['raw'];
      if (raw == null) return PreferencedSoundFile();

      return PreferencedSoundFile.fromRaw(
          Uint8List.fromList((raw as List).map<int>((e) => e).toList()));
    } else {
      final filepath = map?['filepath'];
      if (filepath == null) return PreferencedSoundFile();
      return await PreferencedSoundFile.fromPath(filepath);
    }
  }
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

  String formattedText(BuildContext context, [Participant? participant]) {
    final preferences = AppPreferences.of(context, listen: false);
    final pomodoro = PomodoroStatus.of(context, listen: false);
    final participants = Participants.of(context, listen: false);

    var out = text
        .replaceAll('{session}', (pomodoro.currentSession + 1).toString())
        .replaceAll('{nbSessions}', preferences.nbSessions.toString())
        .replaceAll('{timer}', durationAsString(pomodoro.timer))
        .replaceAll('{sessionTime}',
            durationAsString(preferences.sessionDurations[0].value))
        .replaceAll('{pauseTime}',
            durationAsString(preferences.pauseDurations[0].value))
        .replaceAll('{done}', participants.sessionsDone.toString())
        .replaceAll('{doneToday}', participants.sessionsDoneToday.toString())
        .replaceAll(r'\n', '\n');

    if (participant != null) {
      out = out
          .replaceAll('{username}', participant.username)
          .replaceAll('{userDone}', participant.sessionsDone.toString())
          .replaceAll(
              '{userDoneToday}', participant.sessionsDoneToday.toString());
    }
    return out;
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

  static Future<PreferencedText> deserialize(map,
          [String defaultValue = '']) async =>
      deserializeSync(map, defaultValue);

  static PreferencedText deserializeSync(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    final color = Color(map?['color'] ?? 0xFF000000);
    final font = AppFonts.values[map?['font'] ?? 0];
    return PreferencedText(text, color: color, font: font);
  }

  Map<String, dynamic> serialize() =>
      {'text': _text, 'color': _color.value, 'font': _font.index};
}

class UnformattedPreferencedText extends PreferencedText {
  UnformattedPreferencedText(String text) : super(text, color: Colors.white);

  static Future<UnformattedPreferencedText> deserialize(
          Map<String, dynamic>? map,
          [String defaultValue = '']) async =>
      UnformattedPreferencedText.deserializeSync(map, defaultValue);

  static UnformattedPreferencedText deserializeSync(Map<String, dynamic>? map,
      [String defaultValue = '']) {
    final text = map?['text'] ?? defaultValue;
    return UnformattedPreferencedText(text);
  }
}

class TextOnTimer extends PreferencedText {
  Offset _offset;
  double _size;

  TextOnTimer(
    String text, {
    required Offset offset,
    required double size,
    required super.color,
    super.onChanged,
  })  : _offset = offset,
        _size = size,
        super(text);

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

  static Future<TextOnTimer> deserialize(Map<String, dynamic>? map,
      [String defaultValue = '']) async {
    final text = map?['text'] ?? defaultValue;
    final offset = map?['offset'] ?? [0.0, 150.0];
    final size = map?['size'] ?? 1.0;
    final color = Color(map?['color'] ?? 0xFF000000);
    return TextOnTimer(text,
        offset: Offset(offset[0], offset[1]), size: size, color: color);
  }

  @override
  Map<String, dynamic> serialize() => super.serialize()
    ..addAll({
      'offset': [_offset.dx, _offset.dy],
      'size': _size,
    });
}

class RewardRedemptionPreferenced extends PreferencedElement {
  RewardRedemptionPreferenced({
    RewardRedemption rewardRedemption = RewardRedemption.none,
    String title = '',
    Duration duration = const Duration(minutes: 5),
  })  : _rewardRedemption = rewardRedemption,
        _title = title,
        _duration = duration;

  String _title;
  String get title => _title;
  set title(String value) {
    _title = value;
    if (onChanged != null) onChanged!();
  }

  RewardRedemption _rewardRedemption;
  RewardRedemption get rewardRedemption => _rewardRedemption;
  set rewardRedemption(RewardRedemption value) {
    _rewardRedemption = value;
    if (onChanged != null) onChanged!();
  }

  Duration _duration;
  Duration get duration => _duration;
  set duration(Duration value) {
    _duration = value;
    if (onChanged != null) onChanged!();
  }

  static RewardRedemptionPreferenced deserializeSync(map) =>
      RewardRedemptionPreferenced(
        title: map?['title'],
        rewardRedemption: RewardRedemption.values[map?['rewardRedemption']],
        duration: Duration(seconds: map?['duration'] ?? 60 * 5),
      );

  static Future<RewardRedemptionPreferenced> deserialize(map) async =>
      deserializeSync(map);

  Map<String, dynamic> serialize() => {
        'title': title,
        'rewardRedemption': rewardRedemption.index,
        'duration': duration.inSeconds,
      };
}
