import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';

class DropMenuSelectorTile<T> extends StatelessWidget {
  const DropMenuSelectorTile({
    super.key,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<DropdownMenuItem<T>>? items;
  final Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
              color: ThemeColor().configurationText,
              fontWeight: FontWeight.bold,
              fontSize: ThemeSize.text(context)),
        ),
        SizedBox(
          width: padding,
        ),
        Flexible(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: DropdownButtonFormField<T>(
                initialValue: value,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: ThemeSize.text(context) * 1.20),
                dropdownColor: Colors.white,
                items: items,
                onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
