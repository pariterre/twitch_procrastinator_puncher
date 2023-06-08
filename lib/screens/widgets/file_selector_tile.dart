import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
                  path != null ? basename(path!) : 'None selected',
                  style: TextStyle(color: ThemeColor().configurationText),
                ),
              ),
            ],
          ),
        ),
        if (path != null)
          SizedBox(
              height: windowHeight * 0.04,
              width: windowHeight * 0.04,
              child: Image.file(File(path!))),
        ElevatedButton(
          onPressed: selectFileCallback,
          style: ThemeButton.elevated,
          child: const Text('Select', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
