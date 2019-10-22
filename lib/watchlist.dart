import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'package:mocktrade/buysell.dart';
import 'package:mocktrade/search.dart';

import 'dart:convert';
import 'package:web_socket_channel/io.dart';

import './config.dart';
import './models.dart';
import './utils.dart';

class WatchlistsActivity extends StatefulWidget {
  @override
  WatchlistsActivityState createState() {
    return new WatchlistsActivityState();
  }
}

class WatchlistsActivityState extends State<WatchlistsActivity> {
  double width = 0;

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  @override
  void initState() {
    super.initState();

    getTickers().then((response) {
      LineSplitter ls = new LineSplitter();
      List<String> tickerDetails = new List();
      tickerList.clear();
      int i = 0;
      for (var line in ls.convert(response)) {
        i++;
        if (i == 1) {
          continue;
        }
        tickerDetails = line.split(",");
        tickerList.add(new Ticker(
            instrumentToken: tickerDetails[0],
            exchangeToken: tickerDetails[1],
            tradingSymbol: tickerDetails[2],
            name: tickerDetails[3],
            expiry: tickerDetails[5],
            strike: tickerDetails[6],
            tickSize: tickerDetails[7],
            lotSize: tickerDetails[8],
            instrumentType: tickerDetails[9],
            segment: tickerDetails[10],
            exchange: tickerDetails[11]));
      }
      print(tickerList.length);

      Firestore.instance
          .collection("marketwatch")
          .document(userID)
          .get()
          .then((DocumentSnapshot ds) {
        if (ds.data["tickers"] != null) {
          marketwatch.clear();
          (ds.data["tickers"] as List<dynamic>).forEach((id) {
            tickerList.forEach((ticker) {
              if (ticker.instrumentToken == id.toString()) {
                marketwatch.add(ticker);
                return;
              }
            });
          });
        }
        print(ds.data["tickers"]);
        setState(() {
          marketwatch = marketwatch;
        });
        getData();
      });
    });
  }

  Future<String> getTickers() async {
    final response =
        await http.get("https://api.kite.trade/instruments", headers: {
      "X-Kite-Version": "3",
      "Authorization": "token " + apiKey + ":" + accessToken + ""
    });

    return response.body;
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

  hostelsPage(BuildContext context, Widget page) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ) as String;

    print("getdata");
    getData();
  }

  @override
  Widget build(BuildContext context) {
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
                    height: 50,
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
                    hostelsPage(context, new SearchActivity());
                  },
                ),
                new Container(
                  height: 20,
                ),
                new StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      splitdata(snapshot.data);
                    }
                    return new Expanded(
                      child: new ListView.separated(
                        itemCount: marketwatch.length,
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
                                        int.parse(
                                            marketwatch[i].instrumentToken),
                                        marketwatch[i].tradingSymbol,
                                        false)),
                              );
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
                                      new Text(tickers[int.parse(marketwatch[i]
                                                  .instrumentToken)] !=
                                              null
                                          ? tickers[int.parse(marketwatch[i]
                                                  .instrumentToken)]
                                              .toString()
                                          : ""),
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
                                        marketwatch[i].exchange,
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
