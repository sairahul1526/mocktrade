import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:hex/hex.dart';
import 'package:convert_hex/convert_hex.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import './config.dart';

DateFormat headingDateFormat = new DateFormat("EEE, MMM d, ''yy");

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

int converttoint(Iterable<int> data) {
  return Hex.decode(HEX.encode(data.toList()));
}

Future<String> getTickers() async {
  final response =
      await http.get("https://api.kite.trade/instruments", headers: {
    "X-Kite-Version": "3",
    "Authorization": "token " + apiKey + ":" + accessToken + ""
  });

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

bool isMarketOpen() {
  if (holiday) {
    return false;
  }
  print(open);
  print(close);
  print(DateTime.now());
  if (DateTime.now().isAfter(open) && DateTime.now().isBefore(close)) {
    return true;
  }
  return false;
}