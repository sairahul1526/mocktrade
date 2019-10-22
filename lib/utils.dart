import 'package:flutter/material.dart';

import 'package:hex/hex.dart';
import 'package:convert_hex/convert_hex.dart';

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