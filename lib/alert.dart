import 'package:flutter/material.dart';
import './utils.dart';

class AlertActivity extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool success;
  AlertActivity(this.title, this.subtitle, this.success);

  @override
  State<StatefulWidget> createState() =>
      AlertActivityState(this.title, this.subtitle, this.success);
}

class AlertActivityState extends State<AlertActivity> {
  String title;
  String subtitle;
  bool success;

  double height = 0;
  double width = 0;

  AlertActivityState(this.title, this.subtitle, this.success);

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return new Scaffold(
      body: new SafeArea(
        child: new Container(
          color: Colors.white,
          padding: new EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.1,
              25,
              MediaQuery.of(context).size.width * 0.1,
              0),
          child: new Container(
            height: height,
            width: width,
            child: new Column(
              children: <Widget>[
                new Expanded(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        height: 70,
                        width: 70,
                        child: new Icon(
                          success ? Icons.done : Icons.priority_high,
                          size: 30,
                          color: success ? Colors.blue : Colors.red,
                        ),
                        decoration: new BoxDecoration(
                          color: !success
                              ? HexColor("#e1d0d1")
                              : HexColor("#cfd6e1"),
                          shape: BoxShape.circle,
                        ),
                      ),
                      new Container(
                        height: 20,
                      ),
                      new Text(
                        title,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      new Container(
                        height: 20,
                      ),
                      new Text(
                        subtitle,
                        style: TextStyle(
                          color: success ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  width: width,
                  margin: new EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: new MaterialButton(
                    color: success ? Colors.blue : Colors.red,
                    height: 40,
                    child: new Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                new Container(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
