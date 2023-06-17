import 'package:common_lib/models/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/locale.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  Widget _buildSelection(BuildContext context,
      {required String title, required Language language}) {
    final padding = ThemePadding.normal(context);

    return Container(
      decoration: BoxDecoration(
          color: AppLocale.of(context).language == language
              ? ThemeColor().configurationText
              : null),
      child: InkWell(
        onTap: () => AppLocale.of(context, listen: false).language = language,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: padding * 1 / 2, vertical: padding / 10),
          child: Text(title,
              style: TextStyle(
                  color: AppLocale.of(context).language == language
                      ? Colors.black
                      : ThemeColor().configurationText,
                  fontSize: ThemeSize.text(context))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSelection(context, title: 'En', language: Language.english),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text('/',
              style: TextStyle(
                  color: ThemeColor().configurationText,
                  fontSize: ThemeSize.text(context))),
        ),
        _buildSelection(context, title: 'Fr', language: Language.french)
      ],
    );
  }
}
