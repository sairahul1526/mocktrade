import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mocktrade/utils/api.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import './screens/dashboard.dart';
import './screens/login.dart';
import './utils/utils.dart';
import './utils/models.dart';
import './utils/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        oneButtonDialog(context, "No Internet connection", "", true);
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
      if (onValue) {
        String response =
            prefs.getString(DateTime.now().day.toString() + "_tickers");
        if (response != null && response.length > 0) {
          parseTickers(response);
        } else {
          getTickers().then((response) {
            prefs.setString(
                DateTime.now().day.toString() + "_tickers", response);
            parseTickers(response);
          });
        }
      } else {
        getTickers().then((response) {
          prefs.setString(DateTime.now().day.toString() + "_tickers", response);
          parseTickers(response);
        });
      }
    });
  }

  void parseTickers(String response) {
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
      tickerMap[tickerDetails[0]] = new Ticker(
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

    tokens();
  }

  void tokens() {
    Future<bool> prefInit = initSharedPreference();
    prefInit.then((onValue) {
      if (onValue) {
        if (prefs.getString("accessToken") != null &&
            prefs.getString("accessToken").length > 0) {
          accessToken = prefs.getString("accessToken");
          userID = prefs.getString("userID");

          Future<bool> load = checkAccessToken();
          load.then((response) {
            if (response) {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new DashboardActivity()));
            } else {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new LoginActivity()));
            }
          });
        } else {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new LoginActivity()));
        }
      } else {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new LoginActivity()));
      }
    });
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
              new SizedBox(
                width: 200,
                height: 200,
                child: new Image.asset('assets/bull.jpg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
