import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;

class Help extends StatefulWidget {
  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  TextEditingController edtName = new TextEditingController();
  TextEditingController edtMobileNo = new TextEditingController();
  TextEditingController edtMessage = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("HELP"),
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                cnst.appPrimaryMaterialColor2,
                cnst.appPrimaryMaterialColor1
              ]))),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "We'are Happy\nto hear from you !!!",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 27,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Customer Care-Supoort 24x7",
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    "Your Query",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 27,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 30),
                Column(
                  children: <Widget>[
                    Container(
                      height: 55,
                      child: TextFormField(
                        controller: edtName,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "FULL NAME"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: edtMobileNo,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "ENTER MOBILE"),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: edtMessage,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "MESSAGE"),
                        keyboardType: TextInputType.multiline,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 30, bottom: 15),
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
                        onPressed: () {},
                        child: Text(
                          "SUBMIT NOW",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
