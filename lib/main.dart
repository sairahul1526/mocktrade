import 'package:flutter/material.dart';
import 'package:mocktrade/dashboard.dart';
import 'package:mocktrade/login.dart';

import './utils.dart';
import './models.dart';
import 'dart:convert';
import './config.dart';
import 'package:flutter/foundation.dart';

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

    getTickers().then((response) {
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
        tickerMap[int.parse(tickerDetails[0])] = new Ticker(
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

      Future<bool> prefInit = initSharedPreference();
      prefInit.then((onValue) {
        if (onValue) {
          if (prefs.getString("phone") != null &&
              prefs.getString("phone").length > 0) {
            phone = prefs.getString("phone");

            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => new DashboardActivity()));
          } else {
            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                builder: (BuildContext context) => new LoginActivity()));
          }
        } else {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new LoginActivity()));
        }
      });
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
