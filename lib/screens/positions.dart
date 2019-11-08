import 'package:flutter/material.dart';

import './orders.dart';
import './portfolio.dart';

class PositionsActivity extends StatefulWidget {
  @override
  PositionsActivityState createState() {
    return new PositionsActivityState();
  }
}

class PositionsActivityState extends State<PositionsActivity>
    with SingleTickerProviderStateMixin {
  double width = 0;
  int selectedTab = 0;
  TabController controller;

  @override
  void initState() {
    super.initState();

    controller = new TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Positions",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
        bottom: new TabBar(
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          controller: controller,
          isScrollable: true,
          tabs: <Widget>[
            new Tab(text: "         Orders         "),
            new Tab(text: "         Portfolio         ")
          ],
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[new OrdersActivity(), new PortfolioActivity()],
      ),
    );
  }
}
