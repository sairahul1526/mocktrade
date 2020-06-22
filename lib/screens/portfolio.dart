import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';

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

  Map<String, double> tickers = new Map();

  double pandl = 0;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
        Future<Accounts> data = getAccounts({"user_id": userID});
        data.then((response) {
          if (response != null) {
            if (response.accounts != null) {
              if (response.accounts.length > 0) {
                if (!mounted) return;
                setState(() {
                  amount = double.parse(response.accounts[0].amount);
                });
              }
              positionsapi();
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              if (!mounted) return;
              setState(() {
                accountsapi();
              });
            });
          }
        });
      }
    });
  }

  void positionsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            positionsapi();
          }
        });
        _refreshController.refreshCompleted();
      } else {
        Future<Positions> data = getPositions({"user_id": userID});
        data.then((response) {
          if (response != null) {
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
              if (!mounted) return;
              setState(() {
                positionsMap = positionsMap;
                positions = positions;
                invested = 0;
                current = 0;
                pandl = 0;
              });
              _refreshController.refreshCompleted();
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              if (!mounted) return;
              setState(() {
                positionsapi();
              });
            });
          }
        });
      }
    });
  }

  void _onRefresh() async {
    accountsapi();
  }

  void splitdata(Map<String, double> data) {
    data.forEach((key, value) {
      tickers[key] = value;
    });
    invested = 0;
    current = 0;
    pandl = 0;
    for (var position in positions) {
      if (tickers[position.ticker] != null) {
        invested += double.parse(position.invested);
        current += tickers[position.ticker] * double.parse(position.shares);
      }

      pandl = current - invested;
    }
  }

  buySellPage(BuildContext context, Widget page) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ) as String;
    accountsapi();
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
            child: streamController != null
                ? new StreamBuilder(
                    stream: streamController.stream,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                          positions.length == 0
                              ? new Expanded(
                                  child: new SmartRefresher(
                                    onRefresh: _onRefresh,
                                    controller: _refreshController,
                                    child: new Center(
                                      child: new Text(
                                        "You don't have any positions yet",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              : new Expanded(
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
                                            if (tickerMap[
                                                    positions[i].ticker] !=
                                                null) {
                                              buySellPage(
                                                context,
                                                new BuySellActivity(
                                                    positions[i].ticker,
                                                    positions[i].name,
                                                    true),
                                              );
                                            }
                                          },
                                          child:
                                              tickers[positions[i].ticker] !=
                                                      null
                                                  ? new Container(
                                                      color: Colors.transparent,
                                                      width: width,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 10, 0, 10),
                                                      child: new Column(
                                                        children: <Widget>[
                                                          new Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <Widget>[
                                                              new Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(3),
                                                                child: new Row(
                                                                  children: <
                                                                      Widget>[
                                                                    new Text(
                                                                      positions[
                                                                              i]
                                                                          .shares
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    new Text(
                                                                      " Qty.",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              new Text(
                                                                (((tickers[positions[i].ticker] * double.parse(positions[i].shares)) - double.parse(positions[i].invested)) *
                                                                            100 /
                                                                            double.parse(positions[i]
                                                                                .invested))
                                                                        .toStringAsFixed(
                                                                            2) +
                                                                    " %",
                                                                style:
                                                                    TextStyle(
                                                                  color: (tickers[positions[i].ticker] *
                                                                              double.parse(positions[i]
                                                                                  .shares)) >
                                                                          double.parse(positions[i]
                                                                              .invested)
                                                                      ? Colors
                                                                          .green
                                                                      : ((tickers[positions[i].ticker] * double.parse(positions[i].shares)) <
                                                                              double.parse(positions[i]
                                                                                  .invested)
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .black),
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
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <Widget>[
                                                              new Expanded(
                                                                child: new Text(
                                                                  positions[i]
                                                                      .name,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ),
                                                              new Row(
                                                                children: <
                                                                    Widget>[
                                                                  new Text(
                                                                    ((tickers[positions[i].ticker] * double.parse(positions[i].shares)) -
                                                                            double.parse(positions[i]
                                                                                .invested))
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    style: TextStyle(
                                                                        color: (tickers[positions[i].ticker] * double.parse(positions[i].shares)) > double.parse(positions[i].invested)
                                                                            ? Colors
                                                                                .green
                                                                            : ((tickers[positions[i].ticker] * double.parse(positions[i].shares)) < double.parse(positions[i].invested)
                                                                                ? Colors.red
                                                                                : Colors.black)),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          new Container(
                                                            height: 10,
                                                          ),
                                                          new Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <Widget>[
                                                              new Row(
                                                                children: <
                                                                    Widget>[
                                                                  new Text(
                                                                    "Invested ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    double.parse(positions[i]
                                                                            .invested)
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              new Row(
                                                                children: <
                                                                    Widget>[
                                                                  new Text(
                                                                    "LTP ",
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  new Text(
                                                                    tickers[positions[i]
                                                                            .ticker]
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          12,
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
                  )
                : new Container(),
          ),
        ),
      ),
    );
  }
}
