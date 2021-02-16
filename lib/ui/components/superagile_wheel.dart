library flutter_radar_chart;

import 'dart:math' as math;
import 'dart:math' show pi, cos, sin;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:superagile_app/utils/global_theme.dart';

class SuperagileWheel extends StatefulWidget {
  final List<String> topics;
  final List<int> scores;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;

  SuperagileWheel({
    @required this.topics,
    @required this.scores,
    this.featuresTextStyle = const TextStyle(color: accentColor, fontSize: 9),
    this.outlineColor = accentColor,
    this.axisColor = secondaryColor,
  });

  @override
  _SuperagileWheelState createState() => _SuperagileWheelState();
}

class _SuperagileWheelState extends State<SuperagileWheel> with SingleTickerProviderStateMixin {
  double fraction = 0;
  Animation<double> animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ))
      ..addListener(() {
        setState(() {
          fraction = animation.value;
        });
      });

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(370, 370),
      painter: _SuperagileWheelPainter(
          widget.topics, widget.scores, widget.featuresTextStyle, widget.outlineColor, widget.axisColor, fraction),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class _SuperagileWheelPainter extends CustomPainter {
  final List<String> features;
  final List<int> data;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final double fraction;

  _SuperagileWheelPainter(
    this.features,
    this.data,
    this.featuresTextStyle,
    this.outlineColor,
    this.axisColor,
    this.fraction,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / 3.5;
    final angle = (2 * pi) / features.length;
    final featureLabelRadius = 1.07 * radius;

    drawOutlinePath(canvas, centerOffset, radius);

    features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset = Offset(centerOffset.dx + radius * xAngle, centerOffset.dy + radius * yAngle);

      drawAxisLine(canvas, centerOffset, featureOffset);

      drawFeatureLabel(canvas, centerOffset, angle, index, feature, featureLabelRadius);
    });

    drawGraphOutline(canvas, centerOffset, scale, angle);

    drawScoreLabels(canvas, centerOffset, angle, scale);

    drawZero(canvas, centerOffset);
  }

  void drawOutlinePath(Canvas canvas, Offset centerOffset, double radius) {
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var path = Path();

    path.addOval(Rect.fromCircle(
      center: centerOffset,
      radius: radius,
    ));

    canvas.drawPath(path, outlinePaint);
  }

  void drawAxisLine(Canvas canvas, Offset startingOffset, Offset endingOffset) {
    var axisPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawLine(startingOffset, endingOffset, axisPaint);
  }

  void drawFeatureLabel(
      Canvas canvas, Offset centerOffset, double angle, int index, String feature, double featureLabelRadius) {
    canvas.save();
    double startingAngle = angle * index - angle / 2 * (feature.length / 18);
    canvas.translate(centerOffset.dx, centerOffset.dy - featureLabelRadius);

    if (startingAngle != 0) {
      final d = 2 * featureLabelRadius * math.sin(startingAngle / 2);
      final rotationAngle = calculateRotationAngle(0, startingAngle);
      canvas.rotate(rotationAngle);
      canvas.translate(d, 0);
    }

    double nextStartingAngle = startingAngle;
    for (int i = 0; i < feature.length; i++) {
      nextStartingAngle = drawLetter(canvas, feature[i], nextStartingAngle, featureLabelRadius);
    }
    canvas.restore();
  }

  double drawLetter(Canvas canvas, String letter, double prevAngle, double radius) {
    TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(text: letter, style: featuresTextStyle);
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final double d = textPainter.width;
    final double alpha = 2 * math.asin(d / (2 * radius));

    final newAngle = calculateRotationAngle(prevAngle, alpha);
    canvas.rotate(newAngle);

    textPainter.paint(canvas, Offset(0, -textPainter.height));
    canvas.translate(d, 0);

    return alpha;
  }

  void drawGraphOutline(Canvas canvas, Offset centerOffset, double scale, double angle) {
    var graphOutlinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var initialPoint = scale * data[0] * fraction;
    var path = Path();

    path.moveTo(centerOffset.dx, centerOffset.dy - initialPoint);

    data.asMap().forEach((index, point) {
      if (index == 0) return;

      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);
      var scaledPoint = scale * point * fraction;

      path.lineTo(centerOffset.dx + scaledPoint * xAngle, centerOffset.dy + scaledPoint * yAngle);
    });
    path.close();
    canvas.drawPath(path, graphOutlinePaint);
  }

  void drawScoreLabels(Canvas canvas, Offset centerOffset, double angle, double scale) {
    data.asMap().forEach((index, point) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);
      var scaledPoint = scale * point * fraction;

      var path = Path();
      path.addOval(Rect.fromCircle(
        center: Offset(centerOffset.dx + scaledPoint * xAngle, centerOffset.dy + scaledPoint * yAngle),
        radius: 7,
      ));

      var scoreLabelPaint = Paint()
        ..color = secondaryColor
        ..style = PaintingStyle.fill;

      var scoreLabelOutlinePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..isAntiAlias = true;

      canvas.drawPath(path, scoreLabelPaint);
      canvas.drawPath(path, scoreLabelOutlinePaint);

      TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
          text: point.toString(), style: TextStyle(color: primaryColor, fontSize: 9, fontWeight: FontWeight.bold));
      textPainter.layout(
        minWidth: 0,
        maxWidth: double.maxFinite,
      );

      textPainter.paint(
          canvas,
          Offset(centerOffset.dx + scaledPoint * xAngle - textPainter.width / 2,
              centerOffset.dy + scaledPoint * yAngle - textPainter.height / 2));
    });
  }

  void drawZero(Canvas canvas, Offset centerOffset) {
    var path = Path();
    path.addOval(Rect.fromCircle(
      center: centerOffset,
      radius: 10,
    ));

    var zeroPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    var zeroOutlinePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = true;

    canvas.drawPath(path, zeroPaint);
    canvas.drawPath(path, zeroOutlinePaint);

    TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(text: '0', style: featuresTextStyle);
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );
    var zeroOffset = Offset(centerOffset.dx - textPainter.width / 2, centerOffset.dy - textPainter.height / 2);
    textPainter.paint(canvas, zeroOffset);
  }

  double calculateRotationAngle(double prevAngle, double alpha) => (alpha + prevAngle) / 2;

  @override
  bool shouldRepaint(_SuperagileWheelPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
