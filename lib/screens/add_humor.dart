import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';

class AddHumorScreen extends StatefulWidget {
  final void Function(Humor humor) insertBookmark;

  const AddHumorScreen(this.insertBookmark, {super.key});

  @override
  State<AddHumorScreen> createState() => _AddHumorScreenState();
}

class _AddHumorScreenState extends State<AddHumorScreen> {
  final _contextController = TextEditingController();
  final _punchlineController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _addToBookmark = true;
  bool _submitToUs = false;
  String _errMsg = '';

  @override
  void dispose() {
    _contextController.dispose();
    _punchlineController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _handlePress(BuildContext context) async {
    final humor = Humor(
      uuid: uuid.v4(),
      categoryCode: CategoryCode.DAD_JOKES,
      context: _contextController.text,
      punchline: _punchlineController.text,
      // author: _nicknameController.text,
    );
    print('humor is: $humor');
    if (_submitToUs) {
      print('submit to us');
      // if error occurs, set error message and return out of this //
    }
    if (_addToBookmark) {
      // final dbHelper = DatabaseHelper();
      // final success = await dbHelper.addBookmark(humor);
      // print('success? $success');
      // if (mounted && success) {
      //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Humor added successfully to bookmark.'),
      //     ),
      //   );
      // }
      widget.insertBookmark(humor);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height - 150;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: SizedBox(
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
                        controller: _contextController,
                        minLines: 1,
                        maxLines: 20,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          label: Text('Context'),
                        ),
                      ),
                      TextField(
                        controller: _punchlineController,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          label: Text('Punchline (optional)'),
                        ),
                      ),
                      TextField(
                        controller: _nicknameController,
                        maxLines: 1,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          label: Text('Nickname (optional)'),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _addToBookmark,
                            onChanged: (v) => {
                              setState(() {
                                _addToBookmark = v ?? false;
                              })
                            },
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
                            value: _submitToUs,
                            onChanged: (v) => {
                              setState(() {
                                _submitToUs = v ?? false;
                              })
                            },
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
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errMsg != '')
                    Text(
                      _errMsg,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: !_addToBookmark && !_submitToUs
                        ? null
                        : () => _handlePress(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          Theme.of(context).primaryColor, // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: Text(
                      _addToBookmark && _submitToUs
                          ? 'Add & Submit'
                          : _submitToUs
                              ? 'Submit To Us'
                              : 'Add To Bookmark',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
