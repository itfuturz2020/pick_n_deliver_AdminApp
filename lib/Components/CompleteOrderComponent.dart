import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
class CompleteOrderComponent extends StatefulWidget {
  var completeOrder;

  CompleteOrderComponent({this.completeOrder});

  @override
  _CompleteOrderComponentState createState() => _CompleteOrderComponentState();
}

class _CompleteOrderComponentState extends State<CompleteOrderComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
          elevation: 3,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("${cnst.Inr_Rupee} ${widget.completeOrder["amount"]}",
                          style: TextStyle(fontSize: 18)),
                      Text("${widget.completeOrder["orderNo"]}",
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      "${widget.completeOrder["note"]}",
                      style:
                      TextStyle(fontSize: 15, color: Colors.green.shade500,fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.only(left: 10,top: 8.0),
                            child: Text(widget.completeOrder["pickupPoint"]
                            ["completeAddress"] +" - "+ widget.completeOrder["pickupPoint"]
                            ["address"]
                            ),
                          ))
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
                          decoration: BoxDecoration( color: cnst.appPrimaryMaterialColor2,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: cnst.appPrimaryMaterialColor2,
                                  width: 2)),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(widget.completeOrder["deliveryPoint"]
                            ["completeAddress"] + widget.completeOrder["deliveryPoint"]
                            ["address"] ),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
