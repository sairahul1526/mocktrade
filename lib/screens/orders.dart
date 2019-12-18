import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../utils/config.dart';
import '../utils/utils.dart';
import '../utils/models.dart';

class OrdersActivity extends StatefulWidget {
  @override
  OrdersActivityState createState() {
    return new OrdersActivityState();
  }
}

class OrdersActivityState extends State<OrdersActivity>
    with AutomaticKeepAliveClientMixin<OrdersActivity> {
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
    orders.clear();
    ordersapi();
  }

  void _onRefresh() async {
    orders.clear();
    end = false;
    ongoing = false;
    offset = defaultOffset;
    ordersapi();
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      if (!end && !ongoing) {
        setState(() {
          loading = true;
        });
        ordersapi();
      }
    }
  }

  void ordersapi() {
    setState(() {
      loading = true;
      ongoing = true;
    });
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
        setState(() {
          ongoing = false;
          loading = false;
        });
        _refreshController.refreshCompleted();
      } else {
        Future<Orders> data = getOrders({
          "user_id": userID,
          "limit": defaultLimit,
          "offset": offset,
          "orderby": "created_date_time",
          "sortby": "desc",
          "status": "1",
          "today": "true",
        });
        data.then((response) {
          _refreshController.refreshCompleted();
          if (response.orders != null && response.orders.length > 0) {
            offset =
                (int.parse(response.pagination.offset) + response.orders.length)
                    .toString();
            response.orders.forEach((order) {
              orders.add(order);
            });
            setState(() {
              orders = orders;
            });
          } else {
            end = true;
          }
          if (response.meta != null && response.meta.messageType == "1") {
            oneButtonDialog(context, "", response.meta.message,
                !(response.meta.status == STATUS_403));
          }
          setState(() {
            ongoing = false;
            loading = false;
          });
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
          "Orders",
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
                    child: orders.length == 0
                        ? new SmartRefresher(
                            onRefresh: _onRefresh,
                            controller: _refreshController,
                            child: new Center(
                                child: new Text(loading
                                    ? ""
                                    : "You haven't placed any orders")),
                          )
                        : new SmartRefresher(
                            onRefresh: _onRefresh,
                            controller: _refreshController,
                            child: new ListView.separated(
                              controller: _controller,
                              itemCount: orders.length,
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
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 5),
                                              padding: EdgeInsets.all(3),
                                              color: orders[i].type == "0"
                                                  ? HexColor("#e1d0d1")
                                                  : HexColor("#cfd6e1"),
                                              child: new Text(
                                                  orders[i].type == "0"
                                                      ? "SELL"
                                                      : "BUY",
                                                  style: TextStyle(
                                                      color:
                                                          orders[i].type == "0"
                                                              ? Colors.red
                                                              : Colors.blue)),
                                            ),
                                            new Text(
                                              headingDateFormat.format(
                                                  DateTime.parse(orders[i]
                                                      .createdDateTime)),
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
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
                                            new Text(
                                              orders[i].name,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            new Text(orders[i].shares +
                                                " X " +
                                                orders[i].price),
                                          ],
                                        ),
                                        new Container(
                                          height: 5,
                                        ),
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              orders[i].exchange,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            new Text(
                                              orders[i].invested,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
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
