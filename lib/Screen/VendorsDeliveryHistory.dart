import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:pickndeliver/Screen/SingleVendorOrderDetail.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pulltorefresh;
import '../Common/Constants.dart' as cnst;
import 'EmployeeDeliveryDetail.dart';

class VendorsDeliveryHistory extends StatefulWidget {
  String startdate = "", enddate = "";

  VendorsDeliveryHistory({this.startdate, this.enddate});

  @override
  _VendorsDeliveryHistoryState createState() => _VendorsDeliveryHistoryState();
}

class _VendorsDeliveryHistoryState extends State<VendorsDeliveryHistory> {
  List VendorData = [], specificdatelist = [], VendorsId = [],copyofVendorsData=[];
  List selectedDate = [];
  String dateselected = "";
  String dateonselected = "";
  var deliveries, amount=0.0, thirdparty, VendorBill=0.0,VendorName,VendorId,totalOrders=0;
  bool todaysDateData = false;
  bool specificdate = false;
  var onfilteramount;
  var onfilterdeliveries = 0;

  @override
  void initState() {
    super.initState();
    VendorHistoryDataForSingleDay();
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


  VendorHistoryDataForSingleDay({DateTime dateSelected}) async {
    try {
      VendorData.clear();
      VendorsId.clear();
      copyofVendorsData.clear();
      totalOrders=0;
      amount=0.0;
      var todaysdate, currentdate;
      todaysdate =
          dateSelected.toString().split(" ")[0].replaceAll("-", "/").split("/");
      currentdate = DateTime.now()
          .toString()
          .split(" ")[0]
          .replaceAll("-", "/")
          .split("/");
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      var data;
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (dateSelected == null) {
          data = {
            "ofDate":
                (currentdate[2] + "/" + currentdate[1] + "/" + currentdate[0])
                    .toString(),
          };
        } else {
          data = {
            "ofDate":
                (todaysdate[2] + "/" + todaysdate[1] + "/" + todaysdate[0])
                    .toString(),
          };
        }
        print("data");
        print(data);
        Services.VendorDataSingleDate(data).then((data) async {
          if (data["Data"] != 0) {
            todaysDateData = true;
            setState(() {
              VendorData = data["Data"];
            });
            for(int i=0;i<VendorData.length;i++){
              if(!copyofVendorsData.contains(VendorData[i]["VendorId"])){
                copyofVendorsData.add(VendorData[i]["VendorId"]);
              }
            }
            for(int i=0;i<copyofVendorsData.length;i++){
              numberOfOrders=0;
              VendorBill = 0.0;
              VendorName = "";
              VendorId = "";
              for(int j=0;j<VendorData.length;j++){
                if (copyofVendorsData[i] == VendorData[j]["VendorId"]) {
                  numberOfOrders += 1;
                  VendorBill += VendorData[j]["VendorBill"];
                  VendorName = VendorData[j]["VendorName"];
                  VendorId = VendorData[j]["VendorId"];
                }
              }
              VendorsId.add({
              "numberOfOrders" : numberOfOrders,
              "VendorsBill" : VendorBill,
                "VendorName" : VendorName,
                "VendorId" : VendorId
              }
              );
              print("VendorsId");
              print(VendorsId);
              totalOrders +=numberOfOrders;
              amount +=VendorBill;
            }
            // deliveries = data["TotalDelivery"];
            // amount = data["TotalAmount"];
            // thirdparty = data["TotalThirdParty"];
            getEmployeedata();
          } else {
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

  List<DataRow> vendorDataList = [];
  int numberOfOrders;

  Widget getEmployeedata() {
    vendorDataList.clear();
    print(VendorsId.length);
    for (int i = 0; i < VendorsId.length; i++) {
      // if (!vendorDataList.contains(
      //   DataRow(
      //     cells: <DataCell>[
      //       DataCell(
      //         Text(
      //           "${VendorsId[i]["VendorName"]}",
      //           style: TextStyle(
      //             color: Colors.black,
      //           ),
      //         ),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => SingleEmployeeDeliveryDetail(
      //               EmployeeId: VendorsId[i]["VendorId"],
      //               EmployeeName: VendorsId[i]["VendorName"],
      //             ),
      //           ),
      //         ),
      //       ),
      //       DataCell(
      //         Text(
      //           "${VendorsId[i]["numberOfOrders"]}",
      //         ),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => SingleEmployeeDeliveryDetail(
      //               EmployeeId: VendorsId[i]["VendorId"],
      //               EmployeeName: VendorsId[i]["VendorName"],
      //             ),
      //           ),
      //         ),
      //       ),
      //       DataCell(
      //         Text(
      //           "${VendorsId[i]["VendorsBill"]}",
      //         ),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => SingleEmployeeDeliveryDetail(
      //               EmployeeId: VendorsId[i]["VendorId"],
      //               EmployeeName: VendorsId[i]["VendorName"],
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // )) {
        vendorDataList.add(
          DataRow(
            cells: <DataCell>[
              DataCell(
                Text(
                  "${VendorsId[i]["VendorName"]}",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleVendorOrderDetail(
                      VendorId: VendorsId[i]["VendorId"],
                      VendorName: VendorsId[i]["VendorName"],
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${VendorsId[i]["numberOfOrders"]}",
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleVendorOrderDetail(
                      VendorId: VendorsId[i]["VendorId"],
                      VendorName: VendorsId[i]["VendorName"],
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${VendorsId[i]["VendorsBill"]}",
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleVendorOrderDetail(
                      VendorId: VendorsId[i]["VendorId"],
                      VendorName: VendorsId[i]["VendorName"],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        vendorDataList.remove(
          DataRow(
          cells: <DataCell>[
            DataCell(
              Text(
                "${VendorsId[i]["VendorName"]}",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeId: VendorsId[i]["VendorId"],
                    EmployeeName: VendorsId[i]["VendorName"],
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                "${VendorsId[i]["numberOfOrders"]}",
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeId: VendorsId[i]["VendorId"],
                    EmployeeName: VendorsId[i]["VendorName"],
                  ),
                ),
              ),
            ),
            DataCell(
              Text(
                "${VendorsId[i]["VendorsBill"]}",
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleEmployeeDeliveryDetail(
                    EmployeeId: VendorsId[i]["VendorId"],
                    EmployeeName: VendorsId[i]["VendorName"],
                  ),
                ),
              ),
            ),
          ],
        ),
        );
      // }
    }
  }

  Future<void> _getData() async {
    print("refreshed");
    if (todaysDateData) {
      await VendorHistoryDataForSingleDay();
    }
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
          "Vendor's History",
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
                  onTap: () async {
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
                      amount = 0.0;
                      totalOrders = 0;
                      dateonselected = picked.toString().split(" ")[0];
                      setState(() {
                        dateselected = picked.toString();
                      });
                      // datafiltered(picked);
                      vendorDataList.clear();
                      VendorHistoryDataForSingleDay(dateSelected: picked);
                    }
                  },
                  child: new Text(
                    specificdate
                        ? dateselected
                                .toString()
                                .split(" ")[0]
                                .toString()
                                .split("-")[1] +
                            "-" +
                            dateselected
                                .toString()
                                .split(" ")[0]
                                .toString()
                                .split("-")[2]
                        : "Select-Date",
                    style: TextStyle(fontSize: 15, color: Colors.deepPurple),
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
      body: VendorData.length == 0
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
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
                                    'Orders',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Total\nBill\n(Rs.)',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                              rows: vendorDataList,
                            );
                          }),
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
                          "${totalOrders}",
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
