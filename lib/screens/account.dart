import 'package:flutter/material.dart';
import 'package:mocktrade/screens/funds.dart';
import 'package:mocktrade/screens/history.dart';
import 'package:mocktrade/screens/login.dart';
import 'package:mocktrade/screens/performance.dart';
import 'package:share/share.dart';
import 'package:launch_review/launch_review.dart';
import 'dart:io' show Platform;

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

  loginPage(BuildContext context, Widget page) async {
    final data = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ) as String;
    if (data != null && data.length > 0) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new MyHomePage()));
    }
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
            child: new ListView(
              children: <Widget>[
                new Container(
                  height: 20,
                ),
                prefs.getString("phone") != null &&
                        prefs.getString("phone").length > 0
                    ? new Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(left: 15),
                        child: new Text(
                          prefs.getString("name"),
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : new GestureDetector(
                        onTap: () {
                          loginPage(context, new Login());
                        },
                        child: new Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.all(15),
                          child: new Text(
                            "Login",
                            style: TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                prefs.getString("phone") != null &&
                        prefs.getString("phone").length > 0
                    ? new Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                        child: new Text(
                          prefs.getString("phone"),
                          style: TextStyle(
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : new Container(),
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
                new Container(
                  height: 50,
                ),
                new Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(15),
                  child: new Text(
                    "Mock Trade",
                    style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
                new GestureDetector(
                  onTap: () {
                    Share.share(
                        'Practice trading with virtual funds and become a pro in stock markets using MockTrade app. Download now https://bit.ly/30iSFlM',
                        subject: "");
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Invite Friends"),
                        new Icon(Icons.person_add)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    sendMail(
                        supportEmail,
                        (Platform.isAndroid ? "Android" : "iOS") +
                            "%20Bug%20Report",
                        "\n\n\nVersion: " +
                            headers["appversion"] +
                            ", User: " +
                            userID);
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Report a Bug"),
                        new Icon(Icons.bug_report)
                      ],
                    ),
                  ),
                ),
                new Divider(),
                new GestureDetector(
                  onTap: () {
                    sendMail(
                        supportEmail,
                        (Platform.isAndroid ? "Android" : "iOS") + "%20Support",
                        "\n\n\nVersion: " +
                            headers["appversion"] +
                            ", User: " +
                            userID);
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
                    LaunchReview.launch(
                        androidAppId: "com.saikrishna.mocktrade",
                        iOSAppId: "585027354");
                  },
                  child: new Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(15),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text("Rate Us"),
                        new Icon(Icons.star)
                      ],
                    ),
                  ),
                ),
                new Container(
                  height: 100,
                ),
                prefs.getString("phone") != null &&
                        prefs.getString("phone").length > 0
                    ? new GestureDetector(
                        onTap: () {
                          prefs.clear();
                          userID = "";
                          Navigator.of(context).pushReplacement(
                              new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new MyHomePage()));
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
                      )
                    : new Container(),
                new Container(
                  child: new Center(
                    child: new Text(
                      "\n\n\nVersion: " +
                          headers["appversion"] +
                          ", User: " +
                          userID,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
