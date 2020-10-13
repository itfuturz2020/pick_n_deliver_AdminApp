import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Screen/Home.dart';
import 'package:pickndeliver/Screen/OTP.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController edtMobileNo = new TextEditingController();
  ProgressDialog pr;
  bool isValid = false;
  List logindata = [];
  String OtpStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOtpStatus();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
  }

  Future<Null> validate(StateSetter updateState) async {
    print("in validate : ${edtMobileNo.text.length}");
    if (edtMobileNo.text.length == 10) {
      updateState(() {
        isValid = true;
      });
    }
  }

  _getOtpStatus() async {
    Services.CheckOtp().then((data) async {
      if (data.IsSuccess == true) {
        setState(() {
          isLoading = false;
          OtpStatus = data.Data;
        });
        print("Otp Status-------$OtpStatus");
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Pick n Delivere"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                pr.hide();
                edtMobileNo.text = "";
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  shareprefrenceData(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(cnst.Session.Id, logindata[0]["_id"]);
    prefs.setString(cnst.Session.Name, logindata[0]["name"]);
    prefs.setString(cnst.Session.Email, logindata[0]["email"]);
    prefs.setString(cnst.Session.Mobile, logindata[0]["mobileNo"]);
    prefs.setString(cnst.Session.RegCode, logindata[0]["regCode"]);
    prefs.setString(
        cnst.Session.IsVerified, logindata[0]["isverified"].toString());

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
            (Route<dynamic> route) => false);
  }

  CheckLogin() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();

        var data = {
          "mobileNo": edtMobileNo.text,
        };
        Services.CustomerLogin(data).then((data) async {
          if (data.IsSuccess == true && data.Content.length > 0) {
            pr.hide();
            setState(() {
              logindata = data.Content;
            });

            if (isValid) {
              if (OtpStatus == "0") {
                shareprefrenceData(data);
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OTP(
                        mobileNo: logindata[0]["mobileNo"].toString(),
                        onSuccess: () {
                          shareprefrenceData(logindata);
                        },
                      ),
                    ));
              }
            }
          } else {
            pr.hide();
            showMsg("This number is not Registered Please Sign up");
            //showMsg(data.Message);
          }
        }, onError: (e) {
          pr.hide();
          showMsg("Try Again.");
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter state) {
      return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Welcome",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Sign In to Continue",
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 17,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    Center(
                      child: Image.asset("images/logo.png",
                          width: 200.0, height: 75.0, fit: BoxFit.fill),
                    ),
                    Column(
                      children: <Widget>[
                        TextFormField(
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          validator: (String value) {
                            if (value.trim() == "") {
                              return "Mobile Number can't be empty";
                            } else if (value.length != 10) {
                              return 'Please enter 10 digit Mobile Number';
                            }
                            return null;
                          },
                          controller: edtMobileNo,
                          onChanged: (text) {
                            validate(state);
                          },
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.only(top: 22, bottom: 18, left: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              hintText: 'Mobile Number',
                              counterText: ""),
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 20),
                          height: 45,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    cnst.appPrimaryMaterialColor2,
                                    cnst.appPrimaryMaterialColor1
                                  ]),
                              borderRadius: BorderRadius.all(Radius.circular(6))),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0)),
                            //color: cnst.appPrimaryMaterialColor1,
                            minWidth: MediaQuery.of(context).size.width - 20,
                            onPressed: () {
                              if (_formkey.currentState.validate()) {
                                CheckLogin();
                              }
                            },
                            child: Text(
                              "SIGN IN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 1,
                          width: MediaQuery.of(context).size.width / 2.8,
                          child: Container(color: Colors.grey.shade500),
                        ),
                        Text("OR",
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey.shade500)),
                        SizedBox(
                          height: 1,
                          width: MediaQuery.of(context).size.width / 2.8,
                          child: Container(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/SignUp');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Don't have an Account?  ",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.grey.shade600)),
                              Text("Sign Up",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: cnst.appPrimaryMaterialColor2,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ));
    });
  }
}
