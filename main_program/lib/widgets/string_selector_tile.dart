import 'package:arrow_pad/arrow_pad.dart';
import 'package:flutter/material.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/widgets/color_selector_tile.dart';
import 'package:twitch_procastinator_puncher/widgets/plus_or_minus.dart';

class StringSelectorTile extends StatefulWidget {
  const StringSelectorTile({
    super.key,
    required this.title,
    required this.initialText,
    required this.onTextChanged,
    this.onSizeChanged,
    this.onMoveText,
    this.onFocusChanged,
    this.initialColor,
    this.onColorChanged,
  });

  final String title;
  final String initialText;
  final Function(String value) onTextChanged;
  final Function(PlusOrMinusSelection selection)? onSizeChanged;
  final Function(PressDirection direction)? onMoveText;
  final Function(bool gainedFocus)? onFocusChanged;
  final Color? initialColor;
  final Function(Color value)? onColorChanged;

  @override
  State<StringSelectorTile> createState() => _StringSelectorTileState();
}

class _StringSelectorTileState extends State<StringSelectorTile> {
  late final _controller = TextEditingController(text: widget.initialText);
  bool _configExpanded = false;

  @override
  Widget build(BuildContext context) {
    final padding = ThemePadding.normal(context);

    return Theme(
      data: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(gapPadding: 100),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onFocusChange: (value) {
                if (widget.onFocusChanged != null) {
                  widget.onFocusChanged!(value);
                }
              },
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: widget.title),
                onChanged: (value) => widget.onTextChanged(value),
                maxLines: 2,
                minLines: 2,
                style: TextStyle(fontSize: ThemeSize.text(context)),
              ),
            ),
          ),
          if (widget.onColorChanged != null ||
              widget.onMoveText != null ||
              widget.onSizeChanged != null)
            Padding(
              padding: EdgeInsets.all(padding),
              child: InkWell(
                onTap: () => setState(() => _configExpanded = !_configExpanded),
                child: Icon(
                  _configExpanded
                      ? Icons.keyboard_arrow_right
                      : Icons.keyboard_arrow_left,
                  color: ThemeColor().configurationText,
                ),
              ),
            ),
          if (_configExpanded) _buildConfigurationBar(),
        ],
      ),
    );
  }

  Widget _buildConfigurationBar() {
    final windowHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onColorChanged != null)
          InkWell(
            onTap: () => pickColorDialog(context,
                currentColor: widget.initialColor!,
                onColorChanged: (color) =>
                    setState(() => widget.onColorChanged!(color))),
            child: Container(
              decoration: BoxDecoration(
                  color: widget.initialColor,
                  borderRadius: BorderRadius.circular(25)),
              width: windowHeight * 0.05,
              height: windowHeight * 0.05,
            ),
          ),
        if (widget.onSizeChanged != null) SizedBox(width: windowHeight * 0.01),
        if (widget.onSizeChanged != null)
          PlusOrMinus(onTap: widget.onSizeChanged!),
        if (widget.onMoveText != null)
          ArrowPad(
            height: windowHeight * 0.10,
            width: windowHeight * 0.10,
            innerColor: Colors.blue,
            arrowPadIconStyle: ArrowPadIconStyle.chevron,
            clickTrigger: ClickTrigger.onTapUp,
            onPressed: widget.onMoveText!,
          ),
      ],
    );
  }
}
