import 'package:flutter/material.dart';
import 'package:mocktrade/screens/reorder.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:mocktrade/utils/models.dart';
import 'package:web_socket_channel/io.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';
import "dart:math";

import './buysell.dart';
import './search.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class WatchlistsActivity extends StatefulWidget {
  @override
  WatchlistsActivityState createState() {
    return new WatchlistsActivityState();
  }
}

class WatchlistsActivityState extends State<WatchlistsActivity>
    with AutomaticKeepAliveClientMixin<WatchlistsActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Map<String, double> tickers = new Map();

  final random = new Random();

  IOWebSocketChannel channel;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    accountsapi();
    tickerlastapi();
  }

  void tickerlastapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            tickerlastapi();
          }
        });
        _refreshController.refreshCompleted();
      } else {
        Future<TickerLasts> data = getTickerClose({});
        data.then((response) {
          if (response != null) {
            if (response.tickerLasts != null &&
                response.tickerLasts.length > 0) {
              response.tickerLasts.forEach((d) {
                List<String> temp = d.value.split(":");
                // print(temp);
                if (temp.length > 1) {
                  // if (tickers[d.key] == null) {
                  //   tickers[d.key] = double.parse(temp[0]);
                  // }
                  closes[d.key] = double.parse(temp[1]);
                }
              });
            } else {
              new Timer(const Duration(milliseconds: retry), () {
                setState(() {
                  tickerlastapi();
                });
              });
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                tickerlastapi();
              });
            });
          }
        });
      }
    });
  }

  void _onRefresh() async {
    accountsapi();
    tickerlastapi();
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
        _refreshController.refreshCompleted();
      } else {
        Future<Accounts> data = getAccounts({"user_id": userID});
        data.then((response) {
          if (response != null) {
            _refreshController.refreshCompleted();
            if (response.accounts != null) {
              if (response.accounts.length > 0) {
                prefs.setString("email", response.accounts[0].email);
                amount = double.parse(response.accounts[0].amount);
                marketwatch.clear();
                response.accounts[0].watchlist.split(",").forEach((id) {
                  if (tickerMap[id] != null) {
                    marketwatch.add(tickerMap[id]);
                  }
                });
                setState(() {
                  marketwatch = marketwatch;
                });
                positionsapi();
              }
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                accountsapi();
              });
            });
          }
        });
      }
    });
  }

  takeName() async {
    TextEditingController name = new TextEditingController();
    await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return new _SystemPadding(
            child: new AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      controller: name,
                      autofocus: true,
                      decoration: new InputDecoration(
                          labelText: 'Your Name', hintText: 'eg. John Smith'),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    child: const Text('DONE'),
                    onPressed: () {
                      if (name.text.length > 0) {
                        checkInternet().then((internet) {
                          if (internet == null || !internet) {
                            Future<bool> dialog = retryDialog(
                                context, "No Internet connection", "");
                            dialog.then((onValue) {
                              if (onValue) {
                                takeName();
                              }
                            });
                          } else {
                            Future<bool> load = add(
                                API.ACCOUNT,
                                Map.from({
                                  "user_id": userID,
                                  "name": name.text,
                                }));
                            load.then((onValue) {
                              if (onValue != null) {
                                prefs.setString("name", name.text);
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        });
                      }
                    })
              ],
            ),
          );
        });
  }

  void positionsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                positionsapi();
              });
            });
          }
        });
      } else {
        Future<Positions> data = getPositions({"user_id": userID});
        data.then((response) {
          if (response != null) {
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
              getData();
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                positionsapi();
              });
            });
          }
        });
      }
    });
  }

  void splitdata(String data) {
    List<String> stocks = data.split("#");
    List<String> temp;
    stocks.forEach((stock) {
      temp = stock.split(":");
      if (temp.length == 2) {
        tickers[temp[0]] = double.parse(temp[1]);
      }
    });
    streamController.add(tickers);
  }

  getData() {
    if (channel != null) {
      channel.sink.close();
    }
    channel = null;
    Map<String, bool> ids = new Map();
    marketwatch.forEach((f) {
      ids[f.instrumentToken] = true;
    });
    positions.forEach((p) {
      ids[p.ticker] = true;
    });
    if (ids.length > 0) {
      channel = IOWebSocketChannel.connect(
          "ws://" + API.URL + "/realtime?tickers=" + ids.keys.join(","));

      channel.stream.listen(
        (message) {
          // print(message);
          if (message != null && message != "1") {
            channelStreamController.add(message);
          }
        },
        onDone: () {
          new Timer(Duration(seconds: random.nextInt(3)), () {
            // getData();
          });
        },
        onError: (error) {
          new Timer(Duration(seconds: random.nextInt(3)), () {
            getData();
          });
        },
      );
    }
  }

  searchPage(BuildContext context, Widget page) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ) as String;
    if (data != null && data.length > 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(data),
        duration: Duration(seconds: 3),
      ));
    }
    getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      key: _scaffoldKey,
      body: new Container(
        child: new SafeArea(
          child: new Container(
            padding: EdgeInsets.all(20),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                  "MarketWatch",
                  style: TextStyle(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                ),
                new Container(
                  height: 20,
                ),
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
                    padding: EdgeInsets.fromLTRB(0, 13, 0, 13),
                    child: new Row(
                      children: <Widget>[
                        new Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        new Container(
                          width: 10,
                        ),
                        new Expanded(
                          child: new Text(
                            "Search & add",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        new Text(
                          marketwatch.length.toString() +
                              "/" +
                              maxWatchList.toString(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                  onPressed: () {
                    searchPage(context, new SearchActivity());
                  },
                ),
                new Container(
                  height: 20,
                ),
                channelStreamController != null
                    ? new StreamBuilder(
                        stream: channelStreamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            splitdata(snapshot.data);
                          }
                          return new Expanded(
                            child: marketwatch.length == 0
                                ? new SmartRefresher(
                                    onRefresh: _onRefresh,
                                    controller: _refreshController,
                                    child: new Center(
                                      child: new Text(
                                        "Use the search bar at the top to add some instruments",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : new SmartRefresher(
                                    onRefresh: _onRefresh,
                                    controller: _refreshController,
                                    child: new ListView.separated(
                                      itemCount: marketwatch.length,
                                      separatorBuilder: (context, i) {
                                        return marketwatch[i] == null
                                            ? new Container()
                                            : new Divider();
                                      },
                                      itemBuilder: (itemContext, i) {
                                        return marketwatch[i] == null
                                            ? new Container()
                                            : new GestureDetector(
                                                onLongPress: () {
                                                  searchPage(context,
                                                      new ReordersActivity());
                                                },
                                                onTap: () {
                                                  if (marketwatch[i].segment !=
                                                      "INDICES") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              new BuySellActivity(
                                                                  marketwatch[i]
                                                                      .instrumentToken,
                                                                  marketwatch[i]
                                                                      .tradingSymbol,
                                                                  false)),
                                                    );
                                                  }
                                                },
                                                child: new Container(
                                                  color: Colors.transparent,
                                                  width: width,
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 10, 0, 10),
                                                  child: new Column(
                                                    children: <Widget>[
                                                      new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          new Expanded(
                                                            child: new Text(
                                                              marketwatch[i]
                                                                  .tradingSymbol,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          new Row(
                                                            children: <Widget>[
                                                              new Text(
                                                                tickers[marketwatch[i].instrumentToken] ==
                                                                            null ||
                                                                        closes[marketwatch[i].instrumentToken] ==
                                                                            null
                                                                    ? ""
                                                                    : tickers[marketwatch[i]
                                                                            .instrumentToken]
                                                                        .toStringAsFixed(
                                                                            2),
                                                                style:
                                                                    TextStyle(
                                                                  color: tickers[marketwatch[i].instrumentToken] ==
                                                                              null ||
                                                                          closes[marketwatch[i].instrumentToken] ==
                                                                              null
                                                                      ? Colors
                                                                          .black
                                                                      : tickers[marketwatch[i].instrumentToken] - closes[marketwatch[i].instrumentToken] > 0
                                                                          ? Colors
                                                                              .green
                                                                          : Colors
                                                                              .red,
                                                                ),
                                                              )
                                                            ],
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
                                                          new Row(
                                                            children: <Widget>[
                                                              new Text(
                                                                marketwatch[i]
                                                                    .segment,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              new Container(
                                                                width: 10,
                                                              ),
                                                              positionsMap[marketwatch[
                                                                              i]
                                                                          .instrumentToken] !=
                                                                      null
                                                                  ? new Icon(
                                                                      Icons
                                                                          .card_travel,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 15,
                                                                    )
                                                                  : new Container(),
                                                              new Container(
                                                                width: 10,
                                                              ),
                                                              positionsMap[marketwatch[
                                                                              i]
                                                                          .instrumentToken] !=
                                                                      null
                                                                  ? new Text(
                                                                      positionsMap[marketwatch[i]
                                                                              .instrumentToken]
                                                                          .shares
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            12,
                                                                      ))
                                                                  : new Container()
                                                            ],
                                                          ),
                                                          new Row(
                                                            children: <Widget>[
                                                              new Text(
                                                                tickers[marketwatch[i].instrumentToken] ==
                                                                            null ||
                                                                        closes[marketwatch[i].instrumentToken] ==
                                                                            null
                                                                    ? ""
                                                                    : (tickers[marketwatch[i].instrumentToken] - closes[marketwatch[i].instrumentToken]).toStringAsFixed(
                                                                            2) +
                                                                        " (" +
                                                                        ((tickers[marketwatch[i].instrumentToken] - closes[marketwatch[i].instrumentToken]) *
                                                                                100 /
                                                                                closes[marketwatch[i].instrumentToken])
                                                                            .toStringAsFixed(2) +
                                                                        "%)",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 12,
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                      },
                                    ),
                                  ),
                          );
                        },
                      )
                    : new Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
        duration: const Duration(milliseconds: 300), child: child);
  }
}
