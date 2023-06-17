import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Language {
  english,
  french,
}

class AppLocale with ChangeNotifier {
  Language _language = Language.english;
  Language get language => _language;
  set language(Language value) {
    _language = value;
    notifyListeners();
  }

  static AppLocale of(BuildContext context, {listen = true}) =>
      Provider.of(context, listen: listen);

  // TODO CLOSE BUTTON AND TRADUCTION
  String get coucou {
    switch (_language) {
      case Language.english:
        return 'yo';
      case Language.french:
        return 'coucou';
    }
  }
}
