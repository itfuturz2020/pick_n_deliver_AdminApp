import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;

import 'package:url_launcher/url_launcher.dart';

class ActiveOrderDetails extends StatefulWidget {
  var orderData;

  ActiveOrderDetails({this.orderData});

  @override
  _ActiveOrderDetailsState createState() => _ActiveOrderDetailsState();
}

class _ActiveOrderDetailsState extends State<ActiveOrderDetails> {
  TextEditingController edtName = new TextEditingController();
  TextEditingController edtMobile = new TextEditingController();
  TextEditingController edtPickUpTime = new TextEditingController();
  TextEditingController edtReceiverName = new TextEditingController();
  TextEditingController edtReceiverMobile = new TextEditingController();
  TextEditingController edtDeliveryTime = new TextEditingController();

  @override
  void initState() {
    edtName.text = widget.orderData["pickupPoint"]["name"];
    edtMobile.text = widget.orderData["pickupPoint"]["mobileNo"];
    edtPickUpTime.text = widget.orderData["pickupPoint"]["arriveTime"];

    edtReceiverName.text = widget.orderData["deliveryPoint"]["name"];
    edtReceiverMobile.text = widget.orderData["deliveryPoint"]["mobileNo"];
    edtDeliveryTime.text = widget.orderData["pickupPoint"]["arriveTime"];
  }

  @override
  Widget build(BuildContext context) {
    print("len : ${widget.orderData["courierId"].length}");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cnst.appPrimaryMaterialColor2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.orderData["orderNo"],
            style: TextStyle(color: cnst.appPrimaryMaterialColor2)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Payable Amount: ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    Text("${cnst.Inr_Rupee} ${widget.orderData["finalAmount"]}",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Text("Total Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                    Text("${cnst.Inr_Rupee} ${widget.orderData["amount"]}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("STATUS:",
                        style: TextStyle(
                            color: cnst.appPrimaryMaterialColor2,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(widget.orderData["note"]),
                      ),
                    ),
                  ],
                ),
                widget.orderData["courierId"].length > 0
                    ? SizedBox(height: 20)
                    : Container(),
                widget.orderData["courierId"].length > 0
                    ? Row(
                        children: <Widget>[
                          ClipOval(
                            child: Image.asset(
                              "images/user.png",
                              width: 80,
                              height: 80,
                            ),
                          ),
                          SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("NAME:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16)),
                                  SizedBox(width: 5),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.2,
                                    child: Text(
                                        "${widget.orderData["courierId"][0]["firstName"]} ${widget.orderData["courierId"][0]["lastName"]}",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15)),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("VEHICAL NO:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16)),
                                  SizedBox(width: 5),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.9,
                                    child: Text(
                                        widget.orderData["courierId"][0]
                                            ["transport"]["vehicleNo"],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15)),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("MOBILE NO:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16)),
                                  SizedBox(width: 5),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2.8,
                                    child: Text(
                                        widget.orderData["courierId"][0]
                                            ["mobileNo"],
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 15)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.call,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              launch(
                                  "tel:${widget.orderData["courierId"][0]["mobileNo"]}");
                            },
                          )
                        ],
                      )
                    : Container(),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
/*
                      Column(
                        children: <Widget>[
                          Text("ORDER DATE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 14)),
                          Text(
                              widget.orderData["pickupPoint"]["arriveTime"]
                                  .toString(),
                              style:
                                  TextStyle(color: Colors.black54, fontSize: 14)),
                        ],
                      ),
*/
                      Column(
                        children: <Widget>[
                          Text(
                              widget.orderData["promoCode"]
                                  .toString(),
                              style:
                              TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold)),
                          Text("PROMO CODE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 10)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                              widget.orderData["pickupPoint"]["contents"]
                                  .toString(),
                              style:
                              TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold)),
                          Text("PARCEL CONTENTS",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                ExpansionTile(
                  title: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cnst.appPrimaryMaterialColor2,
                                    width: 2)),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("1",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: cnst.appPrimaryMaterialColor2,
                                      fontWeight: FontWeight.bold)),
                            ))),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Pickup Point",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          widget.orderData["pickupPoint"]["completeAddress"]
                              .toString(),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      child: TextFormField(
                        controller: edtName,
                        readOnly: true,
                        enabled: false,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Name",
                            labelText: "Name"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      child: TextFormField(
                        controller: edtMobile,
                        readOnly: true,
                        enabled: false,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Mobile Number",
                            labelText: "Mobile Number"),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 15),
/*
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      child: TextFormField(
                        controller: edtPickUpTime,
                        readOnly: true,
                        enabled: false,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Pickup Time",
                            labelText: "Pickup Time"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
*/
                    SizedBox(height: 15),
                  ],
                  backgroundColor: Colors.white,
                ),
                ExpansionTile(
                  title: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cnst.appPrimaryMaterialColor2,
                                    width: 2)),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("2",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: cnst.appPrimaryMaterialColor2,
                                      fontWeight: FontWeight.bold)),
                            ))),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "Delivery Point",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text('${widget.orderData["deliveryPoint"]["completeAddress"]}'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      child: TextFormField(
                        readOnly: true,
                        enabled: false,
                        controller: edtReceiverName,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Receiver Name",
                            labelText: "Receiver Name"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      child: TextFormField(
                        controller: edtReceiverMobile,
                        readOnly: true,
                        enabled: false,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            hintText: "Mobile Number",
                            labelText: "Mobile Number"),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                   /* widget.orderData["status"] != "finding_db"
                        ? Container(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            height: 55,
                            child: TextFormField(
                              controller: edtDeliveryTime,
                              readOnly: true,
                              enabled: false,
                              cursorColor: cnst.appPrimaryMaterialColor2,
                              scrollPadding: EdgeInsets.all(0),
                              decoration: InputDecoration(
                                  counterText: "",
                                  border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText: "Delivery Time",
                                  labelText: "Delivery Time"),
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : Container(),
                    SizedBox(height: 15),*/
                  ],
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}