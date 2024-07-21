import 'package:flutter/material.dart';

class ShopCategoryScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  const ShopCategoryScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: LayoutBuilder(builder: (context, constraints) {
            double spacing = 16;
            double itemWidth = ((constraints.maxWidth - spacing) / 2) -
                0.1; // Adjust the width for 2 items per row, 0.1 is safe margin
            return Wrap(
              spacing: spacing,
              runSpacing: 20,
              alignment: WrapAlignment.start,
              children: List.generate(
                9,
                (index) => SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: () => {},
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 140 / 200,
                          child: Card(
                            color: Colors.amber,
                            margin: EdgeInsets.zero,
                            child: SizedBox(
                              width: double.infinity,
                              // height: 200,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          ' Best Dad Jokes of 2023',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          ' \$2.24',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
