import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickndeliver/Common/ClassList.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExpense extends StatefulWidget {
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController txtDescription = new TextEditingController();
  TextEditingController txtAmount = new TextEditingController();
  TextEditingController txtExpenseSource = new TextEditingController();

  bool isLoading = false;
  String currentMode,incomeType;
  List<String> allExpensesName = ["Select Expenses"];
  List allExpenses = [];
  List<String> IncomeType = ["Select Income Type"];

  @override
  void initState() {
    IncomeType.add("Cash");
    IncomeType.add("Online");
    // _getExpenseData();
    super.initState();
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

  _onSourceSelect(val) {
    setState(() {
      print(val);
      currentMode = val;
    });
  }

  _getExpenseData() async {
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
              allExpenses = data["Data"];
              isLoading = false;
            });
            for(int i=0;i<allExpenses.length;i++){
              if(!allExpensesName.contains(allExpenses[i]["expenseCategory"]["name"])) {
                allExpensesName.add(allExpenses[i]["expenseCategory"]["name"]);
              }
            }
          } else {
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

  String addedExpenseId = "";
  _addExpense(String name) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "name" : name,
        };
        Future res = Services.addExpenseName(data);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data["Data"] != null && data["Data"].length > 0) {
            setState(() {
              allExpensesName.add(data["Data"][0]["name"]);
              isLoading = false;
              addedExpenseId = data["Data"][0]["_id"];
            });
          } else {
            setState(() {
              isLoading = false;
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

  addNewExpense(String expenseId,String paymentType,String description,String amount) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
        "expenseCategory" : expenseId,
        "amount" : amount,
        "description" : description,
        'paymentType'  :paymentType
    };
        Future res = Services.addNewExpenseEntry(data);
        res.then((data) async {
          if (data["Data"] != null && data["Data"].length > 0) {
            Navigator.pushReplacementNamed(context, "/Expense");
            Fluttertoast.showToast(
                msg: "Expense Added Successfully",
                backgroundColor: cnst.appPrimaryMaterialColor2,
                textColor: Colors.white,
                gravity: ToastGravity.TOP,
                toastLength: Toast.LENGTH_LONG);
          }
          else {

          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  void _showExpenseSourceDailog() {
    setState(() {
      txtExpenseSource.text = "";
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Add Expense Source"),
          content: TextFormField(
            controller: txtExpenseSource,
            scrollPadding: EdgeInsets.all(0),
            decoration: InputDecoration(hintText: "Expense Source Name"),
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Add",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                bool alreadyExist = false;
                for(int i=0;i<allExpensesName.length;i++){
                  if(allExpensesName[i].contains(txtExpenseSource.text)){
                    alreadyExist = true;
                    break;
                  }
                }
                if(alreadyExist){
                  Fluttertoast.showToast(
                      msg: "This Expense Already Exists!",
                      backgroundColor: cnst.appPrimaryMaterialColor2,
                      textColor: Colors.white,
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_LONG);
                }
                else{
                  _addExpense(txtExpenseSource.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onPaymentModeSelect(val) {
    setState(() {
      incomeType = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Expense");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Add Expense",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Expense");
            },
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 15, left: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: SizedBox(
                            height: 60,
                            child: InputDecorator(
                              decoration: new InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(10),
                                    //borderSide: new BorderSide(),
                                  )),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                hint: Text("Select Expense Type"),
                                value: currentMode,
                                onChanged: (val) {
                                  _onSourceSelect(val);
                                },
                                    items: allExpensesName.map((String value) {
                                      return new DropdownMenuItem<dynamic>(
                                        value: value,
                                        child: new Text(value),
                                      );
                                    }).toList(),
                              )),
                            ),
                          )),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _showExpenseSourceDailog();
                              })
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      SizedBox(
                        height: 60,
                        child: InputDecorator(
                          decoration: new InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10),
                                //borderSide: new BorderSide(),
                              )),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                            hint: Text("Select Payment Mode"),
                                value: incomeType,
                                onChanged: (val) {
                                  _onPaymentModeSelect(val);
                                },
                                items: IncomeType.map((String value) {
                                  return new DropdownMenuItem<dynamic>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                          )),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          bottom: 10,
                          top: 10,
                        ),
                        child: TextFormField(
                          controller: txtDescription,
                          scrollPadding: EdgeInsets.all(0),
                          decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.sms_failed,
                              ),
                              hintText: "Description"),
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: txtAmount,
                          scrollPadding: EdgeInsets.all(0),
                          decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.attach_money,
                              ),
                              hintText: "Amount"),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 10),
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: cnst.appPrimaryMaterialColor2,
                          minWidth: MediaQuery.of(context).size.width - 20,
                          onPressed: () {
                            if(currentMode==null || incomeType==null || txtDescription.text=="" || txtAmount.text==""){
                              Fluttertoast.showToast(
                                  msg: "Please fill all fields",
                                  backgroundColor: cnst.appPrimaryMaterialColor2,
                                  textColor: Colors.white,
                                  gravity: ToastGravity.TOP,
                                  toastLength: Toast.LENGTH_LONG);
                            }
                            else{
                              String expenseId="";
                              for(int i=0;i<allExpenses.length;i++){
                                print(allExpenses);
                                if(currentMode==allExpenses[i]["expenseCategory"]["name"]){
                                  expenseId = allExpenses[i]["expenseCategory"]["_id"];
                                  break;
                                }
                              }
                              if(expenseId!="") {
                                addNewExpense(expenseId, incomeType,
                                    txtDescription.text, txtAmount.text);
                              }
                              else{
                                print("expenseId is empty");
                                addNewExpense(addedExpenseId, incomeType,
                                    txtDescription.text, txtAmount.text);
                              }
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
