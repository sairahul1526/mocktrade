import 'package:flutter/material.dart';
import 'package:mocktrade/screens/funds.dart';
import 'package:mocktrade/screens/history.dart';
import 'package:mocktrade/screens/performance.dart';

import '../main.dart';
import '../utils/config.dart';
import '../utils/utils.dart';

class AccountActivity extends StatefulWidget {
  @override
  AccountActivityState createState() {
    return new AccountActivityState();
  }
}

class AccountActivityState extends State<AccountActivity> {
  double width = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Settings",
          style: TextStyle(
            letterSpacing: 2,
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
                new Container(
                  height: 20,
                ),
                new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new FundsActivity()),
                    );
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Funds"),
                        new Icon(Icons.attach_money)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new HistoryActivity()),
                    );
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("History"),
                        new Icon(Icons.history)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => new PerformanceActivity()),
                    );
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Performance"),
                        new Icon(Icons.trending_up)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    launchURL("mailto:" +
                        supportEmail +
                        "?subject=MockTrade Support");
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Support"),
                        new Icon(Icons.mail)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    prefs.clear();
                    accessToken = "";
                    userID = "";
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(
                        builder: (BuildContext context) => new MyHomePage()));
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Logout"),
                        new Icon(Icons.power_settings_new)
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
