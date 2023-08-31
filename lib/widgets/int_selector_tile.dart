import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twitch_procastinator_puncher/models/app_theme.dart';
import 'package:twitch_procastinator_puncher/models/preferenced_element.dart';

class _DigitOnly extends TextInputFormatter {
  static final _reg = RegExp(r'^\d+$'); // any number

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    return _reg.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class IntSelectorTile extends StatefulWidget {
  const IntSelectorTile({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onValidChange,
  });

  final String title;
  final PreferencedInt initialValue;
  final Function(int value) onValidChange;

  @override
  State<IntSelectorTile> createState() => _IntSelectorTileState();
}

class _IntSelectorTileState extends State<IntSelectorTile> {
  late final _controller =
      TextEditingController(text: widget.initialValue.toString());

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.title,
            style: TextStyle(
                color: ThemeColor().configurationText,
                fontWeight: FontWeight.bold,
                fontSize: ThemeSize.text(context))),
        Theme(
          data: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.black),
              hintStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          child: SizedBox(
              width: windowHeight * 0.1,
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: ThemeSize.text(context)),
                controller: _controller,
                inputFormatters: [_DigitOnly()],
                onChanged: (value) {
                  final valueAsInt = int.tryParse(value);
                  if (valueAsInt == null) return;
                  widget.onValidChange(valueAsInt);
                },
              )),
        ),
      ],
    );
  }
}
