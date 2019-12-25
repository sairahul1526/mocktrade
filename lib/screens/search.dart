import 'package:flutter/material.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../utils/utils.dart';
import '../utils/config.dart';
import '../utils/models.dart';

class SearchActivity extends StatefulWidget {
  @override
  SearchActivityState createState() {
    return new SearchActivityState();
  }
}

class SearchActivityState extends State<SearchActivity> {
  double width = 0;

  TextEditingController search = new TextEditingController();

  List<Ticker> tickerSearchList = new List();

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      body: new ModalProgressHUD(
        inAsyncCall: loading,
        child: new SafeArea(
          child: new Container(
            child: new Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new Container(
                      width: 5,
                    ),
                    new Expanded(
                      child: new TextField(
                        onChanged: (text) {
                          if (text.length > 1) {
                            setState(() {
                              tickerSearchList = tickerList
                                  .where((i) =>
                                      i.name.contains(text) ||
                                      i.tradingSymbol.contains(text))
                                  .toList();
                            });
                          } else {
                            setState(() {
                              tickerSearchList = new List();
                            });
                          }
                        },
                        autofocus: true,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.characters,
                        controller: search,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search eg: infy, tcs',
                        ),
                        onSubmitted: (String value) {},
                      ),
                    ),
                    search.text.length > 1
                        ? new FlatButton(
                            child: new Text(
                              "Clear",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              setState(() {
                                search.text = "";
                                tickerSearchList = new List();
                              });
                            },
                          )
                        : new Container()
                  ],
                ),
                new Divider(),
                new Expanded(
                  child: new ListView.separated(
                    itemCount: tickerSearchList.length,
                    separatorBuilder: (context, i) {
                      return new Divider();
                    },
                    itemBuilder: (itemContext, i) {
                      return new GestureDetector(
                        onTap: () {
                          setState(() {
                            loading = true;
                          });
                          bool added = false;
                          marketwatch.forEach((watch) {
                            if (int.parse(watch.instrumentToken) ==
                                int.parse(
                                    tickerSearchList[i].instrumentToken)) {
                              added = true;
                            }
                          });
                          if (added) {
                            Navigator.pop(
                                context, "Already added to marketwatch");
                            return;
                          }
                          marketwatch.add(tickerSearchList[i]);
                          List<int> tickers = new List();
                          marketwatch.forEach((watch) {
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
                                Map.from({'user_id': userID}),
                              );
                              load.then((onValue) {
                                Navigator.of(context).pop();
                              });
                            }
                          });
                        },
                        child: new Container(
                          color: Colors.transparent,
                          width: width,
                          height: 50,
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                padding: EdgeInsets.all(3),
                                color: tickerSearchList[i].exchange == "NSE"
                                    ? HexColor("#e1d0d1")
                                    : tickerSearchList[i].exchange == "BSE"
                                        ? HexColor("#cfd6e1")
                                        : HexColor("#d8d7d9"),
                                child: new Text(tickerSearchList[i].exchange,
                                    style: TextStyle(
                                        color: tickerSearchList[i].exchange ==
                                                "NSE"
                                            ? Colors.red
                                            : tickerSearchList[i].exchange ==
                                                    "BSE"
                                                ? Colors.blue
                                                : Colors.black)),
                              ),
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    tickerSearchList[i].tradingSymbol,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  tickerSearchList[i].name.length > 0
                                      ? new Text(
                                          tickerSearchList[i].name,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        )
                                      : new Container(),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
