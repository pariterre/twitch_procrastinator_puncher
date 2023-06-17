import 'package:common_lib/models/preferenced_element.dart';

enum Language {
  english,
  french,
}

class PreferencedLanguage extends PreferencedElement {
  @override
  PreferencedLanguage(this._current);

  int serialize() {
    return _current.index;
  }

  static PreferencedLanguage deserialize(map, [int defaultValue = 0]) =>
      PreferencedLanguage(Language.values[map ?? defaultValue]);

  Language _current;
  Language get language => _current;
  set language(Language value) {
    _current = value;
    if (onChanged != null) onChanged!();
  }

  @override
  String toString() {
    return _current.toString();
  }

  String get mainTitle {
    switch (_current) {
      case Language.english:
        return 'The Procrastinator Puncher';
      case Language.french:
        return 'Le Chasseur de Procrastination';
    }
  }
}
