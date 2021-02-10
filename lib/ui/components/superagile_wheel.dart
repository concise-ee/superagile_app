library flutter_radar_chart;

import 'dart:math' as math;
import 'dart:math' show pi, cos, sin;
import 'dart:ui';

import 'package:flutter/material.dart';

class SuperagileWheel extends StatefulWidget {
  final List<String> features;
  final List<int> data;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;

  const SuperagileWheel({
    Key key,
    @required this.features,
    @required this.data,
    this.featuresTextStyle = const TextStyle(color: Colors.yellow, fontSize: 9),
    this.outlineColor = Colors.yellow,
    this.axisColor = Colors.grey,
  }) : super(key: key);

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
  void didUpdateWidget(SuperagileWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(370, 370),
      painter: SuperagileWheelPainter(
          widget.features, widget.data, widget.featuresTextStyle, widget.outlineColor, widget.axisColor, this.fraction),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class SuperagileWheelPainter extends CustomPainter {
  final List<String> features;
  final List<int> data;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final double fraction;

  SuperagileWheelPainter(
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

    _drawOutlinePath(canvas, centerOffset, radius);

    features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset = Offset(centerOffset.dx + radius * xAngle, centerOffset.dy + radius * yAngle);

      _drawAxisLine(canvas, centerOffset, featureOffset);

      _drawFeatureLabel(canvas, centerOffset, angle, index, feature, featureLabelRadius);
    });

    _drawGraphOutline(canvas, centerOffset, scale, angle);

    _drawScoreLabels(canvas, centerOffset, angle, scale);

    _drawZero(canvas, centerOffset);
  }

  void _drawOutlinePath(Canvas canvas, Offset centerOffset, double radius) {
    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var path = Path();

    // Draw a circle
    path.addOval(Rect.fromCircle(
      center: centerOffset,
      radius: radius,
    ));

    canvas.drawPath(path, outlinePaint);
  }

  void _drawAxisLine(Canvas canvas, Offset startingOffset, Offset endingOffset) {
    var axisPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawLine(startingOffset, endingOffset, axisPaint);
  }

  void _drawFeatureLabel(
      Canvas canvas, Offset centerOffset, double angle, int index, String feature, double featureLabelRadius) {
    canvas.save();
    double startingAngle = angle * index - angle / 2 * (feature.length / 18);
    canvas.translate(centerOffset.dx, centerOffset.dy - featureLabelRadius);

    if (startingAngle != 0) {
      final d = 2 * featureLabelRadius * math.sin(startingAngle / 2);
      final rotationAngle = _calculateRotationAngle(0, startingAngle);
      canvas.rotate(rotationAngle);
      canvas.translate(d, 0);
    }

    double nextStartingAngle = startingAngle;
    for (int i = 0; i < feature.length; i++) {
      nextStartingAngle = _drawLetter(canvas, feature[i], nextStartingAngle, featureLabelRadius);
    }
    canvas.restore();
  }

  double _drawLetter(Canvas canvas, String letter, double prevAngle, double radius) {
    TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(text: letter, style: featuresTextStyle);
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );

    final double d = textPainter.width;
    final double alpha = 2 * math.asin(d / (2 * radius));

    final newAngle = _calculateRotationAngle(prevAngle, alpha);
    canvas.rotate(newAngle);

    textPainter.paint(canvas, Offset(0, -textPainter.height));
    canvas.translate(d, 0);

    return alpha;
  }

  void _drawGraphOutline(Canvas canvas, Offset centerOffset, double scale, double angle) {
    var graphOutlinePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    // Start the graph on the initial point
    var scaledPoint = scale * data[0] * fraction;
    var path = Path();

    path.moveTo(centerOffset.dx, centerOffset.dy - scaledPoint);

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

  void _drawScoreLabels(Canvas canvas, Offset centerOffset, double angle, double scale) {
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
        ..color = Colors.grey
        ..style = PaintingStyle.fill;

      var scoreLabelOutlinePaint = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..isAntiAlias = true;

      canvas.drawPath(path, scoreLabelPaint);
      canvas.drawPath(path, scoreLabelOutlinePaint);

      TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
          text: point.toString(),
          style: TextStyle(color: Color.fromRGBO(51, 51, 51, 1), fontSize: 9, fontWeight: FontWeight.bold));
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

  void _drawZero(Canvas canvas, Offset centerOffset) {
    var path = Path();
    path.addOval(Rect.fromCircle(
      center: centerOffset,
      radius: 10,
    ));

    var zeroPaint = Paint()
      ..color = Color.fromRGBO(51, 51, 51, 1)
      ..style = PaintingStyle.fill;

    var zeroOutlinePaint = Paint()
      ..color = Colors.grey
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

  double _calculateRotationAngle(double prevAngle, double alpha) => (alpha + prevAngle) / 2;

  @override
  bool shouldRepaint(SuperagileWheelPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
