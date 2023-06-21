import 'package:common_lib/providers/app_preferences.dart';
import 'package:flutter/material.dart';

class AreYouSureDialog extends StatelessWidget {
  const AreYouSureDialog({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        OutlinedButton(
          child: Text(preferences.texts.miscCancel,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary)),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: Text(preferences.texts.miscConfirm,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
