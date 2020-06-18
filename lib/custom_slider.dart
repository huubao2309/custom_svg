import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/services.dart';

import 'customleftPainter.dart';
import 'utils.dart';

class LeftSlider extends StatefulWidget {
  LeftSlider({Key key}) : super(key: key);

  @override
  _LeftSliderState createState() => _LeftSliderState();
}

class _LeftSliderState extends State<LeftSlider> {
  //intial Values coming
  int leftEnd = 12;
  String rawLeftSvg =
      '''<svg xmlns="http://www.w3.org/2000/svg" height="512px" viewBox="0 0 32 32" width="512px"><g><path d="m8 0c-4.41113 0-8 3.58887-8 8s3.58887 8 8 8 8-3.58887 8-8-3.58887-8-8-8zm0 15c-3.85986 0-7-3.14014-7-7s3.14014-7 7-7 7 3.14014 7 7-3.14014 7-7 7z" data-original="#000000" class="active-path" data-old_color="#000000" fill="#2184C4"/><path d="m9 3c-1.04364 0-1.9624.536926-2.5 1.34772v-3.84772c0-.276367-.223633-.5-.5-.5-1.6543 0-3 1.3457-3 3 0 1.04364.536926 1.9624 1.34772 2.5h-3.84772c-.276367 0-.5.223633-.5.5 0 1.6543 1.3457 3 3 3 1.04364 0 1.9624-.536926 2.5-1.34772v3.84772c0 .276367.223633.5.5.5 1.6543 0 3-1.3457 3-3 0-1.04364-.536926-1.9624-1.34772-2.5h3.84772c.276367 0 .5-.223633.5-.5 0-1.6543-1.3457-3-3-3zm-6 5c-.930176 0-1.71436-.638184-1.93652-1.5h3.87305c-.222168.861816-1.00635 1.5-1.93652 1.5zm1-5c0-.930176.638184-1.71436 1.5-1.93652v3.87305c-.861816-.222168-1.5-1.00635-1.5-1.93652zm2 3.5c-.276123 0-.5-.223877-.5-.5 0-.276184.223877-.5.5-.5s.5.223816.5.5c0 .276123-.223877.5-.5.5zm2 2.5c0 .930176-.638184 1.71436-1.5 1.93652v-3.87305c.861816.222168 1.5 1.00635 1.5 1.93652zm-.936523-3.5c.222168-.861816 1.00635-1.5 1.93652-1.5.930176 0 1.71436.638184 1.93652 1.5h-3.87305z" transform="translate(2 2)" data-original="#000000" class="active-path" data-old_color="#000000" fill="#2184C4"/></g> </svg>''';

  DrawableRoot svgRoot;
  UI.Image image;
  @override
  void initState() {
    super.initState();
    getLeftIcon();
  }

  // this is for the Ui.Image
  Future<UI.Image> loadUiImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);

    final Completer<UI.Image> completer = Completer();
    UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
  //Please Ignore
  /* Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  } */

  getLeftIcon() async {
    /*  svgRoot= await svg.fromSvgString(rawLeftSvg, rawLeftSvg); */
    //File file = await getImageFileFromAssets('icon.png');

    image = await loadUiImage('assets/snowflake.png');
    svgRoot = await svg.fromSvgString(rawLeftSvg, rawLeftSvg);
    print('sucess');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SliderLeftPaint(
        leftsvgIcon: svgRoot,
        leftIcon: image,
        leftInitial: 0,
        leftEnd: leftEnd,
        onSelectionChange: (int left) {
          setState(() {
            leftEnd = left;
          });
        },
        child: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                '$leftEnd\u00B0',
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class SliderLeftPaint extends StatefulWidget {
  final DrawableRoot leftsvgIcon;
  final UI.Image leftIcon;
  final int leftInitial;
  final int leftEnd;

  final Function onSelectionChange;
  final Widget child;

  const SliderLeftPaint(
      {Key key,
      this.leftsvgIcon,
      @required this.leftIcon,
      @required this.leftInitial,
      @required this.leftEnd,
      @required this.onSelectionChange,
      this.child})
      : super(key: key);

  @override
  _SliderLeftPaintState createState() => _SliderLeftPaintState();
}

class _SliderLeftPaintState extends State<SliderLeftPaint> {
  bool _isInitLeftHandlerSelected = false;

  CustomLeftPainter customLeftPainter;

  /// start angle in radians where we need to locate the initial left handler
  double _leftStartAngle;

  /// end angle in radians where we need to locate the end left  handler
  double _leftEndAngle;

  /// the absolute angle in radians representing the selection
  double _leftSweepAngle;

// we need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(SliderLeftPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leftInitial != widget.leftInitial ||
        oldWidget.leftEnd != widget.leftEnd) {
      _calculatePercentage();
    }
  }

  void _calculatePercentage() {
    if (_isInitLeftHandlerSelected) {
      // This is for left inti and end percentage and the sweep Angle
      // TODO That it should be in a limit of half circle

      double initLeftPercentage = valueToPercentage(widget.leftInitial, 100);
      print('This is initial Left Percentge $initLeftPercentage');
      double endLeftPercentage = valueToPercentage(widget.leftEnd, 100);
      print('This is  End  Left Percentage $endLeftPercentage');

      double sweepLeftAngle =
          getSweepAngle(initLeftPercentage, endLeftPercentage);
      print('This is the sweep angle for the left hand side $sweepLeftAngle');
      _leftStartAngle = percentageToRadians(initLeftPercentage);
      print('This is the Left Start Angle $_leftStartAngle');
      _leftEndAngle = percentageToRadians(endLeftPercentage);
      print('This is the Left End Angle $_leftEndAngle');

      _leftSweepAngle = percentageToRadians(sweepLeftAngle.abs());
      print('This is the Left Sweep Angle $_leftSweepAngle');
    }

    customLeftPainter = CustomLeftPainter(
      leftdrawablesvgIcon: widget.leftsvgIcon,
      leftSvgIcon: widget.leftIcon,
      startLeftAngle: _leftStartAngle,
      endLeftAngle: _leftEndAngle,
      leftSweepAngle: _leftSweepAngle,
      selectionLeftColor: Colors.blueAccent,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calculatePaintData();
  }

  void _calculatePaintData() {
    // This is for the right init and end percentage and the sweepangle

    // This is for left inti and end percentage and the sweep Angle
    double initLeftPercentage = valueToPercentage(widget.leftInitial, 100);
    print('This is initial Left Percentge $initLeftPercentage');
    double endLeftPercentage = valueToPercentage(widget.leftEnd, 100);
    print('This is  End  Left Percentage $endLeftPercentage');

    double sweepLeftAngle =
        getSweepAngle(initLeftPercentage, endLeftPercentage);
    print('This is the sweep angle for the left hand side $sweepLeftAngle');
    _leftStartAngle = percentageToRadians(initLeftPercentage);
    print('This is the Left Start Angle $_leftStartAngle');
    _leftEndAngle = percentageToRadians(endLeftPercentage);
    print('This is the Left End Angle $_leftEndAngle');

    _leftSweepAngle = percentageToRadians(sweepLeftAngle.abs());
    print('This is the Left Sweep Angle $_leftSweepAngle');

    customLeftPainter = CustomLeftPainter(
      leftdrawablesvgIcon: widget.leftsvgIcon,
      leftSvgIcon: widget.leftIcon,
      startLeftAngle: _leftStartAngle,
      endLeftAngle: _leftEndAngle,
      leftSweepAngle: _leftSweepAngle,
      selectionLeftColor: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanDown: _onPanDown,
      child: CustomPaint(
        // painter: BasePainter(
        //   baseColor: Color(0XFF5E5C5D),
        // ),
        foregroundPainter: customLeftPainter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  _onPanUpdate(DragUpdateDetails details) {
    if (!_isInitLeftHandlerSelected) {
      return;
    }
    if (customLeftPainter.leftcenter == null) {
      return;
    }

    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details.globalPosition);
    var leftAngle;

    var leftPercent;

    var newLeftValue;

    if (_leftSweepAngle >= 0) {
      leftAngle = coordinatesToRadians(customLeftPainter.leftcenter, position);
      leftPercent = radianstoPercentageLeft(leftAngle);
      newLeftValue = percentageToValue(leftPercent, 100);
      if (_isInitLeftHandlerSelected) {
        widget.onSelectionChange(newLeftValue);
      }
    }
  }

  _onPanDown(DragDownDetails details) {
    if (customLeftPainter == null) {
      return;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details.globalPosition);
    if (position != null) {
      _isInitLeftHandlerSelected = isPointInsideCircle(
          position, customLeftPainter.leftInitHandler, 12.0);
    }
  }

  _onPanEnd(_) {
    _isInitLeftHandlerSelected = false;
  }
}
