import 'package:flutter/material.dart';

class AddHumorScreen extends StatefulWidget {
  const AddHumorScreen({super.key});

  @override
  State<AddHumorScreen> createState() => _AddHumorScreenState();
}

class _AddHumorScreenState extends State<AddHumorScreen> {
  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height - 150;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: Container(
        // color: const Color.fromARGB(255, 248, 255, 242),
        width: double.infinity,
        height: height,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, keyboardSpace + 16),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Add Your Own Humors',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        // controller: _titleController,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          label: const Text('Context'),
                        ),
                      ),
                      TextField(
                        // controller: _titleController,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          label: const Text('Punchline (optional)'),
                        ),
                      ),
                      TextField(
                        // controller: _titleController,
                        maxLines: 1,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: const Text('Nickname (optional)'),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (v) => {},
                          ),
                          const Text(
                            'Add to bookmark',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (v) => {},
                          ),
                          const Text(
                            'Submit to us',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: ElevatedButton(
                onPressed: () {
                  // Your onPressed function here
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor:
                      Theme.of(context).primaryColor, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: const Text(
                  'Add & Submit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
