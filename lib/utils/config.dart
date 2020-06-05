import './models.dart';
import 'dart:async';

int maxWatchList = 20;
List<Ticker> tickerList = new List();
Map<String, Ticker> tickerMap = new Map();
Map<String, Position> positionsMap = new Map();

Map<String, double> closes = new Map();

List<Ticker> marketwatch = new List();
List<Order> orders = new List();
List<Position> positions = new List();

double invested = 0;
double current = 0;

String userID = "";
String phone = "";
String name = "";

double amount = 0;

class API {
  static const URL = "jau.mabido.xyz";
  static const ACCOUNT = "account";
  static const AMOUNT = "amount";
  static const BUYSELL = "buysell";
  static const LOGIN = "login";
  static const TIMING = "timing";
  static const TOKEN = "token";
  static const ORDER = "order";
  static const POSITIONS = "position";
  static const TICKER = "ticker";
  static const TICKERCLOSE = "tickerclose";
  static const SENDOTP = "sendotp";
  static const VERIFYOTP = "verifyotp";
}

String supportEmail = "rahul.mocktrade@gmail.com";

class APPVERSION {
  static const ANDROID = "1.7";
  static const IOS = "1.0";
}

class APIKEY {
  static const ANDROID_LIVE = "T9h9P6j2N6y9M3Q8";
  static const ANDROID_TEST = "K7b3V4h3C7t6g6M7";
  static const IOS_LIVE = "b4E6U9K8j6b5E9W3";
  static const IOS_TEST = "R4n7N8G4m9B4S5n2";
}

Map<String, String> headers = {
  "pkgname": "com.saikrishna.mocktrade",
  "Accept-Encoding": "gzip"
};

const timeout = 10;
const retry = 3000;

const defaultLimit = "25";
const defaultOffset = "0";

// status
const STATUS_400 = "400";
const STATUS_403 = "403"; // forbidden
const STATUS_500 = "500";

StreamController<Map<String, double>> streamController =
    new StreamController.broadcast();

StreamController<String> channelStreamController =
    new StreamController.broadcast();
