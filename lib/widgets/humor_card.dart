import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/util.dart';

class HumorCategoryCard extends StatelessWidget {
  final Category category;
  const HumorCategoryCard(
    this.category, {
    super.key,
  });

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
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          lighten(category.themeColor, 0.0),
                          darken(category.themeColor, 0.0),
                        ]),
                    color: category.themeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        width: double.infinity,
                        child: Text(
                          category.title,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                          child: Image.asset(
                            category.imgPath,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                height: 140,
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${category.numDailyNew} new jokes daily',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (category.subscriberOnly)
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
