import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/loading.dart';

class HumorScreenScaffold extends StatelessWidget {
  final bool isLoading;
  const HumorScreenScaffold({
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      // color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(50),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Text(
                      isLoading ? 'Loading humors...' : 'Oops...',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/thumb-up.png',
                  color: textColor,
                  width: 18,
                ),
                const SizedBox(width: 5),
                const Text(
                  '0',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Spacer(),
          isLoading
              ? LoadingWidget(color: textColor, size: 100)
              : Text(
                  'Could not fetch humors...\nPlease try again later! :)',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
          const Spacer(),
        ],
      ),
    );
  }
}
