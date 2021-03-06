import 'package:flutter/material.dart';
import 'package:mocktrade/utils/models.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../utils/config.dart';
import '../utils/api.dart';
import '../utils/utils.dart';

class ReordersActivity extends StatefulWidget {
  @override
  ReordersActivityState createState() {
    return new ReordersActivityState();
  }
}

class ReordersActivityState extends State<ReordersActivity>
    with AutomaticKeepAliveClientMixin<ReordersActivity> {
  @override
  bool get wantKeepAlive => true;
  double width = 0;

  List<Ticker> reordermarketwatch = new List();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    marketwatch.forEach((watch) {
      reordermarketwatch.add(watch);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      body: new ModalProgressHUD(
          inAsyncCall: loading,
          child: new Container(
            child: new SafeArea(
              child: new Container(
                padding: EdgeInsets.all(20),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          onPressed: () {
                            setState(() {
                              loading = true;
                            });
                            List<int> tickers = new List();
                            reordermarketwatch.forEach((watch) {
                              tickers.add(int.parse(watch.instrumentToken));
                            });
                            checkInternet().then((internet) {
                              if (internet == null || !internet) {
                                Future<bool> dialog = retryDialog(
                                    context, "No Internet connection", "");
                                dialog.then((onValue) {
                                  if (onValue) {}
                                });
                              } else {
                                Future<bool> load = update(
                                    API.ACCOUNT,
                                    Map.from({
                                      "watchlist": tickers.join(","),
                                    }),
                                    Map.from({'user_id': userID}));
                                load.then((onValue) {
                                  setState(() {
                                    loading = false;
                                  });
                                  if (onValue != null) {
                                    marketwatch.clear();
                                    reordermarketwatch.forEach((watch) {
                                      marketwatch.add(watch);
                                    });
                                    Navigator.pop(context, "Marketwatch saved");
                                  }
                                });
                              }
                            });
                          },
                          child: new Text("SAVE"),
                        )
                      ],
                    ),
                    new Container(
                      height: 20,
                    ),
                    new Expanded(
                      child: new ReorderableListView(
                        onReorder: (int oldIndex, int newIndex) {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          Ticker temp = reordermarketwatch.removeAt(oldIndex);
                          reordermarketwatch.insert(newIndex, temp);
                          setState(() {
                            reordermarketwatch = reordermarketwatch;
                          });
                        },
                        children: List.generate(reordermarketwatch.length, (i) {
                          return reordermarketwatch[i] == null
                              ? new Container(
                                  key: ValueKey(i),
                                )
                              : new GestureDetector(
                                  key: ValueKey(i),
                                  onTap: () {},
                                  child: new Container(
                                    color: Colors.transparent,
                                    width: width,
                                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: new Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Icon(
                                              Icons.more_vert,
                                              color: Colors.grey,
                                              size: 15,
                                            ),
                                            new Text(
                                              reordermarketwatch[i]
                                                  .tradingSymbol,
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                            new IconButton(
                                              onPressed: () {
                                                reordermarketwatch.removeAt(i);
                                                setState(() {
                                                  reordermarketwatch =
                                                      reordermarketwatch;
                                                });
                                              },
                                              icon: new Icon(
                                                Icons.delete,
                                                color: Colors.grey,
                                                size: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        new Container(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
