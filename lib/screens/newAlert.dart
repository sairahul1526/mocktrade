import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:slider_button/slider_button.dart';
import 'dart:async';

import './alert.dart';
import '../utils/models.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class NewAlertActivity extends StatefulWidget {
  final String id;
  final String symbol;

  NewAlertActivity(this.id, this.symbol);

  @override
  NewAlertActivityState createState() {
    return new NewAlertActivityState(this.id, this.symbol);
  }
}

class NewAlertActivityState extends State<NewAlertActivity> {
  double width = 0;

  TextEditingController price = new TextEditingController();

  String id;
  String symbol;
  bool sell;

  bool loading = false;

  final globalKey = GlobalKey<ScaffoldState>();

  double lastTradedPrice;
  double closePrice;
  String percentage = "0";

  Widget alertbutton;

  String when = "1";

  NewAlertActivityState(this.id, this.symbol);
  @override
  void initState() {
    super.initState();

    closePrice = closes[id];
  }

  void splitdata(Map<String, double> data) {
    if (data[id] != null) {
      lastTradedPrice = data[id];

      if (price.text != null &&
          price.text.length > 0 &&
          double.tryParse(price.text) != null) {
        percentage =
            (((double.parse(price.text) - lastTradedPrice) / lastTradedPrice) *
                    100)
                .toStringAsFixed(2);
      }
    }
  }

  void closeActivity(String title, String subtitle, bool success) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new AlertActivity(title, subtitle, success)),
    );
  }

  Widget getalertbutton() {
    return new Align(
        alignment: Alignment.bottomCenter,
        child: new SliderButton(
          width: width * 0.65,
          height: 65,
          action: () {
            setState(() {
              loading = true;
            });
            if (price.text.length > 0 &&
                price.text != "0" &&
                lastTradedPrice != null &&
                lastTradedPrice != 0 &&
                double.tryParse(price.text) != null) {
              checkInternet().then((internet) {
                if (internet == null || !internet) {
                  closeActivity("Failed", "No Internet connection", false);
                } else {
                  Future<dynamic> load = addGetResponse(API.ALERT, {
                    "user_id": userID,
                    "ticker": id.toString(),
                    "name": tickerMap[id].tradingSymbol,
                    "price": price.text,
                    "when": when,
                    "expiry": tickerMap[id].expiry,
                  });
                  load.then((response) {
                    if (response != null) {
                      if (response["meta"]["status"] == "200" ||
                          response["meta"]["status"] == "201") {
                        var date = DateTime.now().toString();
                        if (response["created_date_time"] != null) {
                          date = response["created_date_time"];
                        }
                        alerts.insert(
                          0,
                          new Alert(
                            userID: userID,
                            ticker: id.toString(),
                            name: tickerMap[id].tradingSymbol,
                            price: price.text,
                            when: when,
                            alerted: "0",
                            status: "1",
                            createdDateTime: date,
                          ),
                        );
                        closeActivity(
                            "Success", response["meta"]["message"], true);
                      } else {
                        closeActivity(
                            "Failed", response["meta"]["message"], false);
                      }
                    } else {
                      closeActivity("Failed", "Alert Not Created", false);
                    }
                  });
                }
              });
            } else {
              closeActivity("Failed", "Alert Not Created", false);
            }
          },
          label: new Text(
            "ALERT            ",
            style: new TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          buttonColor: Colors.white,
          highlightedColor: Colors.white,
          baseColor: Colors.white,
          backgroundColor: Colors.blue,
          icon: new Center(
            child: new Icon(Icons.arrow_forward_ios),
          ),
          shimmer: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    setState(() {
      alertbutton = getalertbutton();
    });
    return new Scaffold(
      key: globalKey,
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          new IconButton(
            onPressed: () {
              setState(() {
                when = when == "1" ? "0" : "1";
              });
            },
            icon: new Icon(Icons.swap_vert),
          )
        ],
      ),
      floatingActionButton: alertbutton,
      body: new ModalProgressHUD(
        inAsyncCall: loading,
        child: new Container(
          padding: EdgeInsets.all(15),
          child: new StreamBuilder(
            stream: streamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                splitdata(snapshot.data);
              }
              return new ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  new Container(
                    height: 8,
                  ),
                  closePrice != null && lastTradedPrice != null
                      ? new Text(
                          lastTradedPrice.toStringAsFixed(2) +
                              "   " +
                              (lastTradedPrice - closePrice)
                                  .toStringAsFixed(2) +
                              "   " +
                              ((lastTradedPrice - closePrice) *
                                      100 /
                                      closePrice)
                                  .toStringAsFixed(2) +
                              "%",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        )
                      : new Container(),
                  new Container(
                    height: 25,
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        "Price " + (when == "1" ? "Greater" : "Less") + " Than",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      new Expanded(
                        child: new Container(
                          width: width * 0.25,
                          child: new TextField(
                            onChanged: (text) {
                              if (text.length > 0 && lastTradedPrice != null) {
                                setState(() {
                                  percentage = (((double.parse(price.text) -
                                                  lastTradedPrice) /
                                              lastTradedPrice) *
                                          100)
                                      .toStringAsFixed(2);
                                });
                              } else {
                                setState(() {
                                  percentage = "0";
                                });
                              }
                            },
                            autofocus: true,
                            controller: price,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: '1',
                            ),
                            onSubmitted: (String value) {},
                          ),
                        ),
                      ),
                      new Container(
                        child: new Text(
                          "(" + percentage + "%)",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                  new Container(
                    height: 10,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
