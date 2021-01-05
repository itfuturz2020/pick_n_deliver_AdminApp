import 'dart:io';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;
import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pulltorefresh;

import 'EachEmployeeDeliveryDetailData.dart';
import 'EachVendorOrderDetailData.dart';

class SingleVendorOrderDetail extends StatefulWidget {
  String VendorId = "", VendorName = "";

  SingleVendorOrderDetail({this.VendorId, this.VendorName});

  @override
  _SingleVendorOrderDetailState createState() =>
      _SingleVendorOrderDetailState();
}

class _SingleVendorOrderDetailState
    extends State<SingleVendorOrderDetail> {
  int length;
  List eachVendorData = [], specificdatelist = [];
  var totaldeliveries, totalPNDBill,totalthirdparty;
  bool specificdate;
  var onfilteramount;
  var onfilterPNDBill;
  var amount;
  var thirdparty;
  var onfilterthirdparty;
  int toppadding=0;
  var onfilterdeliveries = 0;
  var onfilterBill = 0.0;
  List selectedDate=[];
  String dateonselected = "";

  @override
  void initState() {
    print(widget.VendorId);
    // length = int.parse(widget.EmployeeData[widget.index]["Noofdeliveries"]);
    // TODO: implement initState
    EachVendorData();
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

  EachVendorData() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"vendorId": widget.VendorId.toString()};
        Services.EachVendorOrderData(data).then((data) async {
          if (data.isNotEmpty) {
            setState(() {
              eachVendorData = data["Data"];
            });
            totaldeliveries = data["DeliveryCount"];
            totalPNDBill  = data["PNDBill"].roundToDouble();
            // totalthirdparty = data["TotalThirdPartyCollection"];
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
    totalPNDBill = 0;
    onfilterBill=0.0;
    for (int i = 0; i < eachVendorData.length; i++) {
      if (DateTime.parse(eachVendorData[i]["DeliveryDate"].toString().split("T")[0]).compareTo(pickeddate[0]) >= 0
          && DateTime.parse(eachVendorData[i]["DeliveryDate"].toString().split("T")[0]).compareTo(pickeddate[1]) <= 0) {
        specificdatelist.add(eachVendorData[i]);
        print(eachVendorData[i]["VendorBill"].runtimeType);
        amount = eachVendorData[i]["VendorBill"];
        onfilterBill = (onfilterBill + amount).roundToDouble();
        // thirdparty = eachVendorData[i]["additionalAmount"];
        // onfilterthirdparty = onfilterthirdparty + thirdparty;
        // onfilteramount = onfilteramount + amount;

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
          title: Text("${widget.VendorName}"),
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
        body: eachVendorData.length == 0
            ? Center(
          child: CircularProgressIndicator(),
        )
            : eachVendorData.length == 0 && specificdate
            ? Center(
          child: Text("No Data Found"),
        )
            : Stack(
          children: [
            !specificdate
                ? eachVendorData.length == 0
                ? Center(
              child: Text(
                "No Data Found!!!",
              ),
            )
                : new ListView.builder(
                itemCount: eachVendorData.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return EachVendorOrderDetailData(
                    eachVendorData: eachVendorData[index],
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
                        return EachVendorOrderDetailData(
                          eachVendorData: eachVendorData[index],
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
                      "${totalPNDBill}" + " /-",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    )
                        : Text(
                      "${onfilterBill}" + " /-",
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
