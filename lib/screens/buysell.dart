import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:slider_button/slider_button.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

import './alert.dart';
import '../utils/models.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

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
  double availableamount = 0;

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

  Widget buyselbutton;

  BuySellActivityState(this.id, this.symbol, this.sell);
  @override
  void initState() {
    super.initState();

    shares.text = tickerMap[id].lotSize;
    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("amount")
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          availableamount = doc.data["total"] + .0;
        });
      });
    });

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
  }

  void closeActivity(String title, String subtitle, bool success) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => new AlertActivity(title, subtitle, success)),
    );
  }

  Widget getbuyselbutton() {
    return new Align(
        alignment: Alignment.bottomCenter,
        child: new SliderButton(
          width: width * 0.65,
          height: 65,
          action: () {
            if (!isMarketOpen()) {
              closeActivity("Rejected",
                  "Order was placed outside of trading hours.", false);
              return;
            }
            if (shares.text.length > 0 &&
                shares.text != "0" &&
                lastTradedPrice != null &&
                lastTradedPrice != 0) {
              if (int.parse(shares.text) % int.parse(tickerMap[id].lotSize) !=
                  0) {
                closeActivity("Rejected",
                    "Quantity has to be multiple of lot size.", false);
                return;
              }
              if (sell) {
                if (positionsMap[id.toString()] == null) {
                  closeActivity(
                      "Rejected", "Shares not available to sell.", false);
                  return;
                }
                if (positionsMap[id.toString()].data["shares"] <
                    int.parse(shares.text)) {
                  setState(() {
                    buyselbutton = getbuyselbutton();
                  });
                  closeActivity(
                      "Rejected",
                      "Only " +
                          positionsMap[id.toString()]
                              .data["shares"]
                              .toString() +
                          " shares are available to sell",
                      false);
                  return;
                }
              } else {
                if (int.parse(shares.text) * lastTradedPrice >
                    availableamount) {
                  setState(() {
                    buyselbutton = getbuyselbutton();
                  });
                  closeActivity(
                      "Rejected",
                      "Only " +
                          "Amount Required " +
                          (int.parse(shares.text) * lastTradedPrice)
                              .toStringAsFixed(2),
                      false);
                  return;
                }
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
                Firestore.instance
                    .collection("marketwatch")
                    .document(phone)
                    .collection("amount")
                    .document("amount")
                    .setData({
                  "total": FieldValue.increment(sell
                      ? double.parse((int.parse(shares.text) * lastTradedPrice)
                          .toStringAsFixed(2))
                      : -double.parse((int.parse(shares.text) * lastTradedPrice)
                          .toStringAsFixed(2))),
                }, merge: true).then((onValue) {
                  if (sell &&
                      positionsMap[id.toString()].data["shares"] ==
                          int.parse(shares.text)) {
                    Firestore.instance
                        .collection("marketwatch")
                        .document(phone)
                        .collection("positions")
                        .document(id.toString())
                        .delete()
                        .then((onValue) {
                      closeActivity(
                          "Completed", "Order successfully placed", true);
                    });
                  } else {
                    Firestore.instance
                        .collection("marketwatch")
                        .document(phone)
                        .collection("positions")
                        .document(id.toString())
                        .setData({
                      "shares": FieldValue.increment(sell
                          ? -int.parse(shares.text)
                          : int.parse(shares.text)),
                      "invested": FieldValue.increment(sell
                          ? -double.parse(
                              (int.parse(shares.text) * lastTradedPrice)
                                  .toStringAsFixed(2))
                          : double.parse(
                              (int.parse(shares.text) * lastTradedPrice)
                                  .toStringAsFixed(2))),
                    }, merge: true).then((onValue) {
                      closeActivity(
                          "Completed", "Order successfully placed", true);
                    });
                  }
                });
              });
            }
          },
          label: new Text(
            sell ? "SELL            " : "BUY            ",
            style: new TextStyle(
              color: sell ? Colors.red : Colors.green,
              fontSize: 12,
            ),
          ),
          buttonColor: Colors.white,
          highlightedColor: Colors.white,
          baseColor: Colors.white,
          backgroundColor: sell ? Colors.red : Colors.green,
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
      buyselbutton = getbuyselbutton();
    });
    return new Scaffold(
      key: globalKey,
      appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          (positionsMap[id.toString()] != null)
              ? new IconButton(
                  onPressed: () {
                    setState(() {
                      sell = !sell;
                    });
                  },
                  icon: new Icon(Icons.swap_vert),
                )
              : new Container(),
        ],
      ),
      floatingActionButton: buyselbutton,
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
                    height: 8,
                  ),
                  new Text(
                    (sell
                            ? (positionsMap[id.toString()] != null
                                ? positionsMap[id.toString()]
                                    .data["shares"]
                                    .toString()
                                : "")
                            : availableamount.toStringAsFixed(2)) +
                        (sell ? " shares" : " amount") +
                        " available",
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
                                  openPrice.toStringAsFixed(2),
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
                                  highPrice.toStringAsFixed(2),
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
                                  lowPrice.toStringAsFixed(2),
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
                                  closePrice.toStringAsFixed(2),
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
                                  averageTradedPrice.toStringAsFixed(2),
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
                      : new Container(),
                  new Container(
                    height: 100,
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
