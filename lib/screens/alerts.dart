import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:async';

import '../utils/config.dart';
import '../utils/utils.dart';
import '../utils/models.dart';

class AlertsActivity extends StatefulWidget {
  @override
  AlertsActivityState createState() {
    return new AlertsActivityState();
  }
}

class AlertsActivityState extends State<AlertsActivity>
    with AutomaticKeepAliveClientMixin<AlertsActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;

  ScrollController _controller;
  bool end = false;
  bool ongoing = false;
  String offset = defaultOffset;
  bool loading = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    alerts.clear();
    alertsapi();
  }

  void _onRefresh() async {
    alerts.clear();
    end = false;
    ongoing = false;
    offset = defaultOffset;
    alertsapi();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (!end && !ongoing) {
        if (!mounted) return;
        setState(() {
          loading = true;
        });
        alertsapi();
      }
    }
  }

  void alertsapi() {
    if (!mounted) return;
    setState(() {
      loading = true;
      ongoing = true;
    });
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        Future<bool> dialog =
            retryDialog(context, "No Internet connection", "");
        dialog.then((onValue) {
          if (onValue) {
            alertsapi();
          }
        });
        if (!mounted) return;
        setState(() {
          ongoing = false;
          loading = false;
        });
        _refreshController.refreshCompleted();
      } else {
        Future<Alerts> data = getAlerts({
          "user_id": userID,
          "limit": defaultLimit,
          "offset": offset,
          "orderby": "created_date_time",
          "sortby": "desc",
        });
        data.then((response) {
          _refreshController.refreshCompleted();
          if (response != null) {
            if (response.alerts != null && response.alerts.length > 0) {
              offset = (int.parse(response.pagination.offset) +
                      response.alerts.length)
                  .toString();
              response.alerts.forEach((alert) {
                alerts.add(alert);
              });
              if (!mounted) return;
              setState(() {
                alerts = alerts;
              });
            } else {
              end = true;
            }
            if (response.meta != null && response.meta.messageType == "1") {
              oneButtonDialog(context, "", response.meta.message,
                  !(response.meta.status == STATUS_403));
            }

            if (!mounted) return;
            setState(() {
              ongoing = false;
              loading = false;
            });
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              if (!mounted) return;
              setState(() {
                alertsapi();
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Alerts",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ),
      body: new ModalProgressHUD(
        inAsyncCall: loading,
        child: new Container(
          color: Colors.white,
          child: new SafeArea(
            child: new Container(
              padding: EdgeInsets.all(20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Expanded(
                    child: alerts.length == 0
                        ? new SmartRefresher(
                            onRefresh: _onRefresh,
                            controller: _refreshController,
                            child: new Center(
                                child: new Text(loading
                                    ? ""
                                    : "You haven't placed any alerts")),
                          )
                        : new SmartRefresher(
                            onRefresh: _onRefresh,
                            controller: _refreshController,
                            child: new ListView.separated(
                              controller: _controller,
                              itemCount: alerts.length,
                              separatorBuilder: (context, i) {
                                return new Divider();
                              },
                              itemBuilder: (itemContext, i) {
                                return new GestureDetector(
                                  onTap: () {},
                                  child: new Container(
                                    color: Colors.transparent,
                                    width: width,
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: new Column(
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            new Expanded(
                                              child: new Text(
                                                alerts[i].name +
                                                    (alerts[i].when == "1"
                                                        ? " > "
                                                        : " < ") +
                                                    alerts[i].price,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Container(
                                          height: 5,
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Icon(
                                              Icons.fiber_manual_record,
                                              color: alerts[i].alerted == "0"
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 10,
                                            ),
                                            new Container(
                                              width: 10,
                                            ),
                                            new Expanded(
                                              child: new Text(
                                                alerts[i].alerted == "0"
                                                    ? "Active"
                                                    : "Alert",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            new Text(
                                              headingDateFormat.format(
                                                  DateTime.parse(alerts[i]
                                                      .createdDateTime)),
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
