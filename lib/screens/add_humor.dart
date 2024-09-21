import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_dose_of_humors/models/humor.dart';
import 'package:daily_dose_of_humors/models/category.dart';
import 'package:daily_dose_of_humors/util/global_var.dart';
import 'package:daily_dose_of_humors/providers/app_state.dart';

class AddHumorScreen extends ConsumerStatefulWidget {
  final void Function(Humor humor) insertBookmark;

  const AddHumorScreen(this.insertBookmark, {super.key});

  @override
  ConsumerState<AddHumorScreen> createState() => _AddHumorScreenState();
}

class _AddHumorScreenState extends ConsumerState<AddHumorScreen> {
  final _contextController = TextEditingController();
  final _punchlineController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _addToBookmark = true;
  bool _submitToUs = false;
  bool _isLoading = false;
  String _errMsg = '';

  @override
  void dispose() {
    _contextController.dispose();
    _punchlineController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool _isSubmitButtonEnabled() {
    return _contextController.text.trim().isNotEmpty &&
        (_addToBookmark || _submitToUs);
  }

  void _handlePress() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final humor = BookmarkHumor(
      uuid: GLOBAL.uuid.v4(),
      categoryCode: CategoryCode.YOUR_HUMORS,
      context: _contextController.text.trim(),
      punchline: _punchlineController.text.trim(),
      author: _nicknameController.text.trim(),
      sender: _nicknameController.text.trim(),
      source: 'Your Own Humors',
    );
    if (_submitToUs) {
      final response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Submit Confirmation'),
            content: const Text(
              'We appreciate you sharing your humor with us, and we might feature it in our \'Daily Dose of Humors,\' giving credit to your nickname.\n\nDo you agree to share your humor with us?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Close the dialog
                },
                child: const Text('Nope', style: TextStyle(fontSize: 18)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Close the dialog
                },
                child: const Text(
                  'Sure',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        },
      );
      if (response == true) {
        final resultMsg =
            await ref.read(serverProvider.notifier).submitUserHumors(humor);
        if (resultMsg != null) {
          return setState(() {
            _errMsg = resultMsg;
            _isLoading = false;
          });
        }
      } else {
        return setState(() {
          _isLoading = false;
        });
      }
    }
    if (_addToBookmark) {
      widget.insertBookmark(humor);
    }
    if (mounted) {
      String snackbarMsg = '';
      if (_addToBookmark && !_submitToUs) {
        snackbarMsg = 'Humor added successfully to bookmark.';
      } else if (!_addToBookmark && _submitToUs) {
        snackbarMsg = 'Humor submitted successfully.';
      } else {
        snackbarMsg = 'Humor added to bookmark & submitted successfully.';
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackbarMsg),
        ),
      );
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
                        onChanged: (value) => setState(() {}),
                      ),
                      TextField(
                        controller: _punchlineController,
                        minLines: 1,
                        maxLines: 5,
                        maxLength: 250,
                        decoration: const InputDecoration(
                          label: Text('Punchline (if any)'),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        _errMsg,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitButtonEnabled() ? _handlePress : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          Theme.of(context).primaryColor, // Background color
                      foregroundColor: Colors.white, // Text color
                    ),
                    child: _isLoading
                        ? Lottie.asset(
                            'assets/lottie/loading.json',
                            width: 35,
                            height: 35,
                            delegates: LottieDelegates(
                              values: [
                                ValueDelegate.colorFilter(
                                  ['**'],
                                  value: const ColorFilter.mode(
                                      Colors.white, BlendMode.src),
                                ),
                              ],
                            ),
                          )
                        : Text(
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
