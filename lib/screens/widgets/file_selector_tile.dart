import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: ThemeColor.text, fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(left: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: windowHeight * 0.3,
                child: Text(
                  path ?? 'None selected',
                  style: const TextStyle(color: ThemeColor.text),
                ),
              ),
              ElevatedButton(
                onPressed: selectFileCallback,
                style: ThemeButton.elevated,
                child:
                    const Text('Select', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
