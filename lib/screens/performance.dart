import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:mocktrade/utils/models.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:charts_flutter/flutter.dart' as charty;
import 'package:intl/intl.dart';

import '../utils/config.dart';
import '../utils/utils.dart';

class PerformanceActivity extends StatefulWidget {
  @override
  PerformanceActivityState createState() {
    return new PerformanceActivityState();
  }
}

class PerformanceActivityState extends State<PerformanceActivity> {
  double width = 0;
  bool loading = true;

  List<charty.Series<TimeSeriesSales, DateTime>> seriesList = new List();
  List<Amount> amounts = new List();

  int days = 365;

  @override
  void initState() {
    super.initState();

    amountsapi();
  }

  void amountsapi() {
    setState(() {
      loading = true;
    });
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        setState(() {
          loading = false;
        });
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            amountsapi();
          }
        });
      } else {
        Future<Amounts> data = getAmounts({
          "user_id": userID,
          "date": dateFormat
                  .format(new DateTime.now().add(new Duration(days: -365))) +
              "," +
              dateFormat.format(new DateTime.now()),
          "orderby": "date",
          "sortby": "desc",
        }, 1);
        data.then((response) {
          setState(() {
            loading = false;
          });
          if (response.amounts != null) {
            if (response.amounts.length > 0) {
              this.amounts = response.amounts;
              parseAmounts(365);
            }
          }
          if (response.meta != null && response.meta.messageType == "1") {
            oneButtonDialog(context, "", response.meta.message,
                !(response.meta.status == STATUS_403));
          }
        });
      }
    });
  }

  void parseAmounts(int days) {
    List<TimeSeriesSales> data = new List();
    for (var i = 0; i < amounts.length; i++) {
      if (DateTime.now().difference(DateTime.parse(amounts[i].date)).inDays <
          days) {
        data.add(new TimeSeriesSales(DateTime.parse(amounts[i].date),
            double.parse(amounts[i].amount).ceil()));
      } else {
        break;
      }
    }
    setState(() {
      seriesList = [
        new charty.Series<TimeSeriesSales, DateTime>(
          id: 'Sales',
          colorFn: (_, __) => charty.MaterialPalette.blue.shadeDefault,
          domainFn: (TimeSeriesSales sales, _) => sales.time,
          measureFn: (TimeSeriesSales sales, _) => sales.sales,
          data: data,
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
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
      body: new ModalProgressHUD(
          inAsyncCall: loading,
          child: new Container(
            color: Colors.white,
            child: new SafeArea(
              child: new Container(
                padding: EdgeInsets.all(20),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    seriesList.length > 0
                        ? new Container(
                            child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: new RaisedButton(
                                  color: days == 7 ? Colors.blue : Colors.white,
                                  onPressed: () {
                                    days = 7;
                                    parseAmounts(7);
                                  },
                                  child: new Text("Week",
                                      style: TextStyle(
                                        color: days == 7
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                              ),
                              new Expanded(
                                child: new RaisedButton(
                                  color:
                                      days == 30 ? Colors.blue : Colors.white,
                                  onPressed: () {
                                    days = 30;
                                    parseAmounts(30);
                                  },
                                  child: new Text("Month",
                                      style: TextStyle(
                                        color: days == 30
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                              ),
                              new Expanded(
                                child: new RaisedButton(
                                  color: days == 365
                                      ? Colors.lightBlue
                                      : Colors.white,
                                  onPressed: () {
                                    days = 365;
                                    parseAmounts(365);
                                  },
                                  child: new Text("Year",
                                      style: TextStyle(
                                        color: days == 365
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                              ),
                            ],
                          ))
                        : new Container(),
                    seriesList.length > 0
                        ? new Container(
                            height: 300,
                            child: new Card(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(3.0),
                                side: BorderSide(
                                  color: Colors.white,
                                ),
                              ),
                              elevation: 10,
                              child: new Container(
                                padding: EdgeInsets.all(10),
                                child: new charty.TimeSeriesChart(
                                  seriesList,
                                  animate: true,
                                  behaviors: [
                                    new charty.LinePointHighlighter(
                                        showHorizontalFollowLine: charty
                                            .LinePointHighlighterFollowLineType
                                            .none,
                                        showVerticalFollowLine: charty
                                            .LinePointHighlighterFollowLineType
                                            .nearest),
                                    new charty.SelectNearest(
                                        eventTrigger:
                                            charty.SelectionTrigger.tapAndDrag)
                                  ],
                                  primaryMeasureAxis: new charty
                                          .NumericAxisSpec(
                                      // dash lines
                                      renderSpec: charty.GridlineRendererSpec(
                                          lineStyle: charty.LineStyleSpec(
                                        dashPattern: [4, 4],
                                      )),
                                      // number format
                                      tickFormatterSpec: new charty
                                              .BasicNumericTickFormatterSpec.fromNumberFormat(
                                          new NumberFormat
                                              .compactSimpleCurrency()),
                                      tickProviderSpec: new charty
                                              .BasicNumericTickProviderSpec(
                                          zeroBound: false,
                                          dataIsInWholeNumbers: true,
                                          desiredTickCount: 5)),
                                  dateTimeFactory:
                                      const charty.LocalDateTimeFactory(),
                                ),
                              ),
                            ),
                          )
                        : new Container(),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
