import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickndeliver/Common/Services.dart';
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
  List EmployeeData = [];

  @override
  void initState() {
    super.initState();
    EmployeeHistoryData();
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

  EmployeeOrderDetails() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data =
          {
            "courierId" : "5f6df2e5716f6933d5227c0e",
            "startdate" : "01/11/2020",
            "enddate" : "30/11/2020"
          };
        Services.getEmployeeOrderDetails(data).then((data) async {
          if(data.IsSuccess){
            setState(() {
              EmployeeData = data.Content;
            });
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
            setState(() {
              EmployeeData = data;
            });
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
  int deliveriessum = 0, amountsum = 0, srNo = 0;

  Widget getEmployeedata() {
    for (int i = 0; i < EmployeeData.length; i++) {
      srNo += 1;
      // deliveriessum += int.parse(EmployeeData[i]["Noofdeliveries"]);
      // amountsum += int.parse(EmployeeData[i]["totalamountcollected"]);
      employeedatalist.add(
        DataRow(
          cells: <DataCell>[
            DataCell(
              Text(
                "${EmployeeData[i]["firstName"]}",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeData: EmployeeData,
                    index: i,
                    srNo: srNo,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                "${EmployeeData[i]["Noofdeliveries"]}",
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeData: EmployeeData,
                    index: i,
                    srNo: srNo,
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                "${EmployeeData[i]["totalamountcollected"]}",
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeData: EmployeeData,
                    index: i,
                    srNo: srNo,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Employee Delivery History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: cnst.appPrimaryMaterialColor1,
          ),
        ),
      ),
      body: EmployeeData.length==0 ? Center(child: CircularProgressIndicator()):Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
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
                    'Amount\nCollected',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              rows: employeedatalist,
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
                    "${deliveriessum}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "${amountsum}" + " /-",
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
