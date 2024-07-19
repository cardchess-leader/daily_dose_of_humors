import 'package:flutter/material.dart';

class PageHeaderText extends StatelessWidget {
  final String heading;
  final String subheading;
  const PageHeaderText(
      {super.key, required this.heading, this.subheading = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontSize: 30,
            // color: Colors.white,
            fontWeight: FontWeight.bold,
            // fontStyle: FontStyle.italic,
          ),
        ),
        if (subheading != '') ...[
          const SizedBox(height: 5),
          Text(
            subheading,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ],
    );
  }
}
