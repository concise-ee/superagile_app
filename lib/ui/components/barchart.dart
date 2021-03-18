import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/global_theme.dart';

class BarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final List<String> answerOptions;
  final charts.BarLabelDecorator<String> barLabelDecorator = new charts.BarLabelDecorator();

  BarChart(this.answerOptions, this.seriesList, {this.animate});

  factory BarChart.withSampleData(List<String> answerOptions, String topic, int value) {
    return new BarChart(
      answerOptions,
      _createBarChart(topic, value),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final customTickFormatter =
    charts.BasicNumericTickFormatterSpec((num value) => answerOptions[value.toInt()]);

    return new charts.BarChart(
      seriesList,
      animate: animate,
      domainAxis: new charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 18,
                  color: charts.Color.white),
              lineStyle: new charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(secondaryColor)))),
      primaryMeasureAxis: new charts.NumericAxisSpec(
              tickFormatterSpec: customTickFormatter,
          renderSpec: new charts.GridlineRendererSpec(
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 18,
                  color: charts.Color.white),
              lineStyle: new charts.LineStyleSpec(
                  color: charts.ColorUtil.fromDartColor(secondaryColor))),
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
              dataIsInWholeNumbers: true,
              desiredTickCount: 5)),
    );
  }

  static List<charts.Series<OrdinalValues, String>> _createBarChart(String topic, num value) {
    final data = [
      new OrdinalValues(topic, value + 1)
    ];

    return [
      new charts.Series<OrdinalValues, String>(
        id: 'Values',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(accentColor),
        domainFn: (OrdinalValues values, _) => values.topic,
        measureFn: (OrdinalValues values, _) => values.answer,
        data: data, labelAccessorFn: (OrdinalValues values, _) =>
    '${(values.answer -1).toString()}')
    ];
  }
}

class OrdinalValues {
  final String topic;
  final int answer;

  OrdinalValues(this.topic, this.answer);
}
