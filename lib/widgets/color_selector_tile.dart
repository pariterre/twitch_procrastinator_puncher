import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/widgets/info_tooltip.dart';

void pickColorDialog(context,
    {required Color currentColor,
    required Function(Color) onColorChanged}) async {
  await showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: onColorChanged,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

class ColorSelectorTile extends StatefulWidget {
  const ColorSelectorTile({
    super.key,
    required this.title,
    this.tooltipMessage,
    required this.currentColor,
    required this.onChanged,
  });

  final String title;
  final String? tooltipMessage;
  final Color currentColor;
  final Function(Color) onChanged;

  @override
  State<ColorSelectorTile> createState() => _ColorSelectorTileState();
}

class _ColorSelectorTileState extends State<ColorSelectorTile> {
  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;
    final padding = ThemePadding.normal(context);

    return Padding(
      padding: EdgeInsets.only(right: 1.5 * padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(widget.title,
                  style: TextStyle(
                      color: ThemeColor().configurationText,
                      fontSize: ThemeSize.text(context))),
              if (widget.tooltipMessage != null) SizedBox(width: padding),
              if (widget.tooltipMessage != null)
                InfoTooltip(message: widget.tooltipMessage),
            ],
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: InkWell(
              onTap: () => pickColorDialog(context,
                  currentColor: widget.currentColor,
                  onColorChanged: (color) =>
                      setState(() => widget.onChanged(color))),
              child: Container(
                decoration: BoxDecoration(
                    color: widget.currentColor,
                    border: Border.all(color: Colors.black)),
                width: windowHeight * 0.05,
                height: windowHeight * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
