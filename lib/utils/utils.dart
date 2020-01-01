import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:hex/hex.dart';
import 'package:convert_hex/convert_hex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import './config.dart';

DateFormat headingDateFormat = new DateFormat("h:mm a EEE, MMM d, ''yy");
DateFormat nameFormat = new DateFormat("d MMM yy");
DateFormat nameMonthFormat = new DateFormat("MMM yy");
DateFormat dateFormat = new DateFormat('yyyy-MM-dd');
RegExp regex = new RegExp(r"[0-9]");

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

void sendMail(String mail, String subject, String body) async {
  var url = 'mailto:' +
      mail +
      "?subject=" +
      subject +
      "&body=" +
      Uri.encodeComponent(body);
  if (await canLaunch(url)) {
    await launch(url);
  }
}

int converttoint(Iterable<int> data) {
  return Hex.decode(HEX.encode(data.toList()));
}

Future<String> getTickers() async {
  if (prefs != null) {
    for (var i = 1; i < 30; i++) {
      prefs.setString(
          dateFormat.format(DateTime.now().add(new Duration(days: -i))) +
              "_tickers",
          "");
    }
    String resp =
        prefs.getString(dateFormat.format(DateTime.now()) + "_tickers");
    if (resp != null && resp.length > 0) {
      return resp;
    }
  }
  final response =
      await http.get("https://api.kite.trade/instruments", headers: {
    "X-Kite-Version": "3",
    "Authorization": "token " + apiKey + ":" + accessToken + ""
  });

  if (response.statusCode == 200) {
    prefs.setString(
        dateFormat.format(DateTime.now()) + "_tickers", response.body);
  }
  return response.body;
}

SharedPreferences prefs;
Future<bool> initSharedPreference() async {
  prefs = await SharedPreferences.getInstance();
  if (prefs != null) {
    return true;
  }
  return false;
}

Future<bool> checkInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
  return false;
}

void oneButtonDialog(
    BuildContext context, String title, String content, bool dismiss) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: content != "" ? new Text(content) : null,
        actions: <Widget>[
          new FlatButton(
            child: new Text("ok"),
            onPressed: () {
              if (dismiss) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<bool> retryDialog(
    BuildContext context, String title, String content) async {
  bool returned = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              "Retry",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              returned = true;
            },
          ),
        ],
      );
    },
  );
  return returned;
}

Future<bool> checkAccessToken() async {
  final response =
      await http.get("https://api.kite.trade/quote/ltp?i=NSE:INFY", headers: {
    "X-Kite-Version": "3",
    "Authorization": "token " + apiKey + ":" + accessToken + ""
  });

  return response.statusCode == 200;
}

Future<dynamic> fillDataAPI(String url, List<String> ticks) async {
  bool init = true;
  for (var tick in ticks) {
    if (!init) {
      url += "&";
    }
    url += "i=" + tick;
    init = false;
  }
  final response = await http.get(url, headers: {
    "X-Kite-Version": "3",
    "Authorization": "token " + apiKey + ":" + accessToken + ""
  });

  return json.decode(response.body);
}
