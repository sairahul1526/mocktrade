import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './dashboard.dart';
import '../utils/utils.dart';
import '../utils/config.dart';

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
  bool verifyotp = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
                child: new Text('Login',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
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
                                  prefixIcon: new Icon(Icons.phone),
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
                              verifyotp = false;
                              otp.text = "";
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
                              otp.text = "";
                              otpsent = true;
                              verifyotp = false;
                            });
                            _verifyPhoneNumber();
                          },
                        )
                      ],
                    )
                  : new Container(),
              new Container(
                margin: new EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: new MaterialButton(
                  color: Colors.blue,
                  height: 40,
                  child: new Text(
                    otpsent ? "Verify OTP" : "Send OTP",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (otpsent && !verifyotp) {
                      verifyotp = true;
                      _signInWithPhoneNumber();
                    } else {
                      setState(() {
                        otpsent = true;
                      });
                      _verifyPhoneNumber();
                    }
                  },
                ),
              ),
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

        Firestore.instance.collection("phone").document(phoneno.text).setData({
          "last_login": DateTime.now().millisecondsSinceEpoch,
        }).then((onValue) {
          Firestore.instance
              .collection("marketwatch")
              .document(phoneno.text)
              .collection("amount")
              .document("amount")
              .get()
              .then((DocumentSnapshot ds) {
            if (!ds.exists) {
              Firestore.instance
                  .collection("marketwatch")
                  .document(phoneno.text)
                  .collection("amount")
                  .document("amount")
                  .setData({
                "total": 100000,
              }).then((onValue) {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new DashboardActivity()));
              });
            } else {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(
                  builder: (BuildContext context) => new DashboardActivity()));
            }
          });
        });
      } else {
        otpCheck = true;
      }
    });
  }
}
