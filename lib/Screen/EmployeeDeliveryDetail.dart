import 'dart:io';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pulltorefresh;

import 'EachEmployeeDeliveryDetailData.dart';

class SingleEmployeeDeliveryDetail extends StatefulWidget {
  String EmployeeId = "", EmployeeName = "";

  SingleEmployeeDeliveryDetail({this.EmployeeId, this.EmployeeName});

  @override
  _SingleEmployeeDeliveryDetailState createState() =>
      _SingleEmployeeDeliveryDetailState();
}

class _SingleEmployeeDeliveryDetailState
    extends State<SingleEmployeeDeliveryDetail> {
  int length;
  List eachEmployeeData = [], specificdatelist = [];
  var totaldeliveries, totalpricecollected,totalthirdparty;
  bool specificdate;
  var onfilteramount;
  var amount;
  var thirdparty;
  var onfilterthirdparty;
  int toppadding=0;
  var onfilterdeliveries = 0;
  List selectedDate=[];
  String dateonselected = "";

  @override
  void initState() {
    print(widget.EmployeeId);
    // length = int.parse(widget.EmployeeData[widget.index]["Noofdeliveries"]);
    // TODO: implement initState
    EachEmployeeData();
    specificdate = false;
    super.initState();
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
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  EachEmployeeData() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"courierId": widget.EmployeeId.toString()};
        Services.EachEmployeeDeliveryData(data).then((data) async {
          if (data.isNotEmpty) {
            setState(() {
              eachEmployeeData = data["Data"];
            });
            totaldeliveries = data["TotalDelivery"];
            totalpricecollected = data["TotalPriceCollected"];
            totalthirdparty = data["TotalThirdPartyCollection"];
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

  datafiltered(List pickeddate) {
    amount = 0;
    onfilteramount = 0;
    onfilterthirdparty=0;
    for (int i = 0; i < eachEmployeeData.length; i++) {
      if (DateTime.parse(eachEmployeeData[i]["dateTime"].toString().split("T")[0]).compareTo(pickeddate[0]) >= 0
      && DateTime.parse(eachEmployeeData[i]["dateTime"].toString().split("T")[0]).compareTo(pickeddate[1]) <= 0) {
        specificdatelist.add(eachEmployeeData[i]);
        print(eachEmployeeData[i]["finalAmount"].runtimeType);
        amount = eachEmployeeData[i]["finalAmount"];
        thirdparty = eachEmployeeData[i]["additionalAmount"];
        onfilterthirdparty = onfilterthirdparty + thirdparty;
        onfilteramount = onfilteramount + amount;

      }
      onfilterdeliveries = specificdatelist.length;
    }
    setState(() {});
    print("specificdatelist");
    print(specificdatelist.length);
  }

  // _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate, // Refer step 1
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null) {
  //     specificdate = true;
  //     specificdatelist.clear();
  //     dateonselected = picked.toString().split(" ")[0];
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //     datafiltered(picked);
  //   }
  // }

  Future<void> _getData() async {
    setState(() {
      specificdate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("${widget.EmployeeName}"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Row(
                children: [
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
                        specificdatelist.clear();
                        dateonselected = picked.toString().split(" ")[0];
                        setState(() {
                          selectedDate = picked;
                        });
                        datafiltered(picked);
                      }
                    },
                    child: new  Text(
                      specificdate
                          ? selectedDate[0].toString().split(" ")[0].toString().split("-")[1] +
                          "-" +
                          selectedDate[0].toString().split(" ")[0].toString().split("-")[2] + " to " +
                          selectedDate[1].toString().split(" ")[0].toString().split("-")[1] +
                          "-" +
                          selectedDate[1].toString().split(" ")[0].toString().split("-")[2]
                          : "Select-Date",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white
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
          ],
        ),
        body: eachEmployeeData.length == 0
            ? Center(
                child: CircularProgressIndicator(),
              )
            : eachEmployeeData.length == 0 && specificdate
                ? Center(
                    child: Text("No Data Found"),
                  )
                : Stack(
                    children: [
                      !specificdate
                          ? eachEmployeeData.length == 0
                              ? Center(
                                  child: Text(
                                    "No Data Found!!!",
                                  ),
                                )
                              : new ListView.builder(
                                  itemCount: eachEmployeeData.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return EachEmployeeDeliveryDetailData(
                                      eachEmployeeData: eachEmployeeData[index],
                                    );
                                  })
                          : specificdatelist.length == 0
                              ? RefreshIndicator(
                                onRefresh: _getData,
                                child: new ListView.builder(
                                    itemCount: 1,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top:200),
                                          child: Text("No Data Found"),
                                        ),
                                      );
                                    }),
                              )
                              : RefreshIndicator(
                                  onRefresh: _getData,
                                  child: new ListView.builder(
                                      itemCount: specificdatelist.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        return EachEmployeeDeliveryDetailData(
                                          eachEmployeeData:
                                              specificdatelist[index],
                                        );
                                      }),
                                ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "Total ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              !specificdate
                                  ? Text(
                                      "${totaldeliveries}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    )
                                  : Text(
                                      "${onfilterdeliveries}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                              !specificdate
                                  ? Text(
                                      "${totalpricecollected}" + " /-",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    )
                                  : Text(
                                      "${onfilteramount}" + " /-",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                              !specificdate
                                  ? Text(
                                "${totalthirdparty}" + " /-",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              )
                                  : Text(
                                "${onfilterthirdparty}" + " /-",
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
                  ));
  }
}
