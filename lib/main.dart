import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import './screens/dashboard.dart';
import './utils/utils.dart';
import './utils/config.dart';
import './utils/api.dart';

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

    OneSignal.shared.init(ONESIGNAL_APP_ID, iOSSettings: {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: true
    });
    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);

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
    tickers();
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
            if (response != null &&
                response.tickers != null &&
                response.tickers.length > 0) {
              if (response.meta != null && response.meta.messageType == "1") {
                oneButtonDialog(context, "", response.meta.message,
                    !(response.meta.status == STATUS_403));
              }
              tickerList = response.tickers;
              tickerList.forEach((ticker) {
                tickerMap[ticker.instrumentToken] = ticker;
              });
              getUserID();
            } else {
              new Timer(const Duration(milliseconds: retry), () {
                setState(() {
                  tickers();
                });
              });
            }
          });
        }
      });
    });
  }

  void getUserID() {
    if (prefs.getString("userID") != null &&
        prefs.getString("userID").length > 0) {
      userID = prefs.getString("userID");
      phone = prefs.getString("phone");
      name = prefs.getString("name");

      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new DashboardActivity()));
    } else {
      checkInternet().then((internet) {
        if (internet == null || !internet) {
          Future<bool> dialog =
              retryDialog(context, "No Internet connection", "");
          dialog.then((onValue) {
            if (onValue) {}
          });
        } else {
          Future<dynamic> load = addGetResponse(API.ACCOUNT, Map.from({}));
          load.then((onValue) {
            if (onValue != null &&
                onValue["user_id"] != null &&
                onValue["user_id"].toString().length > 0) {
              userID = onValue["user_id"].toString();
              prefs.setString("userID", userID);
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new DashboardActivity()));
            } else {
              new Timer(const Duration(milliseconds: retry), () {
                setState(() {
                  getUserID();
                });
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Container(
        color: Colors.white,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // shrinkWrap: true,
          children: <Widget>[
            new Expanded(
              child: new Container(),
            ),
            new Expanded(
              child: new Container(),
            ),
            new Expanded(
              child: new Column(
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
            ),
            new SizedBox(
              width: 300,
              height: 300,
              child: new Image.asset('assets/bull.jpg'),
            ),
            new Expanded(
              child: new Container(),
            ),
            new Expanded(
              child: new Container(),
            ),
            new Expanded(
              child: new Container(),
            ),
            new Expanded(
              child: new Text(
                "By using this app, \nyou agree to our Privacy Policy and Terms and Conditions.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
