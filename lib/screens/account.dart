import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

import '../main.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class AccountActivity extends StatefulWidget {
  @override
  AccountActivityState createState() {
    return new AccountActivityState();
  }
}

class AccountActivityState extends State<AccountActivity>
    with AutomaticKeepAliveClientMixin<AccountActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;
  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "wss://ws.kite.trade?api_key=" + apiKey + "&access_token=" + accessToken);
  Map<int, double> tickers = new Map();

  List<DocumentSnapshot> positions = new List();
  double amount = 0;

  double invested;
  double current;

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("amount")
        .snapshots()
        .listen((data) {
      data.documents.forEach((doc) {
        setState(() {
          amount = doc.data["total"] + .0;
        });
      });
    });

    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("positions")
        .snapshots()
        .listen((data) {
      positions.clear();
      data.documents.forEach((doc) {
        positions.add(doc);
      });
      getData();
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

    invested = 0;
    current = 0;
    for (var position in positions) {
      if (tickers[int.parse(position.documentID)] != null) {
        invested += position.data["invested"];
        current +=
            tickers[int.parse(position.documentID)] * position.data["shares"];
      }
    }
  }

  getData() {
    List<int> ids = new List();

    positions.forEach((f) => ids.add(int.parse(f.documentID)));
    Map<String, dynamic> message = {
      "a": "mode",
      "v": ["ltp", ids]
    };
    channel.sink.add(jsonEncode(message));
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
          "Account",
          style: TextStyle(
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
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && positions.length > 0) {
                        splitdata(snapshot.data);
                      }
                      return new RaisedButton(
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
                                      ? (current + amount).toStringAsFixed(2)
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
                                                          (invested + amount))
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
                                              MainAxisAlignment.spaceBetween,
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
                                                  ? invested.toStringAsFixed(2)
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
                                              MainAxisAlignment.spaceBetween,
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
                      );
                    }),
                new Container(
                  height: 20,
                ),
                new GestureDetector(
                  onTap: () {
                    prefs.clear();
                    phone = "";
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (BuildContext context) => new MyHomePage()));
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(20),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Logout "),
                        new Icon(Icons.exit_to_app)
                      ],
                    ),
                  ),
                ),
                new Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
