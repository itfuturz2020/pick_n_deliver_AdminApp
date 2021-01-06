import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pickndeliver/Common/Services.dart';
import '../Common/Constants.dart' as cnst;
import 'ExpenseComponent.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;


class Expense extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  String month = "";
  var amount;

  DateTime selectedDate = DateTime.now();

  List _expenseData = [],specificdatelist=[];
  bool isLoading = false;
  List selectDate=[],firstDate=[],lastDate=[];
  bool specificdate = false;

  @override
  void initState() {
    _expenseData.clear();
    _getExpenseData();
  }

  _getExpenseData() async {
    amount = 0;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.AllExpensesList();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data["Data"] != null && data["Data"].length > 0) {
            setState(() {
              _expenseData = data["Data"];
              isLoading = false;
            });
            for(int i=0;i<_expenseData.length;i++){
              amount = amount + _expenseData[i]["amount"];
            }
          } else {
            setState(() {
              isLoading = false;
              _expenseData = data["Data"];
            });
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  showMsg(String msg, {String title = 'My JINI'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
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

  String setDate(String date) {
    String final_date = "";
    var tempDate;
    if (date != "" || date != null) {
      tempDate = date.toString().split("-");
      if (tempDate[2].toString().length == 1) {
        tempDate[2] = "0" + tempDate[2].toString();
      }
      if (tempDate[1].toString().length == 1) {
        tempDate[1] = "0" + tempDate[1].toString();
      }
    }
    final_date = date == "" || date == null
        ? ""
        : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
        .toString();

    return final_date;
  }

  setMonth(DateTime date) {
    switch (date.month) {
      case 1:
        setState(() {
          month = "Jan";
        });
        break;
      case 2:
        setState(() {
          month = "Feb";
        });
        break;
      case 3:
        setState(() {
          month = "Mar";
        });
        break;
      case 4:
        setState(() {
          month = "Apr";
        });
        break;
      case 5:
        setState(() {
          month = "May";
        });
        break;
      case 6:
        setState(() {
          month = "Jun";
        });
        break;
      case 7:
        setState(() {
          month = "Jul";
        });
        break;
      case 8:
        setState(() {
          month = "Aug";
        });
        break;
      case 9:
        setState(() {
          month = "Sep";
        });
        break;
      case 10:
        setState(() {
          month = "Oct";
        });
        break;
      case 11:
        setState(() {
          month = "Nov";
        });
        break;
      case 12:
        setState(() {
          month = "Dec";
        });
        break;
    }
  }

  List filteredData=[];
  datafiltered(String startdate,String enddate) {
    amount=0;
    print(startdate);
    print(enddate);
    filteredData.clear();
    print(_expenseData);
    for (int i = 0; i < _expenseData.length; i++) {
      var date = _expenseData[i]["date"].toString().replaceAll("/", "-").split("-");
      print(date[2]+"-" + date[1] + "-"+date[0]);
      if (DateTime.parse(date[2]+"-" + date[1] + "-"+date[0]).compareTo(DateTime.parse(startdate)) >= 0
          && DateTime.parse(date[2]+"-"+date[1]+"-"+date[0]).compareTo(DateTime.parse(enddate)) <= 0) {
        print("found");
        filteredData.add(_expenseData[i]);
        amount = amount+ _expenseData[i]["amount"];
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Orders");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Orders");
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/AddExpense");
              },
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 3, right: 3, top: 2, bottom: 2),
                        child: Text(
                          "Add\nExpense",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ))),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top:20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.5,
                      ),
                      Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                      GestureDetector(
                        onTap: () async{
                          final List<DateTime> picked = await DateRangePicker.showDatePicker(
                              context: context,
                              initialFirstDate: new DateTime.now(),
                              initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
                              firstDate: new DateTime(2020),
                              lastDate: new DateTime(2025)
                          );
                          if (picked != null && picked.length == 2) {
                            print(picked);
                            specificdate = true;
                            firstDate = picked[0].toString().split(" ")[0].split("-");
                            lastDate = picked[1].toString().split(" ")[0].split("-");
                            setState(() {
                              selectDate = picked;
                            });
                            datafiltered(firstDate[0] + "-" + firstDate[1] + "-" + firstDate[2],
                                lastDate[0] + "-" + lastDate[1] + "-" + lastDate[2]);
                          }
                        },
                        child: new  Text(
                          specificdate
                              ? selectDate[0].toString().split(" ")[0].toString().split("-")[1] +
                              "-" +
                              selectDate[0].toString().split(" ")[0].toString().split("-")[2] + " to " +
                              selectDate[1].toString().split(" ")[0].toString().split("-")[1] +
                              "-" +
                              selectDate[1].toString().split(" ")[0].toString().split("-")[2]
                              : "Select-Date",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.purple,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            specificdate && filteredData.length ==0 ?
            Center(child: Padding(
              padding: const EdgeInsets.only(top:50.0),
              child: Text(
                "No Data Found",
              ),
            ),
            ):
            filteredData.length > 0 &&specificdate ?
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount:
                  filteredData.length,
                  itemBuilder:
                      (BuildContext context, int index) {
                    return ExpenseComponent(
                        filteredData[index],
                        index);
                  },
                ),
              ),
            )
                :
            _expenseData.length > 0 && !specificdate
                ? Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount:
                  _expenseData.length,
                  itemBuilder:
                      (BuildContext context, int index) {
                    return ExpenseComponent(
                        _expenseData[index],
                        index);
                  },
                ),
              ),
            ) :
            Center(
              child: Text("No Data Found!"),
            ),
            _expenseData.length > 0
                ? Align(
              alignment: Alignment.bottomCenter,
                  child: Container(
              height: 50,
              padding: EdgeInsets.only(left: 10, right: 15),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey[300])),
                  color: Colors.grey[200],
              ),
              child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "TOTAL EXPENSE",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cnst.appPrimaryMaterialColor1,
                          fontSize: 15),
                    ),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(6)),
                        color: Colors.red,
                      ),
                      alignment: Alignment.center,
                      padding:
                      EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        "${cnst.Inr_Rupee} ${amount}",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ],
              ),
            ),
                )
                : Container(),
          ],
        )
      ),
    );
  }
}
