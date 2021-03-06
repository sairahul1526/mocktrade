import 'package:flutter/material.dart';
import 'package:mocktrade/screens/alerts.dart';
import 'package:mocktrade/utils/config.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import './account.dart';
import './orders.dart';
import './portfolio.dart';
import './watchlist.dart';

class DashboardActivity extends StatefulWidget {
  DashboardActivity();

  @override
  DashboardActivityState createState() {
    return new DashboardActivityState();
  }
}

class DashboardActivityState extends State<DashboardActivity>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 5, vsync: this, initialIndex: 0);

    OneSignal.shared.sendTag("user_id", userID).then((response) {
      print("Successfully sent tags with response: $response");
    }).catchError((error) {
      print("Encountered an error sending tags: $error");
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new BottomAppBar(
        elevation: 50,
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: SizedBox(
                height: 60,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                        controller.index = selectedTab;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.bookmark_border,
                            color:
                                selectedTab == 0 ? Colors.blue : Colors.black),
                        Text(
                          "Watchlist",
                          style: TextStyle(
                              color: selectedTab == 0
                                  ? Colors.blue
                                  : Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: SizedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                        controller.index = selectedTab;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.description,
                            color:
                                selectedTab == 1 ? Colors.blue : Colors.black),
                        Text(
                          "Orders",
                          style: TextStyle(
                              color: selectedTab == 1
                                  ? Colors.blue
                                  : Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: SizedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 2;
                        controller.index = selectedTab;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.card_travel,
                            color:
                                selectedTab == 2 ? Colors.blue : Colors.black),
                        Text(
                          "Portfolio",
                          style: TextStyle(
                              color: selectedTab == 2
                                  ? Colors.blue
                                  : Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: SizedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 3;
                        controller.index = selectedTab;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.notifications_none,
                            color:
                                selectedTab == 3 ? Colors.blue : Colors.black),
                        Text(
                          "Alerts",
                          style: TextStyle(
                              color: selectedTab == 3
                                  ? Colors.blue
                                  : Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            new Expanded(
              child: SizedBox(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedTab = 4;
                        controller.index = selectedTab;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.settings,
                            color:
                                selectedTab == 4 ? Colors.blue : Colors.black),
                        Text(
                          "Settings",
                          style: TextStyle(
                              color: selectedTab == 4
                                  ? Colors.blue
                                  : Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: new TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: <Widget>[
          new WatchlistsActivity(),
          new OrdersActivity(),
          new PortfolioActivity(),
          new AlertsActivity(),
          new AccountActivity()
        ],
      ),
    );
  }
}
