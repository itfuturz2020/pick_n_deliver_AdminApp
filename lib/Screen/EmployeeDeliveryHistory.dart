import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:pull_to_refresh/pull_to_refresh.dart' as pulltorefresh;
import '../Common/Constants.dart' as cnst;
import 'EmployeeDeliveryDetail.dart';

class EmployeeDeliveryHistory extends StatefulWidget {
  String startdate="",enddate="";
  EmployeeDeliveryHistory({this.startdate,this.enddate});
  @override
  _EmployeeDeliveryHistoryState createState() =>
      _EmployeeDeliveryHistoryState();
}

class _EmployeeDeliveryHistoryState extends State<EmployeeDeliveryHistory> {
  List EmployeeData = [],specificdatelist = [];
  List selectedDate=[];
  String dateselected="";
  String dateonselected = "";
  var deliveries,amount,thirdparty;
  bool todaysDateData = false;
  bool specificdate = false;
  var onfilteramount;
  var onfilterdeliveries = 0;

  @override
  void initState() {
    super.initState();
    EmployeeHistoryDataForSingleDay();
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

  // EmployeeOrderDetails() async {
  //   try {
  //     //check Internet Connection
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       var data =
  //         {
  //           "courierId" : "5f6df2e5716f6933d5227c0e",
  //           "startdate" : "01/11/2020",
  //           "enddate" : "30/11/2020"
  //         };
  //       Services.getEmployeeOrderDetails(data).then((data) async {
  //         if(data.IsSuccess){
  //           setState(() {
  //             EmployeeData = data.Content;
  //           });
  //           deliveries = data["TotalDelivery"];
  //           getEmployeedata();
  //         }
  //       }, onError: (e) {
  //         showMsg("Try Again.");
  //       });
  //     } else {
  //       showMsg("No Internet Connection.");
  //     }
  //   } on SocketException catch (_) {
  //     showMsg("No Internet Connection.");
  //   }
  // }

  EmployeeHistoryDataForSingleDay({DateTime dateSelected}) async {
    try {
      EmployeeData.clear();
      var todaysdate,currentdate;
      todaysdate = dateSelected.toString().split(" ")[0].replaceAll("-", "/").split("/");
      currentdate = DateTime.now().toString().split(" ")[0].replaceAll("-", "/").split("/");
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      var data;
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if(dateSelected==null){
           data = {
            "ofDate" : (currentdate[2]+"/"+currentdate[1]+"/"+currentdate[0]).toString(),
          };
        }
        else{
           data = {
            "ofDate" : (todaysdate[2]+"/"+todaysdate[1]+"/"+todaysdate[0]).toString(),
          };
        }
        print("data");
        print(data);
        Services.EmployeeDataSingleDate(data).then((data) async {
          if(data["Data"]!=0){
            todaysDateData = true;
            setState(() {
              EmployeeData = data["Data"];
            });
            deliveries = data["TotalDelivery"];
            amount = data["TotalAmount"];
            thirdparty = data["TotalThirdParty"];
            getEmployeedata();
          }
          else{
            showMsg("No Data Found");
          }
        }, onError: (e) {
          showMsg("Try Again.");
        });
      } else {
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  EmployeeHistoryData() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          // "name": edtName.text,
          // "mobileNo": edtMobileNo.text,
          // "email": edtEmail.text,
          // "referalCode": edtReferalCode.text
        };
        Services.EmployeehistoryData(data).then((data) async {
          if(data.isNotEmpty){
            todaysDateData = false;
            setState(() {
              EmployeeData = data["Data"];
              deliveries = data["TotalDelivery"];
              amount = data["TotalAmount"];
            });
            employeedatalist.clear();
            getEmployeedata();
          }
        }, onError: (e) {
          showMsg("Try Again.");
        });
      } else {
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  List<DataRow> employeedatalist = [];

  Widget getEmployeedata() {
    for (int i = 0; i < EmployeeData.length; i++) {
      if(!employeedatalist.contains(DataRow(
        cells: <DataCell>[
          DataCell(
            Text(
              "${EmployeeData[i]["EmployeeName"]}",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleEmployeeDeliveryDetail(
                  EmployeeId : EmployeeData[i]["EmployeeId"],
                  EmployeeName : EmployeeData[i]["EmployeeName"],
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              "${EmployeeData[i]["TotalDelivery"]}",
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleEmployeeDeliveryDetail(
                  EmployeeId : EmployeeData[i]["EmployeeId"],
                  EmployeeName : EmployeeData[i]["EmployeeName"],
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              "${EmployeeData[i]["AmoutCollect"]}",
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleEmployeeDeliveryDetail(
                  EmployeeId : EmployeeData[i]["EmployeeId"],
                  EmployeeName : EmployeeData[i]["EmployeeName"],
                ),
              ),
            ),
          ),
        ],
      ),)){
        employeedatalist.add(
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  "${EmployeeData[i]["EmployeeName"]}",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleEmployeeDeliveryDetail(
                      EmployeeId : EmployeeData[i]["EmployeeId"],
                      EmployeeName : EmployeeData[i]["EmployeeName"],
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${EmployeeData[i]["TotalDelivery"]}",
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleEmployeeDeliveryDetail(
                      EmployeeId : EmployeeData[i]["EmployeeId"],
                      EmployeeName : EmployeeData[i]["EmployeeName"],
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${EmployeeData[i]["AmoutCollect"]}",
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleEmployeeDeliveryDetail(
                      EmployeeId : EmployeeData[i]["EmployeeId"],
                      EmployeeName : EmployeeData[i]["EmployeeName"],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _getData() async {
    print("refreshed");
    if(todaysDateData) {
      await EmployeeHistoryData();
    }
  }

  datafiltered(DateTime pickeddate) {
    amount = 0;
    onfilteramount = 0;
    onfilterdeliveries=0;
    for (int i = 0; i < EmployeeData.length; i++) {
      if (DateTime.parse(EmployeeData[i]["dateTime"].toString().split("T")[0])==pickeddate) {
        specificdatelist.add(EmployeeData[i]);
        print(EmployeeData[i]["TotalPrice"].runtimeType);
        amount = EmployeeData[i]["TotalPrice"];
        onfilteramount = onfilteramount + amount;
        onfilterdeliveries += EmployeeData[i]["TotalDelivery"];
      }
    }
    setState(() {});
    print("specificdatelist");
    print(specificdatelist.length);
  }

  @override
  Widget build(BuildContext context) {
    print(DateTime.now());
    return Scaffold(
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
          'Delivery History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: cnst.appPrimaryMaterialColor1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.deepPurpleAccent,
                ),
                GestureDetector(
                  onTap: () async{
                    final DateTime picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), // Refer step 1
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    // final List<DateTime> picked = await DateRangePicker.showDatePicker(
                    //     context: context,
                    //     initialFirstDate: new DateTime.now(),
                    //     initialLastDate: (new DateTime.now()).add(new Duration(days: 7)),
                    //     firstDate: new DateTime(2020),
                    //     lastDate: new DateTime(2025)
                    // );
                    if (picked != null) {
                      print(picked);
                      specificdate = true;
                      specificdatelist.clear();
                      dateonselected = picked.toString().split(" ")[0];
                      setState(() {
                        dateselected = picked.toString();
                      });
                      // datafiltered(picked);
                      employeedatalist.clear();
                      EmployeeHistoryDataForSingleDay(dateSelected: picked);
                    }
                  },
                  child: new  Text(
                    specificdate
                        ? dateselected.toString().split(" ")[0].toString().split("-")[1] +
                        "-" +
                        dateselected.toString().split(" ")[0].toString().split("-")[2]
                        : "Select-Date",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.deepPurple
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: EmployeeData.length==0 ? Center(child: CircularProgressIndicator()):
      Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              height: MediaQuery.of(context).size.height*0.9,
              child: RefreshIndicator(
                onRefresh: _getData,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return new DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Name',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Deliveries',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Amount\nCollected\n(Rs.)',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                      rows: employeedatalist,
                    );
                  }
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Total ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "${deliveries}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "${amount}" + " /-",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
