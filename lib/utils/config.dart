import './models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Ticker> tickerList = new List();
Map<int, Ticker> tickerMap = new Map();
Map<String, DocumentSnapshot> positionsMap = new Map();

List<Ticker> marketwatch = new List();

String apiKey = "cu50ienpvww2pb2o";
String accessToken = "";

String phone = "";

bool holiday = false;
DateTime open = DateTime.now();
DateTime close = DateTime.now();

class API {
  static const URL = "mocktrade1.ap-south-1.elasticbeanstalk.com";
  static const AMOUNT = "amount";
  static const ORDER = "order";
  static const POSITIONS = "position";
  static const WATCHLIST = "watchlist";
}


class APPVERSION {
  static const ANDROID = "2.6";
  static const IOS = "1.1";
}

class APIKEY {
  static const ANDROID_LIVE = "T9h9P6j2N6y9M3Q8";
  static const ANDROID_TEST = "K7b3V4h3C7t6g6M7";
  static const IOS_LIVE = "b4E6U9K8j6b5E9W3";
  static const IOS_TEST = "R4n7N8G4m9B4S5n2";
}

Map<String, String> headers = {
  "pkgname": "com.saikrishna.cloudpg",
  "Accept-Encoding": "gzip"
};

const timeout = 10;

const defaultLimit = "25";
const defaultOffset = "0";

// status
const STATUS_400 = "400";
const STATUS_403 = "403"; // forbidden
const STATUS_500 = "500";
