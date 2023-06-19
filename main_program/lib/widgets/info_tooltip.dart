import 'package:common_lib/models/app_theme.dart';
import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  const InfoTooltip({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Tooltip(
      message: message,
      margin: EdgeInsets.only(
          left: windowHeight * 0.26, right: windowHeight * 1.05),
      child:
          Icon(Icons.info, color: Colors.white, size: ThemeSize.icon(context)),
    );
  }
}
