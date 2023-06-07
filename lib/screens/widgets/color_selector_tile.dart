import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twitch_pomorodo_timer/models/app_theme.dart';

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
  void _onTap(context) async {
    await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: widget.currentColor,
            onColorChanged: (color) => setState(() => widget.onChanged(color)),
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
            onTap: () => _onTap(context),
            child: Container(
              decoration: BoxDecoration(color: widget.currentColor),
              width: windowHeight * 0.05,
              height: windowHeight * 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
