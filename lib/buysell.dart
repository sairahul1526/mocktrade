import 'package:flutter/material.dart';

import './models.dart';

import 'package:web_socket_channel/io.dart';
import 'dart:convert';

import './config.dart';
import './utils.dart';

class BuySellActivity extends StatefulWidget {
  final int id;
  final String symbol;
  final bool sell;

  BuySellActivity(this.id, this.symbol, this.sell);

  @override
  BuySellActivityState createState() {
    return new BuySellActivityState(this.id, this.symbol, this.sell);
  }
}

class BuySellActivityState extends State<BuySellActivity> {
  double width = 0;

  TextEditingController shares = new TextEditingController();

  String amount = "";

  List<Ticker> tickerBuySellList = new List();

  int id;
  String symbol;
  bool sell;
  Map<int, double> tickers = new Map();

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);

  BuySellActivityState(this.id, this.symbol, this.sell);
  @override
  void initState() {
    super.initState();

    Map<String, dynamic> message = {
      "a": "mode",
      "v": [
        "ltp",
        [id]
      ]
    };
    channel.sink.add(jsonEncode(message));
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

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          new Center(
            child: new Text(
              "BUY",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          new Switch(
            value: sell,
            onChanged: (value) {
              setState(() {
                sell = value;
              });
            },
            activeColor: Colors.red,
            inactiveTrackColor: Colors.lightGreen,
            inactiveThumbColor: Colors.green,
          ),
          new Center(
            child: new Text(
              "SELL",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          new Container(
            width: 10,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (shares.text.length > 0 && shares.text != "0") {}
        },
        child: Icon(Icons.done),
        backgroundColor: sell ? Colors.red : Colors.green,
      ),
      body: new Container(
        padding: EdgeInsets.all(15),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(
              (sell ? "Sell" : "Buy") + " " + symbol,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            new Container(
              height: 8,
            ),
            new Text(
              "#120 available",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            new Container(
              height: 25,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  "Number of Shares",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                new Container(
                  width: width * 0.25,
                  child: new TextField(
                    onChanged: (text) {
                      if (text.length > 0) {
                        setState(() {
                          amount = text;
                        });
                      } else {
                        setState(() {
                          amount = "";
                        });
                      }
                    },
                    controller: shares,
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
                )
              ],
            ),
            new Container(
              height: 10,
            ),
            new Divider(),
            new Container(
              height: 10,
            ),
            new StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  splitdata(snapshot.data);
                }
                return new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                      "Estimated " + (sell ? "Credit" : "Cost"),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    new Text(
                      "#" +
                          (shares.text.length > 0
                              ? (tickers[id] * int.parse(shares.text))
                                  .toStringAsFixed(2)
                              : ""),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
