import 'package:flutter/material.dart';
import 'package:daily_dose_of_humors/widgets/page_header_text.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() {
    return _ShopScreenState();
  }
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // backgroundColor: Colors.yellow,
          title: const PageHeaderText(
        heading: 'Humor Shop',
        subheading: 'Premium Quality Humor Bundles',
      )),
    );
  }
}
