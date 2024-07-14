import 'package:daily_dose_of_humors/util/util.dart';
import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/widgets/custom_chip.dart';

class HumorScreen extends StatefulWidget {
  final Category selectedCategory;
  const HumorScreen(this.selectedCategory, {super.key});

  @override
  State<HumorScreen> createState() {
    return _HumorScreenState();
  }
}

class _HumorScreenState extends State<HumorScreen> {
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // color: _selectedCategory.themeColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // const SizedBox(height: 15),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(89, 108, 189, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CustomChip(
                                color: Color.fromARGB(0, 0, 0, 0),
                                // textColor: Color.fromARGB(159, 0, 0, 0),
                                textColor: darken(
                                  Color.fromARGB(89, 108, 189, 255),
                                  0.5,
                                ),
                                label: 'Dad Jokes'),
                            const SizedBox(width: 10),
                            CustomChip(
                                color: Color.fromARGB(0, 33, 149, 243),
                                textColor: darken(
                                  Color.fromARGB(89, 108, 189, 255),
                                  0.5,
                                ),
                                label: '2024-07-10'),
                            const Expanded(child: SizedBox(width: 10)),
                            CustomChip(
                              color: Colors.transparent,
                              textColor: darken(
                                Color.fromARGB(89, 108, 189, 255),
                                0.5,
                              ),
                              label: '1/5',
                              // textColor: Colors.grey,
                            ),
                          ],
                          // [
                          // Text('Dad Jokes'),
                          // SizedBox(width: 10),
                          // Text('2024-07-10'),
                          // SizedBox(width: 10),
                          // Text('New'),
                          // ],
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(30),
                                    child: Center(
                                      child: Text(
                                        'Why did the scarecrow win an award?',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade900,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.sentiment_very_satisfied_rounded,
                              size: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'x123',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(30, 0, 0, 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 100,
                          color: Color.fromARGB(58, 0, 0, 0),
                        ),
                        Text(
                          'Tap to view punchline',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(111, 0, 0, 0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton(
        // elevation: 0,
        onPressed: () {
          // Handle the FAB action
          print('FAB Pressed');
        },
        tooltip: 'Add',
        child: const Icon(
          Icons.sentiment_very_satisfied_rounded,
          size: 30,
        ),
      ),
    );
  }
}
