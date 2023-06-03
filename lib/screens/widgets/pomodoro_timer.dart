import 'dart:io';

import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/providers/app_preferences.dart';

class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final appPreferences = AppPreferences.of(context);

    final background = (appPreferences.activeBackgroundImagePath == null)
        ? Container()
        : Image.file(File(appPreferences.activeBackgroundImagePath!));

    return background;
  }
}
