import 'package:common_lib/models/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/widgets/info_tooltip.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus.dart';

class PlusOrMinusTile extends StatelessWidget {
  const PlusOrMinusTile({
    super.key,
    required this.title,
    this.tooltipMessage,
    required this.onTap,
  });

  final String title;
  final String? tooltipMessage;
  final Function(PlusOrMinusSelection selection) onTap;

  @override
  Widget build(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: padding * 2, vertical: padding / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.white, fontSize: ThemeSize.text(context)),
              ),
              if (tooltipMessage != null) SizedBox(width: padding),
              if (tooltipMessage != null) InfoTooltip(message: tooltipMessage)
            ],
          ),
          PlusOrMinus(onTap: onTap),
        ],
      ),
    );
  }
}
