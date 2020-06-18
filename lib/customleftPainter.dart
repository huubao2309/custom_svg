import 'dart:math';
import 'dart:ui' as UI;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'utils.dart';

class CustomLeftPainter extends CustomPainter {
  DrawableRoot leftdrawablesvgIcon;
  UI.Image leftSvgIcon;
  double startLeftAngle;
  double endLeftAngle;
  double leftSweepAngle;
  Color selectionLeftColor;
  Size actuallsize = Size(30, 30);

  Offset leftcenter;

  double leftradius;

  Offset leftInitHandler;

  CustomLeftPainter({
    @required this.leftdrawablesvgIcon,
    @required this.leftSvgIcon,
    @required this.startLeftAngle,
    @required this.endLeftAngle,
    @required this.leftSweepAngle,
    @required this.selectionLeftColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //This was the problem when all the both left and right angles are 0 then it will return with no points
    /* if (startLeftAngle == 0.0 &&
        endLeftAngle == 0.0 &&
        startRightAngle == 0.0 &&
        endRightAngle == 0.0) return;
 */

    Paint leftprogress = _getPaint(color: selectionLeftColor, width: 20);

    leftcenter = Offset(size.width / 2, size.height / 2);

    leftradius = min(size.width / 2, size.height / 2);

    canvas.drawArc(Rect.fromCircle(center: leftcenter, radius: leftradius),
        pi / 2 + startLeftAngle, leftSweepAngle, false, leftprogress);

    Paint lefthandler =
        _getPaint(color: Colors.white, style: PaintingStyle.fill);
    Paint lefthandlerOutter = _getPaint(color: selectionLeftColor);

    leftInitHandler =
        radiansToCoordinates(leftcenter, pi / 2 + endLeftAngle, leftradius);
    canvas.drawCircle(leftInitHandler, 8.0, lefthandler);
    canvas.drawCircle(leftInitHandler, 12.0, lefthandlerOutter);

    // To draw image but problem is it has scalling problem

    /* canvas.drawImage(
        leftSvgIcon,
        Offset(leftInitHandler.dx - 12, leftInitHandler.dy - 12),
        lefthandlerOutter); */
    //

    leftdrawablesvgIcon.scaleCanvasToViewBox(canvas, size);

    leftdrawablesvgIcon.clipCanvasToViewBox(canvas);

    //This is the add part for the edit
    Rect myRect =
        Offset(leftInitHandler.dx, leftInitHandler.dy) & const Size(50.0, 50.0);

    leftdrawablesvgIcon.draw(canvas, myRect);
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.square
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? 8.0;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
