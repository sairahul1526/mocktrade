/// Scatter plot chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleScatterPlotChart extends StatefulWidget {
  @override
  SimpleScatterPlotChartState createState() {
    return new SimpleScatterPlotChartState();
  }
}

class SimpleScatterPlotChartState extends State<SimpleScatterPlotChart> {
  List<charts.Series> seriesList;

  @override
  void initState() {
    super.initState();

    seriesList = _createSampleData();
  }

  @override
  Widget build(BuildContext context) {
    seriesList = _createSampleData();
    return new Scaffold(
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
      body: new Container(
        height: 30,
        child: new charts.BarChart(seriesList,
            animate: true,
            vertical: false,
            barGroupingType: charts.BarGroupingType.grouped,
            primaryMeasureAxis: new charts.NumericAxisSpec(
                renderSpec: new charts.NoneRenderSpec()),
            domainAxis: new charts.OrdinalAxisSpec(
                showAxisLine: true, renderSpec: new charts.NoneRenderSpec()),
            customSeriesRenderers: [
              new charts.BarTargetLineRendererConfig<String>(
                  // ID used to link series to this renderer.
                  customRendererId: 'customTargetLine',
                  groupingType: charts.BarGroupingType.grouped)
            ]),
      ),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 5),
    ];

    final desktopTargetLineData = [
      new OrdinalSales('2014', 4.25),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop Target Line',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopTargetLineData,
      )
        // Configure our custom bar target renderer for this series.
        ..setAttribute(charts.rendererIdKey, 'customTargetLine'),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final double sales;

  OrdinalSales(this.year, this.sales);
}
