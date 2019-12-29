import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import './models.dart';
import './config.dart';
import './utils.dart';

// account

Future<Accounts> getAccounts(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.ACCOUNT, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Accounts.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getAccounts(query, count + 1);
  }
}

// amount

Future<Amounts> getAmounts(Map<String, String> query, int count) async {
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
  try {
    final response = await http
        .get(Uri.http(API.URL, API.AMOUNT, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    if (response.statusCode == 200) {
      prefs.setString(
          dateFormat.format(DateTime.now()) +
              "_" +
              query["user_id"] +
              "_amounts",
          response.body);
    }
    return Amounts.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getAmounts(query, count + 1);
  }
}

// login

Future<Logins> getLogins(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.LOGIN, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Logins.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getLogins(query, count + 1);
  }
}

// timing

Future<Timings> getTimings(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TIMING, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Timings.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getTimings(query, count + 1);
  }
}

// token

Future<Tokens> getTokens(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TOKEN, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Tokens.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getTokens(query, count + 1);
  }
}

// order

Future<Orders> getOrders(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.ORDER, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Orders.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getOrders(query, count + 1);
  }
}

// postion

Future<Positions> getPositions(Map<String, String> query, int count) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.POSITIONS, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Positions.fromJson(json.decode(response.body));
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return getPositions(query, count + 1);
  }
}

// add and update
Future<bool> add(String endpoint, Map<String, String> body, int count) async {
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

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return add(endpoint, body, count + 1);
  }
}

// add and update
Future<dynamic> addGetResponse(
    String endpoint, Map<String, String> body, int count) async {
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

  try {
    var response = await request.send();
    var resp = await response.stream.bytesToString();
    if (resp != null) {
      return json.decode(resp);
    }
    return null;
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return addGetResponse(endpoint, body, count + 1);
  }
}

Future<bool> update(String endpoint, Map<String, String> body,
    Map<String, String> query, int count) async {
  var request = new http.MultipartRequest(
    "PUT",
    Uri.http(API.URL, endpoint, query),
  );
  request.headers.addAll(headers);
  body.forEach((k, v) => {request.fields[k] = v});

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return update(endpoint, body, query, count + 1);
  }
}

Future<bool> delete(
    String endpoint, Map<String, String> query, int count) async {
  var request = new http.MultipartRequest(
    "DELETE",
    Uri.http(API.URL, endpoint, query),
  );

  request.headers.addAll(headers);

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    sleep(new Duration(seconds: 2 * count));
    return delete(endpoint, query, count + 1);
  }
}
