import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './models.dart';
import './config.dart';
import './utils.dart';

// account

Future<Accounts> getAccounts(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.ACCOUNT, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Accounts.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// alert

Future<Alerts> getAlerts(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.ALERT, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Alerts.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// amount

Future<Amounts> getAmounts(Map<String, String> query) async {
  if (prefs != null) {
    String respDate = prefs.getString("amounts_date");
    if (respDate != null &&
        respDate.length > 0 &&
        respDate == dateFormat.format(new DateTime.now())) {
      String resp = prefs.getString("amounts");
      if (resp != null && resp.length > 0) {
        return Amounts.fromJson(json.decode(resp));
      }
    }
  }
  try {
    final response = await http
        .get(Uri.http(API.URL, API.AMOUNT, query), headers: headers)
        .timeout(Duration(seconds: timeout));
    if (response.statusCode == 200) {
      prefs.setString("amounts", response.body);
      prefs.setString("amounts_date", dateFormat.format(new DateTime.now()));
    }
    return Amounts.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// login

Future<Logins> getLogins(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.LOGIN, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Logins.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// ticker last

Future<TickerLasts> getTickerClose(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TICKERCLOSE, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return TickerLasts.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// timing

Future<Timings> getTimings(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TIMING, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Timings.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// token

Future<Tokens> getTokens(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TOKEN, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Tokens.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// order

Future<Orders> getOrders(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.ORDER, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Orders.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// postion

Future<Positions> getPositions(Map<String, String> query) async {
  try {
    final response = await http
        .get(Uri.http(API.URL, API.POSITIONS, query), headers: headers)
        .timeout(Duration(seconds: timeout));

    return Positions.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
}

// ticker

Future<Tickers> getTickers() async {
  if (prefs != null) {
    String respDate = prefs.getString("tickers_date");
    if (respDate != null &&
        respDate.length > 0 &&
        respDate == dateFormat.format(new DateTime.now())) {
      String resp = prefs.getString("tickers");
      if (resp != null && resp.length > 0) {
        return Tickers.fromJson(json.decode(resp));
      }
    }
  }
  try {
    final response = await http
        .get(Uri.http(API.URL, API.TICKER), headers: headers)
        .timeout(Duration(seconds: timeout));
    if (response.statusCode == 200) {
      prefs.setString("tickers", response.body);
      prefs.setString("tickers_date", dateFormat.format(new DateTime.now()));
    }
    return Tickers.fromJson(json.decode(response.body));
  } catch (e) {
    return null;
  }
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

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  } catch (e) {
    return null;
  }
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
  )..fields.addAll(body);
  request.headers.addAll(headers);

  try {
    var response = await request.send();
    var resp = await response.stream.bytesToString();
    if (resp != null) {
      return json.decode(resp);
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<bool> update(String endpoint, Map<String, String> body,
    Map<String, String> query) async {
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
    return null;
  }
}

Future<bool> delete(String endpoint, Map<String, String> query) async {
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
    return null;
  }
}
