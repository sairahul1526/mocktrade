import 'package:flutter/material.dart';
import 'package:mocktrade/main.dart';
import 'package:mocktrade/utils/api.dart';
import 'package:mocktrade/utils/config.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';
import 'package:email_validator/email_validator.dart';

import '../utils/utils.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LoginState();
  }
}

class LoginState extends State<Login> {
  FocusNode textSecondFocusNode = new FocusNode();

  TextEditingController mail = new TextEditingController();
  TextEditingController otp = new TextEditingController();

  bool loading = false;
  bool otpSent = false;
  bool wrongOtp = false;

  String onesignalUserId = "";

  @override
  void initState() {
    super.initState();
  }

  void sendOTP() {
    print("sendOTP");
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
      } else {
        setState(() {
          loading = true;
        });
        Future<dynamic> load =
            addGetResponse(API.SENDEMAILOTP, Map.from({"email": mail.text}));
        load.then((response) {
          if (response != null) {
            setState(() {
              loading = false;
              otpSent = true;
            });
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                sendOTP();
              });
            });
          }
        });
      }
    });
  }

  void verifyOTP() {
    checkInternet().then((internet) {
      if (internet == null || !internet) {
        oneButtonDialog(context, "No Internet connection", "", true);
      } else {
        setState(() {
          loading = true;
        });
        Future<dynamic> load = addGetResponse(API.VERIFYEMAILOTP,
            Map.from({"email": mail.text, "user_id": userID, "otp": otp.text}));
        load.then((response) {
          if (response != null) {
            if (response["meta"] != null &&
                response["meta"]["status"] == "200") {
              Navigator.pop(context);
              if (response["data"] != null) {
                userID = response["data"][0]["user_id"];
                email = response["data"][0]["email"];
                prefs.setString("userID", userID);
                prefs.setString("email", email);
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (BuildContext context) => new MyHomePage()));
              }
            } else {
              setState(() {
                wrongOtp = true;
              });
            }
            setState(() {
              loading = false;
            });
          } else {
            new Timer(const Duration(milliseconds: retry), () {
              setState(() {
                verifyOTP();
              });
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: new Text(
          "Login",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ),
      body: ModalProgressHUD(
        child: new Container(
          margin: new EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.1,
              100,
              MediaQuery.of(context).size.width * 0.1,
              0),
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              new Container(
                height: 50,
              ),
              new Container(
                height: 50,
                decoration: BoxDecoration(
                    border: otpSent
                        ? Border(
                            left: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                          )
                        : Border(
                            left: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                          )),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      margin: EdgeInsets.only(left: 15),
                      child: new Text(
                        "EMAIL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    new Expanded(
                      child: new Container(
                        child: new TextField(
                          cursorColor: Colors.black,
                          controller: mail,
                          autocorrect: false,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'rahul@gmail.com',
                          ),
                          onSubmitted: (String value) {
                            FocusScope.of(context)
                                .requestFocus(textSecondFocusNode);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              otpSent
                  ? new Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.black),
                          right: BorderSide(color: Colors.black),
                          top: BorderSide(color: Colors.black),
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            margin: EdgeInsets.only(left: 15),
                            child: new Text(
                              "OTP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          new Expanded(
                            child: new Container(
                              child: new TextField(
                                cursorColor: Colors.black,
                                controller: otp,
                                focusNode: textSecondFocusNode,
                                textInputAction: TextInputAction.go,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (String value) {
                                  if (otpSent) {
                                    verifyOTP();
                                  } else {
                                    if (mail.text.length > 0 &&
                                        EmailValidator.validate(mail.text)) {
                                      sendOTP();
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : new Container(),
              new Container(
                decoration: new BoxDecoration(
                  color: Colors.black,
                ),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new FlatButton(
                        onPressed: () {
                          if (otpSent) {
                            verifyOTP();
                          } else {
                            if (mail.text.length > 0 &&
                                EmailValidator.validate(mail.text)) {
                              sendOTP();
                            }
                          }
                        },
                        child: new Text(
                          otpSent ? "Verify OTP" : "Send OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                margin: new EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: new Center(
                  child: new Text(
                    wrongOtp ? "Incorrect OTP" : "",
                    style: new TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        inAsyncCall: loading,
      ),
    );
  }
}
