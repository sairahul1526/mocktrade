import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:mocktrade/utils/api.dart';

import './dashboard.dart';
import '../utils/utils.dart';
import '../utils/config.dart';

class LoginActivity extends StatefulWidget {
  LoginActivity();

  @override
  State<StatefulWidget> createState() => LoginActivityState();
}

class LoginActivityState extends State<LoginActivity> {
  String selectedUrl = "";

  @override
  void initState() {
    super.initState();

    getLogins({}).then((response) {
      setState(() {
        selectedUrl = response.logins[0].url;
      });
      print(selectedUrl);
    });

    final flutterWebviewPlugin = new FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      String token = Uri.parse(url).queryParameters["request_token"];
      if (token != null && token.length > 0) {
        getTokens({"tok": token}).then((response) {
          accessToken = response.tokens[0].token;
          prefs.setString("accessToken", accessToken);
          userID = response.tokens[0].userID;
          prefs.setString("userID", userID);

          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new DashboardActivity()));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new SafeArea(
        child: new Container(
          color: Colors.white,
          child: selectedUrl.length > 0
              ? new WebviewScaffold(
                  url: selectedUrl,
                  withLocalStorage: true,
                  initialChild: Container(
                    child: const Center(
                      child: Text('Waiting.....'),
                    ),
                  ),
                )
              : new Container(),
        ),
      ),
    );
  }
}
