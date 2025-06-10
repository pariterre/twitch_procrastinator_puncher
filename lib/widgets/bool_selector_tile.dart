import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';

class BoolSelectorTile extends StatelessWidget {
  const BoolSelectorTile({
    super.key,
    required this.title,
    required this.onChanged,
    required this.value,
  });

  final String title;
  final Function(bool value) onChanged;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontSize: ThemeSize.text(context)),
        ),
        Switch(
          onChanged: onChanged,
          value: value,
          activeColor: Colors.white,
        ),
      ],
    );
  }
}
