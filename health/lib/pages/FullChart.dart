import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart' as chartsTextElement;
import 'package:charts_flutter/src/text_style.dart' as chartsTextStyle;

class FullChart extends StatelessWidget {
  List data;
  String sign;
  int id;
  FullChart(this.data, this.sign, this.id);

  draw(List data) {
    List<Graph> _value = [];
    for (var i = (data.length) - 1; i >= 0; i--) {
      _value.add(Graph(
          new DateTime.fromMillisecondsSinceEpoch(data[i]["Timestamp"] * 1000),
          data[i]["$id"].toDouble()));
    }
    List<charts.Series<Graph, DateTime>> series = [
      charts.Series(
          id: sign,
          data: _value,
          domainFn: (Graph series, _) => series.timestamp,
          measureFn: (Graph series, _) => series.value,
          colorFn: (Graph series, _) =>
              charts.MaterialPalette.teal.shadeDefault)
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(sign),
      ),
      body: SafeArea(
          child: Card(
        color: Colors.white,
        child: new charts.TimeSeriesChart(
          draw(data),
          animate: true,
          selectionModels: [
            charts.SelectionModelConfig(
                changedListener: (charts.SelectionModel model) {
              if (model.hasDatumSelection) {
                CustomCircleSymbolRenderer.tim =
                    model.selectedDatum.first.datum.timestamp;
                final value = model.selectedSeries[0]
                    .measureFn(model.selectedDatum[0].index);
                CustomCircleSymbolRenderer.value = value.toString();
                CustomCircleSymbolRenderer.id = id;
              }
            })
          ],
          behaviors: [
            new charts.PanAndZoomBehavior(),
            new charts.SlidingViewport(),
            new charts.LinePointHighlighter(
                symbolRenderer: CustomCircleSymbolRenderer(),
                showVerticalFollowLine:
                    charts.LinePointHighlighterFollowLineType.nearest),
          ],
          primaryMeasureAxis: new charts.NumericAxisSpec(
              viewport: id==2?charts.NumericExtents(0,100):id==4?charts.NumericExtents(0,50):null,
              tickProviderSpec:
                  new charts.BasicNumericTickProviderSpec(zeroBound: true)),
          domainAxis: DateTimeAxisSpecWorkaround(
            tickFormatterSpec: new charts.AutoDateTimeTickFormatterSpec(
              minute: new charts.TimeFormatterSpec(
                format: 'hh:mm', // or even HH:mm here too
                transitionFormat: 'hh:mm',
              ),
              hour: new charts.TimeFormatterSpec(
                format: 'hh:mm', // or even HH:mm here too
                transitionFormat: 'ddMMM hh:mm',
              ),
              day: new charts.TimeFormatterSpec(
                format: 'hh:mm', // or even HH:mm here too
                transitionFormat: 'ddMMM hh:mm',
              ),
            ),
          ),
        ),
      )),
    );
  }
}

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  static String value;
  static DateTime tim;
  static int id;
  String unit;
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      charts.Color fillColor,
      charts.FillPatternType fillPattern,
      charts.Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top + 48, bounds.width + 125,
            bounds.height + 27),
        fill: charts.Color.white);
    if (id == 0) {
      unit = "BPM";
    }
    if (id == 1) {
      unit = "\u2109";
    }
    if (id == 2) {
      unit = "%";
    }
    if (id == 3) {
      unit = "m";
    }
    if (id == 4) {
      unit = "\u2103";
    }
    var textStyle = chartsTextStyle.TextStyle();
    textStyle.color = charts.Color(r: 0, g: 150, b: 136);
    textStyle.fontSize = 15;
    canvas.drawText(
        chartsTextElement.TextElement(
            value +
                " " +
                unit +
                "\n" +
                DateFormat("hh:mm:ss dd MMM,yy").format(tim).toString(),
            style: textStyle),
        (bounds.left).round(),
        (bounds.top + 50).round());
  }
}

class Graph {
  final DateTime timestamp;
  final double value;
  Graph(this.timestamp, this.value);
}

class DateTimeAxisSpecWorkaround extends charts.DateTimeAxisSpec {
  const DateTimeAxisSpecWorkaround(
      {charts.RenderSpec<DateTime> renderSpec,
      charts.DateTimeTickProviderSpec tickProviderSpec,
      charts.DateTimeTickFormatterSpec tickFormatterSpec,
      bool showAxisLine,
      viewport})
      : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine,
            viewport: viewport);

  @override
  configure(charts.Axis<DateTime> axis, charts.ChartContext context,
      charts.GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);
    axis.autoViewport = false;
  }
}
