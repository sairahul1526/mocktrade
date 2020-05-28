import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

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

Future<dynamic> getHistoricalData() async {
  final response = await http.get(
      "https://kite.zerodha.com/oms/instruments/historical/260105/5minute?user_id=ZB2718&oi=1&from=2020-01-06&to=2020-01-06&ciqrandom=1578332136095",
      headers: {
        "Authorization":
            "enctoken Wx/wvMxglkruvWLLdysAOo/R821bfhYJrwgzQ3ZfBbZMm83rdq0hw94tITN6TKc28nSOBeQw9m6mH0DI5Q+kuNz/gbc85A=="
      });

  return json.decode(response.body);
}
