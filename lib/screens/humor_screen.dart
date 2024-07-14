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
                            const CustomChip(
                                color: Color.fromARGB(0, 0, 0, 0),
                                textColor: Color.fromARGB(159, 0, 0, 0),
                                label: 'Dad Jokes'),
                            SizedBox(width: 10),
                            const CustomChip(
                                color: Color.fromARGB(0, 33, 149, 243),
                                textColor: Color.fromARGB(159, 0, 0, 0),
                                label: '2024-07-10'),
                            Expanded(child: SizedBox(width: 10)),
                            const CustomChip(
                              color: Colors.transparent,
                              textColor: Color.fromARGB(159, 0, 0, 0),
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
                                    child: const Center(
                                      child: Text(
                                        'Why did the scarecrow win an award?',
                                        style: TextStyle(fontSize: 26),
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
                              Icons.thumb_up,
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '123',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(30, 0, 0, 0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
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
                            color: const Color.fromARGB(111, 0, 0, 0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                //     // color: Colors.grey,
                //     decoration: BoxDecoration(
                //       border: Border.all(color: Colors.grey.shade200, width: 1),
                //       borderRadius: BorderRadius.circular(20),
                //       color: Colors.grey.shade100,
                //     ),
                //     child: const Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Icon(
                //           Icons.thumb_up,
                //           size: 20,
                //         ),
                //         SizedBox(
                //           width: 5,
                //         ),
                //         Text(
                //           'x123',
                //           style: TextStyle(fontWeight: FontWeight.w500),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
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
        elevation: 0,
        onPressed: () {
          // Handle the FAB action
          print('FAB Pressed');
        },
        tooltip: 'Add',
        child: const Icon(Icons.thumb_up_outlined),
      ),
    );
  }
}
