import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:pickndeliver/Screen/EmployeeDeliveryHistory.dart';
import 'dart:async';
import '../Common/Constants.dart' as cnst;

class EmployeeDeliveryDateFilter extends StatefulWidget {
  EmployeeDeliveryDateFilter({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _EmployeeDeliveryDateFilterState createState() =>
      new _EmployeeDeliveryDateFilterState();
}

class _EmployeeDeliveryDateFilterState
    extends State<EmployeeDeliveryDateFilter> {
  String start = "", end = "";
  List startdate = [];
  List enddate = [];

  void callDatePicker(String date) async {
    var order = await getDate();
    if (date == "start") {
      setState(() {
        start = order.toString();
      });
    } else {
      setState(() {
        end = order.toString();
      });
    }
  }

  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
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
    startdate = start.split(" ");
    enddate = end.split(" ");
    return new Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Employee Delivery History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: cnst.appPrimaryMaterialColor1,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              callDatePicker("start");
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  startdate[0] == "" ? "Select Start Date" : startdate[0],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              callDatePicker("end");
            },
            child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.95,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: Text(
                  enddate[0] == "" ? "Select End Date" : enddate[0],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          new RaisedButton(
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              if (enddate[0] == "" ||
                  startdate[0] == "" ||
                  enddate[0] == null ||
                  startdate[0] == null) {
                showMsg("Please try again");
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDeliveryHistory(
                      startdate: startdate[0],
                      enddate: enddate[0],
                    ),
                  ),
                );
              }
            },
            child: new Text("Search"),
          ),
        ],
      ),
    );
  }
}
