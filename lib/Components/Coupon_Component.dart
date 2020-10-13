import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Screen/AddNewOrder.dart';

class Coupon_Component extends StatefulWidget {
  var couponList;
  int index;
  Coupon_Component(this.couponList,this.index);
  @override
  _Coupon_ComponentState createState() => _Coupon_ComponentState();
}

class _Coupon_ComponentState extends State<Coupon_Component> {

  String setDate(String date) {
    String final_date = "";
    var tempDate;
    if (date != "" || date != null) {
      tempDate = date.toString().split("-");
      if (tempDate[2].toString().length == 1) {
        tempDate[2] = "0" + tempDate[2].toString();
      }
      if (tempDate[1].toString().length == 1) {
        tempDate[1] = "0" + tempDate[1].toString();
      }
      final_date = date == "" || date == null
          ? ""
          : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
          .toString();
    }
    return final_date;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: (){
          Navigator.pop(context,widget.couponList["code"].toString());
        },
      child: Padding(
        padding: const EdgeInsets.only(left:4.0,right: 4.0),
        child: Card(
          elevation: 1,
          child: Row(
            children: <Widget>[
              Container(
                 height: 80,
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                        child: Image.network(cnst.IMG_URL+
                        '${widget.couponList["image"]}',fit: BoxFit.fill),
                  )),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("${widget.couponList["title"]}",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("${widget.couponList["description"]}",style: TextStyle(fontSize: 14,color: Colors.grey),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("",style: TextStyle(fontSize: 14,color: Colors.black54)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 25,
                        width: 110,
                        decoration: BoxDecoration(
                            color: cnst.appPrimaryMaterialColor1[700],
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(child: Text("${widget.couponList["code"]}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
                      ),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
