import 'package:flutter/material.dart';
import 'package:twitch_pomorodo_timer/widgets/plus_or_minus.dart';

class PlusOrMinusListTile extends StatelessWidget {
  const PlusOrMinusListTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  final Widget title;
  final Function(PlusOrMinusSelection selection) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      trailing: PlusOrMinus(onTap: onTap),
    );
  }
}
