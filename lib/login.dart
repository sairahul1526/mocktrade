import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktrade/config.dart';
import 'package:mocktrade/dashboard.dart';

import './utils.dart';

class LoginActivity extends StatefulWidget {
  LoginActivity();

  @override
  State<StatefulWidget> createState() => LoginActivityState();
}

class LoginActivityState extends State<LoginActivity> {
  final TextEditingController phoneno = TextEditingController();
  final TextEditingController otp = TextEditingController();

  bool phonenoCheck = false;
  bool otpCheck = false;

  String _verificationId;

  bool otpsent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: new Align(
        alignment: Alignment.bottomCenter,
        child: new FloatingActionButton(
          onPressed: () async {
            if (otpsent) {
              _signInWithPhoneNumber();
            } else {
              setState(() {
                otpsent = true;
              });
              _verifyPhoneNumber();
            }
          },
          child: Icon(Icons.arrow_forward_ios),
          backgroundColor: Colors.blue,
        ),
      ),
      body: new SafeArea(
        child: new Container(
          color: Colors.white,
          padding: new EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.1,
              25,
              MediaQuery.of(context).size.width * 0.1,
              0),
          child: new ListView(
            children: <Widget>[
              new SizedBox(
                width: 200,
                height: 200,
                child: new Image.asset('assets/bull.jpg'),
              ),
              new Container(
                child: new Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                padding: new EdgeInsets.all(16),
                alignment: Alignment.center,
              ),
              !otpsent
                  ? new Container(
                      height: phonenoCheck ? null : 50,
                      margin: new EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Flexible(
                            child: new Container(
                              child: new TextField(
                                controller: phoneno,
                                textInputAction: TextInputAction.send,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  suffixIcon: phonenoCheck
                                      ? IconButton(
                                          icon: Icon(Icons.error,
                                              color: Colors.red),
                                          onPressed: () {},
                                        )
                                      : null,
                                  errorText: phonenoCheck
                                      ? "Enter Valid Phone Number"
                                      : null,
                                  isDense: true,
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                  labelText: 'Phone Number',
                                ),
                                onSubmitted: (String value) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : new Container(
                      height: otpCheck ? null : 50,
                      margin: new EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Flexible(
                            child: new Container(
                              child: new TextField(
                                controller: otp,
                                textInputAction: TextInputAction.send,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  suffixIcon: otpCheck
                                      ? IconButton(
                                          icon: Icon(Icons.error,
                                              color: Colors.red),
                                          onPressed: () {},
                                        )
                                      : null,
                                  errorText: otpCheck ? "Wrong OTP" : null,
                                  isDense: true,
                                  prefixIcon: Icon(Icons.phone),
                                  border: OutlineInputBorder(),
                                  labelText: 'OTP',
                                ),
                                onSubmitted: (String value) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              otpsent
                  ? new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new MaterialButton(
                          height: 40,
                          child: new Text(
                            "Use different number",
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () {
                            setState(() {
                              otpsent = false;
                              phoneno.text = "";
                              phonenoCheck = false;
                            });
                          },
                        ),
                        new MaterialButton(
                          height: 40,
                          child: new Text(
                            "Resend OTP",
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () async {
                            setState(() {
                              otpsent = true;
                            });
                            _verifyPhoneNumber();
                          },
                        )
                      ],
                    )
                  : new Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {};

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneno.text,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: otp.text,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        prefs.setString("phone", phoneno.text);
        phone = phoneno.text;

        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => new DashboardActivity()));
      } else {
        otpCheck = true;
      }
    });
  }
}
