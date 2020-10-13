import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Screen/Home.dart';
import 'package:pickndeliver/Screen/OTP.dart';
import 'package:pickndeliver/Screen/TermsAndCondition.dart';

import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController edtName = new TextEditingController();
  TextEditingController edtEmail = new TextEditingController();
  TextEditingController edtMobileNo = new TextEditingController();
  TextEditingController edtReferalCode = new TextEditingController();
  bool privacyPolicy = false;
  ProgressDialog pr;
  bool isValid = false;
  List Signupdata = [];
  String OtpStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOtpStatus();
    /*new Future.delayed(Duration.zero, () {
      showDialog(context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new Container(child: TermsAndCondition());
          });
    });*/
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
  }

  shareprefrenceData(data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(cnst.Session.Id, data[0]["_id"]);
    prefs.setString(cnst.Session.Name, data[0]["name"]);
    prefs.setString(cnst.Session.Email, data[0]["email"]);
    prefs.setString(cnst.Session.Mobile, data[0]["mobileNo"]);
    prefs.setString(cnst.Session.RegCode, data[0]["regCode"]);
    prefs.setString(cnst.Session.IsVerified, data[0]["isverified"].toString());

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        (Route<dynamic> route) => false);
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

  SignUp() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();
        setState(() {
          isLoading = true;
        });

        var data = {
          "name": edtName.text,
          "mobileNo": edtMobileNo.text,
          "email": edtEmail.text,
          "referalCode": edtReferalCode.text
        };
        Services.SignUp(data).then((data) async {
          pr.hide();
          if (data.IsSuccess == true && data.Content.length > 0) {
            setState(() {
              Signupdata = data.Content;
            });
            pr.hide();
            if (OtpStatus == "0") {
              shareprefrenceData(Signupdata);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OTP(
                      mobileNo: Signupdata[0]["mobileNo"].toString(),
                      onSuccess: () {
                        shareprefrenceData(Signupdata);
                      },
                    ),
                  ));
            }
          } else {
            pr.hide();
            showMsg(data.Message);
          }
        }, onError: (e) {
          pr.hide();
          showMsg("Try Again.");
        });
      } else {
        setState(() {
          isLoading = false;
        });
        pr.hide();
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Pick n Delivere"),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Form(
        key: _formkey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top + 10),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 27,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Let's Create Your Account",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 17,
                        fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              SizedBox(height: 45),
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text("Mandatory *",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12)),
                    ),
                  ),
                  TextFormField(
                    validator: (String value) {
                      if (value.trim() == "") {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    controller: edtName,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'NAME',
                        counterText: ""),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text("Mandatory *",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12)),
                    ),
                  ),
                  TextFormField(
                    controller: edtEmail,
                    validator: (String value) {
                      Pattern pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(value))
                        return 'Enter Valid Email';
                      else
                        return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'email',
                        counterText: ""),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text("Mandatory *",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 12)),
                    ),
                  ),
                  TextFormField(
                    validator: (String value) {
                      if (value.trim() == "") {
                        return "Mobile Number Can't be empty";
                      } else if (value.length != 10) {
                        return "Please Enter 10 Digit Mobile Number";
                      }
                      return null;
                    },
                    controller: edtMobileNo,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'MOBILE',
                        counterText: ""),
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  /*Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text("Optional",
                          style: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  TextFormField(
                    controller: edtReferalCode,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'REFERAL CODE',
                        counterText: ""),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 10),*/
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: privacyPolicy,
                        onChanged: (value) {
                          setState(() {
                            privacyPolicy = value;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/TermsAndCondition');
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "I agree to the ",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                                Text(
                                  "Terms & Conditions",
                                  style: TextStyle(
                                      color: cnst.appPrimaryMaterialColor2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
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
                          if (privacyPolicy == false) {
                            Fluttertoast.showToast(
                                msg: "Please agree Terms & Condition");
                          } else {
                            SignUp();
                          }
                        }
                      },
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Already have an Account?  ",
                            style: TextStyle(
                                fontSize: 17, color: Colors.grey.shade600)),
                        Text("Sign In",
                            style: TextStyle(
                                fontSize: 17,
                                color: cnst.appPrimaryMaterialColor2,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
