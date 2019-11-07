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