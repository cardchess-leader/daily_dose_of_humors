import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final Color color;
  final String label;

  const CustomChip({
    required this.color,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
