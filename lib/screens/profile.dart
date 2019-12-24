import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:mocktrade/utils/models.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../utils/config.dart';
import '../utils/utils.dart';

class ProfileActivity extends StatefulWidget {
  @override
  ProfileActivityState createState() {
    return new ProfileActivityState();
  }
}

class ProfileActivityState extends State<ProfileActivity>
    with AutomaticKeepAliveClientMixin<ProfileActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;
  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  ScrollController _controller;
  bool end = false;
  bool ongoing = false;
  String offset = defaultOffset;
  bool loading = true;

  List<Order> orders = new List();

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    orders.clear();
    ordersapi();
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
          fillData();
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

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (!end && !ongoing) {
        setState(() {
          loading = true;
        });
        ordersapi();
      }
    }
  }

  void ordersapi() {
    setState(() {
      loading = true;
      ongoing = true;
    });
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
        setState(() {
          ongoing = false;
          loading = false;
        });
      } else {
        Future<Orders> data = getOrders({
          "user_id": userID,
          "limit": defaultLimit,
          "offset": offset,
          "orderby": "created_date_time",
          "sortby": "desc",
          "status": "1",
        });
        data.then((response) {
          if (response.orders != null && response.orders.length > 0) {
            offset =
                (int.parse(response.pagination.offset) + response.orders.length)
                    .toString();
            response.orders.forEach((order) {
              orders.add(order);
            });
            setState(() {
              orders = orders;
            });
          } else {
            end = true;
          }
          if (response.meta != null && response.meta.messageType == "1") {
            oneButtonDialog(context, "", response.meta.message,
                !(response.meta.status == STATUS_403));
          }
          setState(() {
            ongoing = false;
            loading = false;
          });
        });
      }
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
          prefs != null && prefs.getString("name") != null
              ? prefs.getString("name")
              : "",
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
                                          ? (current + amount)
                                              .toStringAsFixed(2)
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
                                                              (invested +
                                                                  amount))
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      ? invested
                                                          .toStringAsFixed(2)
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                          new Container(
                            height: 20,
                          ),
                          new Expanded(
                            child: orders.length == 0
                                ? new Center(
                                    child: new Text(loading
                                        ? ""
                                        : "You haven't placed any orders"))
                                : new ListView.separated(
                                    controller: _controller,
                                    itemCount: orders.length,
                                    separatorBuilder: (context, i) {
                                      return new Divider();
                                    },
                                    itemBuilder: (itemContext, i) {
                                      return new GestureDetector(
                                        onTap: () {},
                                        child: new Container(
                                          color: Colors.transparent,
                                          width: width,
                                          padding:
                                              EdgeInsets.fromLTRB(0, 10, 0, 10),
                                          child: new Column(
                                            children: <Widget>[
                                              new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  new Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    padding: EdgeInsets.all(3),
                                                    color: orders[i].type == "0"
                                                        ? HexColor("#e1d0d1")
                                                        : HexColor("#cfd6e1"),
                                                    child: new Text(
                                                        orders[i].type == "0"
                                                            ? "SELL"
                                                            : "BUY",
                                                        style: TextStyle(
                                                            color: orders[i]
                                                                        .type ==
                                                                    "0"
                                                                ? Colors.red
                                                                : Colors.blue)),
                                                  ),
                                                  new Text(
                                                    headingDateFormat.format(
                                                        DateTime.parse(orders[i]
                                                            .createdDateTime)),
                                                    style: TextStyle(
                                                      color: Colors.grey,
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
                                                  new Text(
                                                    orders[i].name,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  new Text(orders[i].shares +
                                                      " X " +
                                                      orders[i].price),
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
                                                  new Text(
                                                    orders[i].exchange,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  new Text(
                                                    orders[i].invested,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          )
                        ],
                      );
                    }),
              ),
            ),
          )),
    );
  }
}
