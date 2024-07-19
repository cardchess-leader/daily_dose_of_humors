import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:daily_dose_of_humors/painter/background.dart';
import 'package:daily_dose_of_humors/main.dart';

class ScrollingBackground extends StatefulWidget {
  final List<String> imagePathList;
  final int scrollTime;
  final double imageSize;
  final double imageMargin;
  final int patternLength;

  const ScrollingBackground({
    super.key,
    required this.imagePathList,
    required this.imageSize,
    required this.imageMargin,
    this.patternLength = 1,
    this.scrollTime = 10000,
  });

  @override
  State<ScrollingBackground> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground>
    with SingleTickerProviderStateMixin, RouteAware {
  late AnimationController _controller;
  List<ui.Image>? _imageList;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.scrollTime),
    )..repeat();

    _loadImages(widget.imagePathList).then((imageList) {
      setState(() {
        _imageList = imageList;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _controller.stop();
  }

  @override
  void didPopNext() {
    _controller.repeat();
  }

  Future<List<ui.Image>> _loadImages(List<String> assets) async {
    return Future.wait(assets.map((asset) async {
      final ByteData data = await rootBundle.load(asset);
      final Uint8List bytes = data.buffer.asUint8List();
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        completer.complete(img);
      });
      return completer.future;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_imageList == null) {
      return Container(); // Placeholder while the images are loading
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ScrollingBackgroundPainter(
            _imageList!,
            _controller.value *
                (widget.imageSize + widget.imageMargin) *
                widget.patternLength,
            widget.imageSize,
            widget.imageMargin,
            widget.patternLength,
          ),
          child: Container(),
        );
      },
    );
  }
}
