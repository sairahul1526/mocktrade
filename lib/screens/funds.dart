import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:mocktrade/utils/models.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

import '../utils/config.dart';
import '../utils/utils.dart';

class FundsActivity extends StatefulWidget {
  @override
  FundsActivityState createState() {
    return new FundsActivityState();
  }
}

class FundsActivityState extends State<FundsActivity>
    with AutomaticKeepAliveClientMixin<FundsActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;
  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  @override
  void initState() {
    super.initState();
    accountsapi();
  }

  void accountsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            accountsapi();
          }
        });
      } else {
        Future<Accounts> data = getAccounts({"user_id": userID}, 1);
        data.then((response) {
          if (response.accounts != null) {
            if (response.accounts.length > 0) {
              setState(() {
                amount = double.parse(response.accounts[0].amount);
              });
            }
            fillData();
          }
          if (response.meta != null && response.meta.messageType == "1") {
            oneButtonDialog(context, "", response.meta.message,
                !(response.meta.status == STATUS_403));
          }
        });
      }
    });
  }

  void splitdata(List<int> data) {
    if (data.length < 2) {
      return;
    }
    int noPackets = converttoint(data.getRange(0, 2));

    int j = 2;
    for (var i = 0; i < noPackets; i++) {
      tickers[converttoint(data.getRange(j + 2, j + 2 + 4))] =
          converttoint(data.getRange(j + 2 + 4, j + 2 + 8)).toDouble() / 100;
      j = j + 2 + 8;
    }
    calculate();
  }

  calculate() {
    invested = 0;
    current = 0;
    for (var position in positions) {
      if (tickers[int.parse(position.ticker)] != null) {
        invested += double.parse(position.invested);
        current +=
            tickers[int.parse(position.ticker)] * double.parse(position.shares);
      }
    }
  }

  fillData() {
    List<String> ids = new List();

    if (positions.length == 0) {
      invested = 0;
      current = 0;
    }
    positions.forEach((f) => ids.add(f.ticker));
    fillDataAPI("https://api.kite.trade/quote/ltp?", ids).then((resp) {
      for (var id in ids) {
        if (resp["data"][id] != null) {
          tickers[int.parse(id)] = resp["data"][id]["last_price"].toDouble();
        }
      }
      calculate();
      getData();
    });
  }

  getData() {
    List<int> ids = new List();

    if (positions.length == 0) {
      invested = 0;
      current = 0;
    }
    positions.forEach((f) => ids.add(int.parse(f.ticker)));
    Map<String, dynamic> message = {
      "a": "mode",
      "v": ["ltp", ids]
    };
    channel.sink.add(jsonEncode(message));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Funds",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ),
      body: new Container(
        color: Colors.white,
        child: new SafeArea(
          child: new Container(
            padding: EdgeInsets.all(20),
            child: new StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && positions.length > 0) {
                    splitdata(snapshot.data);
                  }
                  return new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new RaisedButton(
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(3.0),
                          side: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.white,
                        elevation: 10,
                        child: new Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: new Text(
                                  current != null && amount != null
                                      ? (current + amount).toStringAsFixed(2)
                                      : (amount != null
                                          ? amount.toStringAsFixed(2)
                                          : ""),
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              new Row(
                                children: <Widget>[
                                  new Container(
                                    width: 10,
                                  ),
                                  new Expanded(
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Text(
                                          invested != null && amount != null
                                              ? (invested *
                                                          100 /
                                                          (invested + amount))
                                                      .toStringAsFixed(2) +
                                                  " %"
                                              : "0.00 %",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        new Text(
                                          "Invested",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  new Expanded(
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              "Invested",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            new Text(
                                              invested != null
                                                  ? invested.toStringAsFixed(2)
                                                  : "0.00",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
                                        ),
                                        new Divider(),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              "Cash",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            new Text(
                                              amount.toStringAsFixed(2),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              new Container(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
