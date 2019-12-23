import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import './buysell.dart';
import '../utils/config.dart';
import '../utils/utils.dart';
import '../utils/models.dart';
import '../utils/api.dart';

class PortfolioActivity extends StatefulWidget {
  @override
  PortfolioActivityState createState() {
    return new PortfolioActivityState();
  }
}

class PortfolioActivityState extends State<PortfolioActivity>
    with AutomaticKeepAliveClientMixin<PortfolioActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  double pandl = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
      
  @override
  void initState() {
    super.initState();

    fillData();
    accountsapi();
  }

  void accountsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
      } else {
        Future<Accounts> data = getAccounts({"user_id": userID});
        data.then((response) {
          if (response.accounts != null) {
            if (response.accounts.length > 0) {
              setState(() {
                amount = double.parse(response.accounts[0].amount);
              });
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

  void positionsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
        _refreshController.refreshCompleted();
      } else {
        Future<Positions> data = getPositions({"user_id": userID});
        data.then((response) {
            _refreshController.refreshCompleted();
          if (response.positions != null) {
            positionsMap.clear();
            positions.clear();
            if (response.positions.length > 0) {
              response.positions.forEach((position) {
                positionsMap[position.ticker] = position;
                positions.add(position);
              });
            }
            setState(() {
              positionsMap = positionsMap;
              positions = positions;
            });
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

  void _onRefresh() async {
    positionsapi();
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

    invested = 0;
    current = 0;
    pandl = 0;
    for (var position in positions) {
      if (tickers[int.parse(position.ticker)] != null) {
        invested += double.parse(position.invested);
        current +=
            tickers[int.parse(position.ticker)] * double.parse(position.shares);
      }

      pandl = current - invested;
    }
  }

  getData() {
    List<int> ids = new List();

    if (positions.length == 0) {
      invested = 0;
      current = 0;
      pandl = 0;
    }
    positions.forEach((f) => ids.add(int.parse(f.ticker)));
    Map<String, dynamic> message = {
      "a": "mode",
      "v": ["ltp", ids]
    };
    channel.sink.add(jsonEncode(message));
    _refreshController.refreshCompleted();
  }

  fillData() {
    List<String> ids = new List();

    marketwatch.forEach((f) => ids.add(f.instrumentToken));
    fillDataAPI(ids).then((resp) {
      for (var id in ids) {
        if (resp["data"][id] != null) {
          tickers[int.parse(id)] = resp["data"][id]["last_price"].toDouble();
        }
      }
      getData();
    });
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
          "Portfolio",
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
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: new Column(
                          children: <Widget>[
                            new Row(
                              children: <Widget>[
                                new Container(
                                  width: 10,
                                ),
                                new Expanded(
                                  child: new Text(
                                    "Invested",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                new Expanded(
                                  child: new Text(
                                    "Current",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            new Container(
                              height: 3,
                            ),
                            new Row(
                              children: <Widget>[
                                new Container(
                                  width: 10,
                                ),
                                new Expanded(
                                  child: new Text(
                                    invested.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                new Expanded(
                                  child: new Text(
                                    current.toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            new Container(
                              height: 7,
                            ),
                            new Divider(),
                            new Container(
                              height: 7,
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Container(
                                  width: 7,
                                ),
                                new Expanded(
                                  child: new Text(
                                    "P&L",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                               new Row(
                                  children: <Widget>[
                                    new Text(
                                      (pandl > 0 ? "+" : "") +
                                          pandl.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: pandl > 0
                                            ? Colors.green
                                            : (pandl < 0
                                                ? Colors.red
                                                : Colors.black),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    new Text(
                                      invested != 0
                                          ? ("  " +
                                              (pandl > 0 ? "+" : "") +
                                              (pandl * 100 / invested)
                                                  .toStringAsFixed(2) +
                                              " %")
                                          : "",
                                      style: TextStyle(
                                        color: pandl > 0
                                            ? Colors.green
                                            : (pandl < 0
                                                ? Colors.red
                                                : Colors.black),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            new Container(
                              height: 5,
                            )
                          ],
                        ),
                      ),
                      onPressed: () {},
                    ),
                    new Container(
                      height: 20,
                    ),
                    new Expanded(
                      child: new SmartRefresher(
                              onRefresh: _onRefresh,
                              controller: _refreshController,
                        child: new ListView.separated(
                        itemCount: positions.length,
                        separatorBuilder: (context, i) {
                          return new Divider();
                        },
                        itemBuilder: (itemContext, i) {
                          return new GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => new BuySellActivity(
                                       positions[i].ticker,
                                        positions[i].name,
                                        true)),
                              );
                            },
                            child: tickers[
                                        int.parse(positions[i].ticker)] !=
                                    null
                                ? new Container(
                                    color: Colors.transparent,
                                    width: width,
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Container(
                                              padding: EdgeInsets.all(3),
                                              child: new Row(
                                                children: <Widget>[
                                                  new Text(
                                                    positions[i]
                                                        .shares
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                  new Text(
                                                    " Qty.",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            new Text(
                                              (((tickers[int.parse(positions[i]
                                                                      .ticker)] *
                                                                  double.parse(positions[i]
                                                                          .shares)) -
                                                              double.parse(positions[i].invested)) *
                                                          100 /
                                                          double.parse(positions[i].invested))
                                                      .toStringAsFixed(2) +
                                                  " %",
                                              style: TextStyle(
                                                color: (tickers[int.parse(
                                                                positions[i]
                                                                    .ticker)] *
                                                            double.parse(positions[i].shares)) >
                                                        double.parse(positions[i]
                                                            .invested)
                                                    ? Colors.green
                                                    : ((tickers[int.parse(
                                                                    positions[i]
                                                                        .ticker)] *
                                                                double.parse(positions[i]
                                                                        .shares)) <
                                                            double.parse(positions[i].invested)
                                                        ? Colors.red
                                                        : Colors.black),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Container(
                                          height: 5,
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              positions[i].name,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            new Text(
                                              ((tickers[int.parse(positions[i]
                                                              .ticker)] *
                                                          double.parse(positions[i]
                                                              .shares)) -
                                                      double.parse(positions[i]
                                                          .invested))
                                                  .toStringAsFixed(2),
                                              style: TextStyle(
                                                  color: (tickers[int.parse(
                                                                  positions[i]
                                                                      .ticker)] *
                                                              double.parse(positions[i].shares)) >
                                                          double.parse(positions[i].invested)
                                                      ? Colors.green
                                                      : ((tickers[int.parse(positions[i].ticker)] *
                                                                  double.parse(positions[i]
                                                                          .shares)) <
                                                              double.parse(positions[i].invested)
                                                          ? Colors.red
                                                          : Colors.black)),
                                            ),
                                          ],
                                        ),
                                        new Container(
                                          height: 10,
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Row(
                                              children: <Widget>[
                                                new Text(
                                                  "Invested ",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                new Text(
                                                  double.parse(positions[i].invested)
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            ),
                                            new Row(
                                              children: <Widget>[
                                                new Text(
                                                  "LTP ",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                new Text( 
                                                  tickers[int.parse(positions[i]
                                                          .ticker)]
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                : new Container(),
                          );
                        },
                      ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
