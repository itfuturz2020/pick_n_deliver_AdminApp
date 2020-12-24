import 'package:flutter/material.dart';

import 'EachEmployeeDeliveryDetailData.dart';

class SingleEmployeeDeliveryDetail extends StatefulWidget {

  List EmployeeData = [];
  int index,srNo,deliveriessum,amountsum;
  SingleEmployeeDeliveryDetail({this.EmployeeData,this.index,this.srNo,this.amountsum,this.deliveriessum});

  @override
  _SingleEmployeeDeliveryDetailState createState() => _SingleEmployeeDeliveryDetailState();
}

class _SingleEmployeeDeliveryDetailState extends State<SingleEmployeeDeliveryDetail> {

  int length;

  @override
  void initState() {
    // length = int.parse(widget.EmployeeData[widget.index]["Noofdeliveries"]);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(length);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${widget.EmployeeData[widget.index]["EmployeeName"]}" + "'s Tracking History"),
      ),
        body: Stack(
          children: [
            new ListView.builder
              (
                itemCount: 10,
                itemBuilder: (BuildContext ctxt, int index) {
                  return EachEmployeeDeliveryDetailData(Employeedataone: widget.EmployeeData,index: widget.index,);
                }
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
                      "${length}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "${widget.EmployeeData[widget.index]["totalamountcollected"]}" + " /-",
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
        )
    );
  }
}
