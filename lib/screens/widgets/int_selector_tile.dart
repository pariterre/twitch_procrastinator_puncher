import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/common/app_theme.dart';

class IntSelectorTile extends StatefulWidget {
  const IntSelectorTile({
    super.key,
    required this.title,
    required this.controller,
    required this.onValidChange,
  });

  final String title;
  final TextEditingController controller;
  final Function(int value) onValidChange;

  @override
  State<IntSelectorTile> createState() => _IntSelectorTileState();
}

class _IntSelectorTileState extends State<IntSelectorTile> {
  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title,
            style: const TextStyle(
                color: ThemeColor.text, fontWeight: FontWeight.bold)),
        Theme(
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
          child: SizedBox(
              width: windowHeight * 0.1,
              child: TextField(
                controller: widget.controller,
                onChanged: (value) {
                  final valueAsInt = int.tryParse(value);
                  if (valueAsInt == null) {
                    setState(() => widget.controller.text = '');
                    return;
                  }
                  widget.onValidChange(valueAsInt);
                },
              )),
        ),
      ],
    );
  }
}
