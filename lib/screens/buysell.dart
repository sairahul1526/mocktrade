import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:slider_button/slider_button.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';

import './alert.dart';
import '../utils/models.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class BuySellActivity extends StatefulWidget {
  final String id;
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

  List<Ticker> tickerBuySellList = new List();

  String requiredAmount = "";
  String id;
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

    accountsapi();

    List<String> ids = new List();

    marketwatch.forEach((f) => ids.add(f.instrumentToken));
    fillDataAPI("https://api.kite.trade/quote?", [id]).then((resp) {
      if (resp["data"][id] != null) {
        lastTradedPrice = resp["data"][id]["last_price"].toDouble();
        lastTradedQuantity = resp["data"][id]["last_quantity"].toDouble();
        averageTradedPrice = resp["data"][id]["average_price"].toDouble();
        volumeTraded = resp["data"][id]["volume"].toDouble();
        totalBuyQuantity = resp["data"][id]["buy_quantity"].toDouble();
        totalSellQuantity = resp["data"][id]["sell_quantity"].toDouble();
        openPrice = resp["data"][id]["ohlc"]["open"].toDouble();
        highPrice = resp["data"][id]["ohlc"]["high"].toDouble();
        lowPrice = resp["data"][id]["ohlc"]["low"].toDouble();
        closePrice = resp["data"][id]["ohlc"]["close"].toDouble();
      }
      shares.text = tickerMap[id].lotSize;
      Map<String, dynamic> message = {
        "a": "mode",
        "v": [
          "quote",
          [int.parse(id)]
        ]
      };
      channel.sink.add(jsonEncode(message));
    });
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
                amount = double.parse(response.accounts[0].amount);
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
            setState(() {
              loading = true;
            });
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
              var price = lastTradedPrice;
              var invested = double.parse(shares.text) * price;
              checkInternet().then((internet) {
                if (internet == null || !internet) {
                  closeActivity("Rejected", "No Internet connection", false);
                } else {
                  Future<dynamic> load = addGetResponse(API.BUYSELL, {
                    "user_id": userID,
                    "ticker": id.toString(),
                    "name": tickerMap[id].tradingSymbol,
                    "exchange": tickerMap[id].segment,
                    "shares": int.parse(shares.text).toString(),
                    "price": price.toStringAsFixed(2),
                    "invested": invested.toStringAsFixed(2),
                    "type": sell ? "0" : "1",
                    "expiry": tickerMap[id].expiry,
                  });
                  load.then((response) {
                    if (response != null) {
                      if (response["meta"]["status"] == "200" ||
                          response["meta"]["status"] == "201") {
                        orders.insert(
                            0,
                            new Order(
                                userID: userID,
                                ticker: id.toString(),
                                name: tickerMap[id].tradingSymbol,
                                exchange: tickerMap[id].segment,
                                shares: int.parse(shares.text).toString(),
                                price: price.toString(),
                                invested: invested.toStringAsFixed(2),
                                type: sell ? "0" : "1",
                                createdDateTime: DateTime.now().toString()));
                        if (positionsMap[id.toString()] != null) {
                          var positionInvested =
                              positionsMap[id.toString()].invested;
                          var positionShares =
                              positionsMap[id.toString()].shares;
                          for (var i = 0; i < positions.length; i++) {
                            if (positions[i].ticker == id.toString()) {
                              positions[i].invested =
                                  (double.parse(positionInvested) +
                                          (sell ? -invested : invested))
                                      .toStringAsFixed(2);
                              positions[i].shares = (int.parse(positionShares) +
                                      (sell
                                          ? -int.parse(shares.text)
                                          : int.parse(shares.text)))
                                  .toString();
                              break;
                            }
                          }
                          positionsMap[id.toString()].invested =
                              (double.parse(positionInvested) +
                                      (sell
                                          ? -(double.parse(shares.text) *
                                              lastTradedPrice)
                                          : (double.parse(shares.text) *
                                              lastTradedPrice)))
                                  .toStringAsFixed(2);
                          positionsMap[id.toString()].shares =
                              (int.parse(positionShares) +
                                      (sell
                                          ? -int.parse(shares.text)
                                          : int.parse(shares.text)))
                                  .toString();
                        } else {
                          positions.insert(
                              0,
                              new Position(
                                userID: userID,
                                ticker: id.toString(),
                                name: symbol,
                                invested: (double.parse(shares.text) *
                                        lastTradedPrice)
                                    .toString(),
                                shares: int.parse(shares.text).toString(),
                                status: "1",
                                expiry: tickerMap[id].expiry,
                              ));
                          positionsMap[id.toString()] = new Position(
                            userID: userID,
                            ticker: id.toString(),
                            name: symbol,
                            invested:
                                (double.parse(shares.text) * lastTradedPrice)
                                    .toString(),
                            shares: int.parse(shares.text).toString(),
                            status: "1",
                            expiry: tickerMap[id].expiry,
                          );
                        }
                        if (positionsMap[id.toString()].shares == "0") {
                          for (var i = 0; i < positions.length; i++) {
                            if (positions[i].ticker == id.toString()) {
                              positions.removeAt(i);
                              break;
                            }
                          }
                          positionsMap[id.toString()] = null;
                        }
                        closeActivity(
                            "Completed", response["meta"]["message"], true);
                      } else {
                        closeActivity(
                            "Rejected", response["meta"]["message"], false);
                      }
                    } else {
                      closeActivity("Rejected", "Order not placed", false);
                    }
                  });
                }
              });
            } else {
              closeActivity("Rejected", "Order not placed", false);
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
                if (requiredAmount.length == 0 && lastTradedPrice != null) {
                  requiredAmount =
                      (lastTradedPrice * int.parse(shares.text)).toString();
                }
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
                                ? positionsMap[id.toString()].shares
                                : "")
                            : amount.toString()) +
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
                            if (text.length > 0 && lastTradedPrice != null) {
                              setState(() {
                                requiredAmount =
                                    (lastTradedPrice * int.parse(shares.text))
                                        .toStringAsFixed(2);
                              });
                            } else {
                              setState(() {
                                requiredAmount = "0";
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
                        requiredAmount,
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
