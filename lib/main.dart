import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mocktrade/utils/api.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import './screens/dashboard.dart';
import './screens/login.dart';
import './utils/utils.dart';
import './utils/models.dart';
import './utils/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(new MaterialApp(
    title: "mocktrade",
    home: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mocktrade',
      home: MyHomePage(title: 'mocktrade'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loaded = false;
  bool shouldLogin = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      headers["appversion"] = APPVERSION.ANDROID;
      if (kReleaseMode) {
        headers["apikey"] = APIKEY.ANDROID_LIVE;
      } else {
        headers["apikey"] = APIKEY.ANDROID_TEST;
      }
    } else {
      headers["appversion"] = APPVERSION.IOS;
      if (kReleaseMode) {
        headers["apikey"] = APIKEY.IOS_LIVE;
      } else {
        headers["apikey"] = APIKEY.IOS_TEST;
      }
    }
    timingsapi();
  }

  void timingsapi() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            timingsapi();
          }
        });
      } else {
        Future<Timings> data =
            getTimings({"day": DateTime.now().weekday.toString()});
        data.then((response) {
          if (response.timings != null && response.timings.length > 0) {
            holiday = response.timings[0].holiday == "1";
            List<String> opening = response.timings[0].open.split(":");
            List<String> closing = response.timings[0].close.split(":");
            open = new DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                int.parse(opening[0]),
                int.parse(opening[1]),
                0,
                0,
                0);
            close = new DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                int.parse(closing[0]),
                int.parse(closing[1]),
                0,
                0,
                0);

            tickers();
          }
          if (response.meta != null && response.meta.messageType == "1") {
            oneButtonDialog(context, "", response.meta.message,
                !(response.meta.status == STATUS_403));
          }
        });
      }
    });
  }

  void tickers() {
    Future<bool> prefInit = initSharedPreference();
    prefInit.then((onValue) {
      checkInternet().then((internet) {
        if (internet == null || !internet) {
          Future<bool> dialog =
              retryDialog(context, "No Internet connection", "");
          dialog.then((onValue) {
            if (onValue) {
              tickers();
            }
          });
        } else {
          getTickers().then((response) {
            parseTickers(response);
          });
        }
      });
    });
  }

  void parseTickers(String response) {
    LineSplitter ls = new LineSplitter();
    List<String> tickerDetails = new List();
    tickerList.clear();
    int i = 0;

    List<Ticker> nseList = new List();
    Map<String, Ticker> nseMap = new Map();

    List<Ticker> bseList = new List();
    Map<String, Ticker> bseMap = new Map();

    List<Ticker> nfoList = new List();
    Map<String, Ticker> nfoMap = new Map();

    for (var line in ls.convert(response)) {
      i++;
      if (i == 1) {
        continue;
      }
      tickerDetails = line.split(",");
      if (tickerDetails[11] == "NSE") {
        nseMap[tickerDetails[0]] = new Ticker(
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
            exchange: tickerDetails[11]);
        nseList.add(new Ticker(
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
      } else if (tickerDetails[11] == "BSE") {
        bseMap[tickerDetails[0]] = new Ticker(
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
            exchange: tickerDetails[11]);
        bseList.add(new Ticker(
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
      } else if (tickerDetails[11] == "NFO") {
        nfoMap[tickerDetails[0]] = new Ticker(
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
            exchange: tickerDetails[11]);
        nfoList.add(new Ticker(
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
    }

    tickerMap.addAll(nseMap);
    tickerMap.addAll(bseMap);
    tickerMap.addAll(nfoMap);

    tickerList.addAll(nseList);
    tickerList.addAll(bseList);
    tickerList.addAll(nfoList);

    tokens();
  }

  void tokens() {
    if (prefs.getString("accessToken") != null &&
        prefs.getString("accessToken").length > 0) {
      accessToken = prefs.getString("accessToken");
      userID = prefs.getString("userID");

      checkInternet().then((internet) {
        if (internet == null || !internet) {
          Future<bool> dialog =
              retryDialog(context, "No Internet connection", "");
          dialog.then((onValue) {
            if (onValue) {
              tokens();
            }
          });
        } else {
          Future<bool> load = checkAccessToken();
          load.then((response) {
            setState(() {
              loaded = true;
            });
            if (response) {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new DashboardActivity()));
            }
          });
        }
      });
    } else {
      setState(() {
        loaded = true;
        shouldLogin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Container(
        color: Colors.white,
        child: new Center(
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    "Welcome to",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    "MOCK TRADE",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              new SizedBox(
                width: 200,
                height: 200,
                child: new Image.asset('assets/bull.jpg'),
              ),
              loaded && shouldLogin
                  ? new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          "Login with",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    )
                  : new Container(),
              new Container(
                height: 10,
              ),
              loaded && shouldLogin
                  ? new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new LoginActivity()));
                      },
                      child: new Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(3.0),
                        child: new Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new SizedBox(
                              width: 50,
                              height: 50,
                              child: new Image.asset('assets/kite.jpg'),
                            ),
                            new Text(
                              "Zerodha",
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : new Container(),
            ],
          ),
        ),
      ),
    );
  }
}
