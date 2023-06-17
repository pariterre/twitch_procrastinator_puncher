import 'package:common_lib/models/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
    required this.currentColor,
    required this.onChanged,
  });

  final String title;
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
          SizedBox(
            width: windowHeight * 0.3,
            child: Text(widget.title,
                style: TextStyle(
                    color: ThemeColor().configurationText,
                    fontWeight: FontWeight.bold)),
          ),
          InkWell(
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
        ],
      ),
    );
  }
}
