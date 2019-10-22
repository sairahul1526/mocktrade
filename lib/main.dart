import 'package:flutter/material.dart';
import 'package:mocktrade/watchlist.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(new MaterialApp(
    title: "mocktrade",
    home: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mocktrade',
      home: MyHomePage(title: 'mocktrade'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0;
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 4, vsync: this, initialIndex: 0);
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
                        Icon(Icons.card_travel,
                            color:
                                selectedTab == 1 ? Colors.blue : Colors.black),
                        Text(
                          "Positions",
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
                        Icon(Icons.contacts,
                            color:
                                selectedTab == 2 ? Colors.blue : Colors.black),
                        Text(
                          "Traders",
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
                        Icon(Icons.person_outline,
                            color:
                                selectedTab == 3 ? Colors.blue : Colors.black),
                        Text(
                          "Account",
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
          ],
        ),
      ),
      body: new TabBarView(
        controller: controller,
        children: <Widget>[
          new WatchlistsActivity(),
          new Container(),
          new Container(),
          new Container()
        ],
      ),
    );
  }
}
