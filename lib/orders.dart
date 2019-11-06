import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mocktrade/buysell.dart';
import 'package:mocktrade/search.dart';

import 'dart:convert';
import 'package:web_socket_channel/io.dart';

import './config.dart';
import './models.dart';
import './utils.dart';

class OrdersActivity extends StatefulWidget {
  @override
  OrdersActivityState createState() {
    return new OrdersActivityState();
  }
}

class OrdersActivityState extends State<OrdersActivity>
    with AutomaticKeepAliveClientMixin<OrdersActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;

  List<DocumentSnapshot> orders = new List();

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("marketwatch")
        .document(phone)
        .collection("orders")
        .orderBy("time", descending: true)
        .snapshots()
        .listen((data) {
      orders.clear();
      data.documents.forEach((doc) {
        orders.add(doc);
      });
      setState(() {
        orders = orders;
      });
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
          "Orders",
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
                new Expanded(
                  child: new ListView.separated(
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
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: new Column(
                            children: <Widget>[
                              new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    padding: EdgeInsets.all(3),
                                    color: orders[i]["type"] == 0
                                        ? HexColor("#e1d0d1")
                                        : HexColor("#cfd6e1"),
                                    child: new Text(
                                        orders[i]["type"] == 0 ? "SELL" : "BUY",
                                        style: TextStyle(
                                            color: orders[i]["type"] == 0
                                                ? Colors.red
                                                : Colors.blue)),
                                  ),
                                  new Text(
                                    headingDateFormat.format(
                                        new DateTime.fromMillisecondsSinceEpoch(
                                            orders[i]["time"])),
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
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    tickerMap[orders[i]["id"]]
                                        .tradingSymbol
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  new Text(orders[i]["shares"].toString() +
                                      " X " +
                                      orders[i]["price"].toStringAsFixed(2)),
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
                                    tickerMap[orders[i]["id"]].segment,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  new Text(
                                    (orders[i]["price"] * orders[i]["shares"])
                                        .toStringAsFixed(2),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
