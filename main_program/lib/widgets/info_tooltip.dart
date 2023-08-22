import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';

class InfoTooltip extends StatelessWidget {
  const InfoTooltip({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Tooltip(
      message: message,
      margin: EdgeInsets.only(
          left: windowHeight * 0.26, right: windowHeight * 0.85),
      child:
          Icon(Icons.info, color: Colors.white, size: ThemeSize.icon(context)),
    );
  }
}
