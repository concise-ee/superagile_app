library flutter_radar_chart;

import 'dart:math' as math;
import 'dart:math' show pi, cos, sin;
import 'dart:ui';

import 'package:flutter/material.dart';

const defaultGraphColors = [
  Colors.yellow,
  Colors.grey,
];

class RadarChart extends StatefulWidget {
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;

  const RadarChart({
    Key key,
    @required this.ticks,
    @required this.features,
    @required this.data,
    this.featuresTextStyle = const TextStyle(color: Colors.yellow, fontSize: 9),
    this.outlineColor = Colors.yellow,
    this.axisColor = Colors.grey,
    this.graphColors = defaultGraphColors,
  }) : super(key: key);

  factory RadarChart.light({
    @required List<int> ticks,
    @required List<String> features,
    @required List<List<int>> data,
  }) {
    return RadarChart(ticks: ticks, features: features, data: data);
  }

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    animationController.reset();
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(370, 370),
      painter: RadarChartPainter(widget.ticks, widget.features, widget.data, widget.featuresTextStyle,
          widget.outlineColor, widget.axisColor, widget.graphColors, this.fraction),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class RadarChartPainter extends CustomPainter {
  final List<int> ticks;
  final List<String> features;
  final List<List<int>> data;
  final TextStyle featuresTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final List<Color> graphColors;
  final double fraction;

  RadarChartPainter(
    this.ticks,
    this.features,
    this.data,
    this.featuresTextStyle,
    this.outlineColor,
    this.axisColor,
    this.graphColors,
    this.fraction,
  );

  Path variablePath(Size size, double radius, int sides) {
    var path = Path();
    var angle = (math.pi * 2) / sides;

    Offset center = Offset(size.width / 2, size.height / 2);

    if (sides < 3) {
      // Draw a circle
      path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ));
    } else {
      // Draw a polygon
      Offset startPoint = Offset(radius * cos(-pi / 2), radius * sin(-pi / 2));

      path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

      for (int i = 1; i <= sides; i++) {
        double x = radius * cos(angle * i - pi / 2) + center.dx;
        double y = radius * sin(angle * i - pi / 2) + center.dy;
        path.lineTo(x, y);
      }
      path.close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / ticks.last;

    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawPath(variablePath(size, radius, 0), outlinePaint);
    // Painting the circles

    // Painting the axis for each given feature
    var angle = (2 * pi) / features.length;

    features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset = Offset(centerX + radius * xAngle, centerY + radius * yAngle);

      canvas.drawLine(centerOffset, featureOffset, ticksPaint);

      canvas.save();

      double initialAngle = angle * index - angle / 2 * (feature.length / 18);

      var featureLabelRadius = 1.07 * radius;
      canvas.translate(size.width / 2, size.height / 2 - featureLabelRadius);

      if (initialAngle != 0) {
        final d = 2 * featureLabelRadius * math.sin(initialAngle / 2);
        final rotationAngle = _calculateRotationAngle(0, initialAngle);
        canvas.rotate(rotationAngle);
        canvas.translate(d, 0);
      }

      double angle1 = initialAngle;
      for (int i = 0; i < feature.length; i++) {
        angle1 = _drawLetter(canvas, feature[i], angle1, featureLabelRadius);
      }
      canvas.restore();
    });

    // Painting each graph
    data.asMap().forEach((index, graph) {
      var graphPaint = Paint()
        ..color = graphColors[index % graphColors.length].withOpacity(0.3)
        ..style = PaintingStyle.stroke;

      var graphOutlinePaint = Paint()
        ..color = graphColors[index % graphColors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = true;

      // Start the graph on the initial point
      var scaledPoint = scale * graph[0] * fraction;
      var path = Path();

      path.moveTo(centerX, centerY - scaledPoint);

      graph.asMap().forEach((index, point) {
        if (index == 0) return;

        var xAngle = cos(angle * index - pi / 2);
        var yAngle = sin(angle * index - pi / 2);
        var scaledPoint = scale * point * fraction;

        path.lineTo(centerX + scaledPoint * xAngle, centerY + scaledPoint * yAngle);
      });

      path.close();

      canvas.drawPath(path, graphPaint);
      canvas.drawPath(path, graphOutlinePaint);

      graph.asMap().forEach((index, point) {
        var xAngle = cos(angle * index - pi / 2);
        var yAngle = sin(angle * index - pi / 2);
        var scaledPoint = scale * point * fraction;

        var path1 = Path();
        path1.addOval(Rect.fromCircle(
          center: Offset(centerX + scaledPoint * xAngle, centerY + scaledPoint * yAngle),
          radius: 7,
        ));

        var graphPaint1 = Paint()
          ..color = Colors.grey
          ..style = PaintingStyle.fill;

        var graphOutlinePaint1 = Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..isAntiAlias = true;

        canvas.drawPath(path1, graphPaint1);
        canvas.drawPath(path1, graphOutlinePaint1);

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
            Offset(centerX + scaledPoint * xAngle - textPainter.width / 2,
                centerY + scaledPoint * yAngle - textPainter.height / 2));
      });
    });

    var path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: 10,
    ));

    var graphPaint = Paint()
      ..color = Color.fromRGBO(51, 51, 51, 1)
      ..style = PaintingStyle.fill;

    var graphOutlinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = true;

    canvas.drawPath(path, graphPaint);
    canvas.drawPath(path, graphOutlinePaint);

    TextPainter textPainter = new TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(text: '0', style: featuresTextStyle);
    textPainter.layout(
      minWidth: 0,
      maxWidth: double.maxFinite,
    );
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
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

  double _calculateRotationAngle(double prevAngle, double alpha) => (alpha + prevAngle) / 2;

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
