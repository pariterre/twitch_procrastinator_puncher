import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/widgets/info_tooltip.dart';

class CheckboxTile extends StatefulWidget {
  const CheckboxTile({
    super.key,
    required this.title,
    this.tooltipMessage,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? tooltipMessage;
  final bool value;
  final void Function(bool?) onChanged;

  @override
  State<CheckboxTile> createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> {
  late bool _value = widget.value;

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
                widget.title,
                style: TextStyle(
                    color: Colors.white, fontSize: ThemeSize.text(context)),
              ),
              if (widget.tooltipMessage != null) SizedBox(width: padding),
              if (widget.tooltipMessage != null)
                InfoTooltip(message: widget.tooltipMessage)
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: _value ? Colors.blue : null,
                border: _value ? null : Border.all(color: Colors.black)),
            child: InkWell(
                onTap: () {
                  _value = !_value;
                  widget.onChanged(_value);
                },
                child: Icon(
                  _value ? Icons.check : null,
                  color: Colors.white,
                  size: ThemeSize.icon(context) * 2 / 3,
                )),
          ),
        ],
      ),
    );
  }
}
