import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;

class OrderPlaced extends StatefulWidget {
  @override
  _OrderPlacedState createState() => _OrderPlacedState();
}

class _OrderPlacedState extends State<OrderPlaced> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/Home', (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("ORDER PLACED",
              style: TextStyle(color: cnst.appPrimaryMaterialColor2)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: cnst.appPrimaryMaterialColor2),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/Home', (Route<dynamic> route) => false);
            },
          ),
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "images/correct.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.fill,
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text("ORDER PLACED",
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
                Text("SUCCESSFULLY !",
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700)),
                SizedBox(height: 20),
                Text(
                  "Our delivery boy connect with you shortly. ",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ), SizedBox(height: 20),Container(
                  width: MediaQuery.of(context).size.width/1.5,
                  margin: EdgeInsets.only(top: 20),
                  height: 45,
                  decoration: BoxDecoration(
                      color: cnst.appPrimaryMaterialColor2,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),

                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/Home', (Route<dynamic> route) => false);
                    },
                    child: Text(
                      "TRACK ORDER",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
