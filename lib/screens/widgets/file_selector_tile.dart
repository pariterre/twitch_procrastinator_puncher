import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';

class FileSelectorTile extends StatelessWidget {
  const FileSelectorTile({
    super.key,
    required this.title,
    required this.path,
    required this.selectFileCallback,
  });

  final String title;
  final String? path;
  final Function() selectFileCallback;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: windowHeight * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: ThemeColor().configurationText,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.only(left: padding),
                child: Text(
                  path ?? 'None selected',
                  style: TextStyle(color: ThemeColor().configurationText),
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: selectFileCallback,
          style: ThemeButton.elevated,
          child: const Text('Select', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
