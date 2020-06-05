import 'package:charts_flutter/flutter.dart' as charty;
import 'package:flutter/material.dart';
import 'package:mocktrade/utils/utils.dart';

class InfoActivity extends StatefulWidget {
  @override
  InfoActivityState createState() {
    return new InfoActivityState();
  }
}

class InfoActivityState extends State<InfoActivity> {
  List<charty.Series<TimeSeriesSales2, DateTime>> seriesList = new List();
  List<charty.Series> seriesList2 = new List();
  List<charty.Series> seriesList3 = new List();

  bool animate = true;

  double low = 32.5;
  double high = 41.2;
  double avg = 38;
  double current = 38;

  double buy = 123171;
  double sell = 12333;

  @override
  void initState() {
    super.initState();
    seriesList2 = _createSampleData();
    seriesList3 = _createSampleData2();
    gethistory();
  }

  void gethistory() {
    Future<dynamic> history = getHistoricalData();
    history.then((resp) {
      print(resp["status"]);
      print(resp["data"]["candles"].length);

      List<TimeSeriesSales2> data = new List();
      for (var i = 0; i < resp["data"]["candles"].length; i++) {
        data.add(new TimeSeriesSales2(
            DateTime.parse(resp["data"]["candles"][i][0]),
            (resp["data"]["candles"][i][1] * 1.0)));
      }
      for (var d in data) {
        print(d.time.toString() + " ---- " + d.sales.toString());
      }
      setState(() {
        seriesList = [
          new charty.Series<TimeSeriesSales2, DateTime>(
            id: '',
            colorFn: (_, __) => charty.MaterialPalette.red.shadeDefault,
            domainFn: (TimeSeriesSales2 sales, _) => sales.time,
            measureFn: (TimeSeriesSales2 sales, _) => sales.sales,
            data: data,
          )
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    low = 1531.85;
    high = 1549.80;
    avg = 1547.95;
    current = 30;
    seriesList2 = _createSampleData();
    seriesList3 = _createSampleData2();
    return Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Performance",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
            height: 300,
            child: new charty.TimeSeriesChart(
              seriesList,
              animate: animate,
              behaviors: [
                new charty.LinePointHighlighter(
                    showHorizontalFollowLine:
                        charty.LinePointHighlighterFollowLineType.none,
                    showVerticalFollowLine:
                        charty.LinePointHighlighterFollowLineType.nearest),
                new charty.SelectNearest(
                    eventTrigger: charty.SelectionTrigger.tapAndDrag),
                new charty.RangeAnnotation([
                  new charty.LineAnnotationSegment(
                      32069.25, charty.RangeAnnotationAxisType.measure,
                      endLabel: "Previous Close",
                      startLabel: "32069.25",
                      color: charty.MaterialPalette.gray.shade400),
                ]),
              ],
              primaryMeasureAxis: new charty.NumericAxisSpec(
                // dash lines
                renderSpec: charty.GridlineRendererSpec(
                    lineStyle: charty.LineStyleSpec(
                  dashPattern: [4, 4],
                )),
                // number format
                tickProviderSpec: new charty.BasicNumericTickProviderSpec(
                    zeroBound: false,
                    dataIsInWholeNumbers: true,
                    desiredTickCount: 5),
              ),
              dateTimeFactory: const charty.LocalDateTimeFactory(),
            ),
          ),
          new Container(
            height: 30,
          ),
          new Container(
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  margin: EdgeInsets.fromLTRB(10, 30, 0, 0),
                  child: new Text(
                    low.toString() + "\nlow",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                new Expanded(
                  child: new Container(
                    height: 30,
                    child: new charty.BarChart(
                      seriesList2,
                      animate: true,
                      vertical: false,
                      // defaultRenderer: new charty.BarRendererConfig(
                      //   groupingType: charty.BarGroupingType.groupedStacked,
                      //   weightPattern: [2],
                      // ),
                      barGroupingType: charty.BarGroupingType.grouped,
                      primaryMeasureAxis: new charty.NumericAxisSpec(
                          renderSpec: new charty.NoneRenderSpec()),
                      domainAxis: new charty.OrdinalAxisSpec(
                          showAxisLine: false,
                          renderSpec: new charty.NoneRenderSpec()),
                      customSeriesRenderers: [
                        new charty.BarTargetLineRendererConfig<String>(
                            // ID used to link series to this renderer.
                            customRendererId: 'customTargetLine',
                            groupingType: charty.BarGroupingType.grouped)
                      ],
                    ),
                  ),
                ),
                new Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 10, 0),
                  child: new Text(
                    high.toString() + "\nhigh",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          new Container(
            height: 30,
          ),
          new Container(
            height: 200,
            child: new charty.PieChart(
              seriesList3,
              animate: true,
              behaviors: [
                new charty.DatumLegend(
                  // Positions for "start" and "end" will be left and right respectively
                  // for widgets with a build context that has directionality ltr.
                  // For rtl, "start" and "end" will be right and left respectively.
                  // Since this example has directionality of ltr, the legend is
                  // positioned on the right side of the chart.
                  // position: charty.BehaviorPosition.top,
                  // By default, if the position of the chart is on the left or right of
                  // the chart, [horizontalFirst] is set to false. This means that the
                  // legend entries will grow as new rows first instead of a new column.
                  horizontalFirst: true,
                  // This defines the padding around each legend entry.
                  // cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
                  // Set [showMeasures] to true to display measures in series legend.
                  showMeasures: true,
                  // Configure the measure value to be shown by default in the legend.
                  legendDefaultMeasure: charty.LegendDefaultMeasure.firstValue,
                  // Optionally provide a measure formatter to format the measure value.
                  // If none is specified the value is formatted as a decimal.
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Create series list with multiple series
  List<charty.Series<OrdinalSales, String>> _createSampleData() {
    return [
      new charty.Series<OrdinalSales, String>(
        id: '',
        colorFn: (_, __) => charty.MaterialPalette.gray.shade400,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: [
          new OrdinalSales('2014', high - low),
        ],
      ),
      new charty.Series<OrdinalSales, String>(
        id: '',
        colorFn: (_, __) => charty.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: [
          new OrdinalSales('2014', avg - low),
        ],
      )
        // Configure our custom bar target renderer for this series.
        ..setAttribute(charty.rendererIdKey, 'customTargetLine'),
    ];
  }

  List<charty.Series<LinearSales, String>> _createSampleData2() {
    return [
      new charty.Series<LinearSales, String>(
        id: 'Sales',
        colorFn: (LinearSales sales, _) => sales.year == "Buy"
            ? charty.MaterialPalette.green.shadeDefault
            : charty.MaterialPalette.red.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: [
          new LinearSales("Buy", buy),
          new LinearSales("Sell", sell),
        ],
        labelAccessorFn: (LinearSales row, _) => '',
      )
    ];
  }
}

class TimeSeriesSales2 {
  final DateTime time;
  final double sales;

  TimeSeriesSales2(this.time, this.sales);
}

class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}

class LinearSales {
  final String year;
  final double sales;

  LinearSales(this.year, this.sales);
}
