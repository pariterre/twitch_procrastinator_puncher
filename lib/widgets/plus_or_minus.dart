import 'package:flutter/material.dart';

enum PlusOrMinusSelection { plus, minus }

class PlusOrMinus extends StatelessWidget {
  const PlusOrMinus({super.key, required this.onTap});

  final Function(PlusOrMinusSelection) onTap;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Button(icon: Icons.add, onTap: () => onTap(PlusOrMinusSelection.plus)),
        SizedBox(height: windowHeight * 0.005),
        _Button(
            icon: Icons.remove, onTap: () => onTap(PlusOrMinusSelection.minus)),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.icon, required this.onTap});

  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final windowHeight = MediaQuery.of(context).size.height;

    return Container(
      height: windowHeight * 0.025,
      width: windowHeight * 0.025,
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(8)),
      child: InkWell(
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: windowHeight * 0.02)),
    );
  }
}
