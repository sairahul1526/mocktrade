import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './models.dart';
import './config.dart';
import './utils.dart';

// account

Future<Accounts> getAccounts(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.ACCOUNT, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Accounts.fromJson(json.decode(response.body));
}

// amount

Future<Amounts> getAmounts(Map<String, String> query) async {
  if (prefs != null) {
    for (var i = 1; i < 30; i++) {
      prefs.setString(
          dateFormat.format(DateTime.now().add(new Duration(days: -i))) +
              "_" +
              query["user_id"] +
              "_amounts",
          "");
    }
    String resp = prefs.getString(dateFormat.format(DateTime.now()) +
        "_" +
        query["user_id"] +
        "_amounts");
    if (resp != null && resp.length > 0) {
      return Amounts.fromJson(json.decode(resp));
    }
  }
  final response = await http
      .get(Uri.http(API.URL, API.AMOUNT, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  if (response.statusCode == 200) {
    prefs.setString(
        dateFormat.format(DateTime.now()) + "_" + query["user_id"] + "_amounts",
        response.body);
  }
  return Amounts.fromJson(json.decode(response.body));
}

// login

Future<Logins> getLogins(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.LOGIN, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Logins.fromJson(json.decode(response.body));
}

// timing

Future<Timings> getTimings(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.TIMING, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Timings.fromJson(json.decode(response.body));
}

// token

Future<Tokens> getTokens(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.TOKEN, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Tokens.fromJson(json.decode(response.body));
}

// order

Future<Orders> getOrders(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.ORDER, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Orders.fromJson(json.decode(response.body));
}

// postion

Future<Positions> getPositions(Map<String, String> query) async {
  final response = await http
      .get(Uri.http(API.URL, API.POSITIONS, query), headers: headers)
      .timeout(Duration(seconds: timeout));

  return Positions.fromJson(json.decode(response.body));
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

// add and update
Future<dynamic> addGetResponse(
    String endpoint, Map<String, String> body) async {
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
  var resp = await response.stream.bytesToString();
  if (resp != null) {
    return json.decode(resp);
  }
  return null;
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
