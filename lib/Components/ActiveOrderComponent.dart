import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Screen/ActiveOrderDetails.dart';

class ActiveOrderComponent extends StatefulWidget {
  var activeOrder;

  ActiveOrderComponent({this.activeOrder});

  @override
  _ActiveOrderComponentState createState() => _ActiveOrderComponentState();
}

class _ActiveOrderComponentState extends State<ActiveOrderComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ActiveOrderDetails(orderData: widget.activeOrder),
            ),
          );
        },
        child: Card(
            elevation: 2,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("${cnst.Inr_Rupee} ${widget.activeOrder["finalAmount"]}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${widget.activeOrder["orderNo"]}",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text("${widget.activeOrder["note"]}",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.green.shade500,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          height: 13,
                          width: 13,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cnst.appPrimaryMaterialColor2),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text("${widget.activeOrder["pickupPoint"]["completeAddress"] +" - "+ widget.activeOrder["pickupPoint"]
                            ["address"]}"),
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.5),
                      child: SizedBox(
                        height: 20,
                        width: 2,
                        child: Container(color: cnst.appPrimaryMaterialColor2),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 13,
                          width: 13,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cnst.appPrimaryMaterialColor2,
                                    width: 2)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(widget.activeOrder["deliveryPoint"]
                                ["completeAddress"] + widget.activeOrder["deliveryPoint"]
                            ["address"] ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
