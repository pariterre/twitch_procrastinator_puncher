import 'package:flutter/material.dart';

class StringSelectorTile extends StatefulWidget {
  const StringSelectorTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onValidChange,
  });

  final String title;
  final String initialValue;
  final Function(String value) onValidChange;

  @override
  State<StringSelectorTile> createState() => _StringSelectorTileState();
}

class _StringSelectorTileState extends State<StringSelectorTile> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
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
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(labelText: widget.title),
        onChanged: (value) => widget.onValidChange(value),
      ),
    );
  }
}
