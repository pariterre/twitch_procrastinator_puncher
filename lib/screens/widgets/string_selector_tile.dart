import 'package:arrow_pad/arrow_pad.dart';
import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/widgets/plus_or_minus.dart';

class StringSelectorTile extends StatefulWidget {
  const StringSelectorTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onTextChanged,
    this.onSizeChanged,
    this.onMoveText,
    this.onFocusChanged,
  });

  final String title;
  final String initialValue;
  final Function(String value) onTextChanged;
  final Function(PlusOrMinusSelection selection)? onSizeChanged;
  final Function(PressDirection direction)? onMoveText;
  final Function(bool gainedFocus)? onFocusChanged;

  @override
  State<StringSelectorTile> createState() => _StringSelectorTileState();
}

class _StringSelectorTileState extends State<StringSelectorTile> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

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
              ),
            ),
          ),
          if (widget.onSizeChanged != null)
            SizedBox(width: windowHeight * 0.01),
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
      ),
    );
  }
}
