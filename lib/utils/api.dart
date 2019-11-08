import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './models.dart';
import './config.dart';

// admin

Future<Amounts> getAmounts(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.AMOUNT, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Amounts.fromJson(json.decode(response.body));
}

// order

Future<Orders> getBills(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.ORDER, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Orders.fromJson(json.decode(response.body));
}

// postion

Future<Positions> getDashboards(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.POSITIONS, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Positions.fromJson(json.decode(response.body));
}

// watchlist

Future<Watchlists> getEmployees(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.WATCHLIST, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Watchlists.fromJson(json.decode(response.body));
}

// add and update
Future<bool> add(String endpoint, Map<String, String> body) async {
  if (body["status"] != null) {
    body["status"] = "1";
  }
  var request = new http.MultipartRequest(
    "POST",
    Uri.http(
      API.URL,
      endpoint,
    ),
  );
  request.headers.addAll(headers);
  body.forEach((k, v) => {request.fields[k] = v});

  var response = await request.send();
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> update(String endpoint, Map<String, String> body,
    Map<String, String> query) async {
  var request = new http.MultipartRequest(
    "PUT",
    Uri.http(API.URL, endpoint, query),
  );
  request.headers.addAll(headers);
  body.forEach((k, v) => {request.fields[k] = v});

  var response = await request.send();
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> delete(String endpoint, Map<String, String> query) async {
  var request = new http.MultipartRequest(
    "DELETE",
    Uri.http(API.URL, endpoint, query),
  );

  request.headers.addAll(headers);

  var response = await request.send();
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
