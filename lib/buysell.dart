import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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

  bool loading = false;

  double lastTradedPrice;
  double lastTradedQuantity;
  double averageTradedPrice;
  double volumeTraded;
  double totalBuyQuantity;
  double totalSellQuantity;
  double openPrice;
  double highPrice;
  double lowPrice;
  double closePrice;

  final globalKey = GlobalKey<ScaffoldState>(); 

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);

  BuySellActivityState(this.id, this.symbol, this.sell);
  @override
  void initState() {
    super.initState();

    Map<String, dynamic> message = {
      "a": "mode",
      "v": [
        "quote",
        [id]
      ]
    };
    channel.sink.add(jsonEncode(message));
  }

  void splitdata(List<int> data) {
    if (data.length < 2) {
      return;
    }

    // setState(() {
    lastTradedPrice = converttoint(data.getRange(8, 12)).toDouble() / 100;
    lastTradedQuantity = converttoint(data.getRange(12, 16)).toDouble();
    averageTradedPrice = converttoint(data.getRange(16, 20)).toDouble() / 100;
    volumeTraded = converttoint(data.getRange(20, 24)).toDouble();
    totalBuyQuantity = converttoint(data.getRange(24, 28)).toDouble();
    totalSellQuantity = converttoint(data.getRange(28, 32)).toDouble();
    openPrice = converttoint(data.getRange(32, 36)).toDouble() / 100;
    highPrice = converttoint(data.getRange(36, 40)).toDouble() / 100;
    lowPrice = converttoint(data.getRange(40, 44)).toDouble() / 100;
    closePrice = converttoint(data.getRange(44, 48)).toDouble() / 100;
    // });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      key: globalKey,
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: new Align(
        alignment: Alignment.bottomCenter,
        child: new FloatingActionButton(
          onPressed: () {
            if (shares.text.length > 0 &&
                shares.text != "0" &&
                lastTradedPrice != 0) {
              if (int.parse(shares.text) % int.parse(tickerMap[id].lotSize) !=
                  0) {
                globalKey.currentState.showSnackBar(new SnackBar(
                  backgroundColor: Colors.red,
                  content: new Text("Quantity has to be multiple of lot size " +
                      tickerMap[id].lotSize),
                ));
                return;
              }
              setState(() {
                loading = true;
              });
              Firestore.instance
                  .collection("marketwatch")
                  .document(phone)
                  .collection("orders")
                  .add({
                "id": id,
                "shares": int.parse(shares.text),
                "price": lastTradedPrice,
                "type": sell ? 0 : 1,
                "time": DateTime.now().millisecondsSinceEpoch,
              }).then((onValue) {
                Navigator.of(context).pop();
              });
            }
          },
          child: Icon(Icons.done),
          backgroundColor: sell ? Colors.red : Colors.green,
        ),
      ),
      body: new ModalProgressHUD(
        inAsyncCall: loading,
        child: new Container(
          padding: EdgeInsets.all(15),
          child: new StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                splitdata(snapshot.data);
              }
              return new ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
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
                  closePrice != null
                      ? new Text(
                          lastTradedPrice.toString() +
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
                    height: 8,
                  ),
                  new Text(
                    "120 available",
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
                          autofocus: true,
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
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        "Estimated " + (sell ? "Credit" : "Cost"),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      new Text(
                        (shares.text.length > 0 && lastTradedPrice != null
                            ? (lastTradedPrice * int.parse(shares.text))
                                .toStringAsFixed(2)
                            : "0"),
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  new Divider(),
                  new Container(
                    height: 30,
                  ),
                  openPrice != null
                      ? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            new Column(
                              children: <Widget>[
                                new Text(
                                  openPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 5,
                                ),
                                new Text(
                                  "Open",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                            new Column(
                              children: <Widget>[
                                new Text(
                                  highPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "High",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      : new Container(),
                  new Container(
                    height: 20,
                  ),
                  lowPrice != null
                      ? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            new Column(
                              children: <Widget>[
                                new Text(
                                  lowPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Low",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                            new Column(
                              children: <Widget>[
                                new Text(
                                  closePrice.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Close",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      : new Container(),
                  new Container(
                    height: 20,
                  ),
                  volumeTraded != null
                      ? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            new Column(
                              children: <Widget>[
                                new Text(
                                  volumeTraded.round().toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Volume",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                            new Column(
                              children: <Widget>[
                                new Text(
                                  averageTradedPrice.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Avg. Price",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      : new Container(),
                  new Container(
                    height: 20,
                  ),
                  totalBuyQuantity != null
                      ? new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            new Column(
                              children: <Widget>[
                                new Text(
                                  totalBuyQuantity.round().toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Total Buy",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                            new Column(
                              children: <Widget>[
                                new Text(
                                  totalSellQuantity.round().toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                new Container(
                                  height: 4,
                                ),
                                new Text(
                                  "Total Sell",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      : new Container()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
