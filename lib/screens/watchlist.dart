import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

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

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("tickers")
        .document("tickers")
        .snapshots()
        .listen((ds) {
      if (ds.data["tickers"] != null) {
        marketwatch.clear();
        (ds.data["tickers"] as List<dynamic>).forEach((id) {
          if (tickerMap[id] != null) {
            marketwatch.add(tickerMap[id]);
          }
        });
      }
      setState(() {
        marketwatch = marketwatch;
      });
      getData();
    });

    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("positions")
        .snapshots()
        .listen((data) {
      positionsMap.clear();
      data.documents.forEach((doc) {
        positionsMap[doc.documentID] = doc;
      });
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
  }

  getData() {
    List<int> ids = new List();

    marketwatch.forEach((f) => ids.add(int.parse(f.instrumentToken)));
    Map<String, dynamic> message = {
      "a": "mode",
      "v": ["ltp", ids]
    };
    channel.sink.add(jsonEncode(message));
  }

  searchPage(BuildContext context, Widget page) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ) as String;

    getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
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
                          tickers.length.toString() + "/100",
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
                new StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && marketwatch.length > 0) {
                      splitdata(snapshot.data);
                    }
                    return new Expanded(
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
                                  onTap: () {
                                    if (marketwatch[i].segment != "INDICES") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                new BuySellActivity(
                                                    int.parse(marketwatch[i]
                                                        .instrumentToken),
                                                    marketwatch[i]
                                                        .tradingSymbol,
                                                    false)),
                                      );
                                    }
                                  },
                                  child: new Container(
                                    color: Colors.transparent,
                                    width: width,
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              marketwatch[i].tradingSymbol,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            new Text(tickers[int.parse(
                                                        marketwatch[i]
                                                            .instrumentToken)] !=
                                                    null
                                                ? tickers[int.parse(
                                                        marketwatch[i]
                                                            .instrumentToken)]
                                                    .toStringAsFixed(2)
                                                : ""),
                                          ],
                                        ),
                                        new Container(
                                          height: 5,
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                              marketwatch[i].segment,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            new Container(
                                              width: 10,
                                            ),
                                            positionsMap[marketwatch[i]
                                                        .instrumentToken] !=
                                                    null
                                                ? new Icon(
                                                    Icons.card_travel,
                                                    color: Colors.grey,
                                                    size: 15,
                                                  )
                                                : new Container(),
                                            new Container(
                                              width: 10,
                                            ),
                                            positionsMap[marketwatch[i]
                                                        .instrumentToken] !=
                                                    null
                                                ? new Text(
                                                    positionsMap[marketwatch[i]
                                                            .instrumentToken]
                                                        .data["shares"]
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ))
                                                : new Container()
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
