import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/util.dart';

class HumorCategoryCard extends StatefulWidget {
  final Category category;
  const HumorCategoryCard(
    this.category, {
    super.key,
  });

  @override
  State<HumorCategoryCard> createState() => _HumorCategoryCardState();
}

class _HumorCategoryCardState extends State<HumorCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      // width: 500,
      height: 500,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  // margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.category.themeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        width: double.infinity,
                        child: Text(
                          widget.category.title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                          child: ScaleTransition(
                            scale: _controller.drive(
                              Tween<double>(begin: 0.9, end: 1.05),
                            ),
                            child: Image.asset(widget.category.imgPath,
                                color: darken(widget.category.themeColor, 0.4)
                                // color: Color(0xff74b9ff),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                // color: Colors.white,
                height: 140,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade900),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.category.numDailyNew} new jokes daily',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.category.subscriberOnly)
                          Chip(
                            avatar: const Icon(Icons.lock),
                            backgroundColor: Colors.grey.shade100,
                            shape: const StadiumBorder(
                              side: BorderSide(
                                color: Colors.transparent, // No border color
                                width: 0, // Border width set to zero
                              ),
                            ),
                            // elevation: 1,
                            shadowColor: Colors.grey.shade100,
                            label: const Text(
                              'Subscribers Only',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
