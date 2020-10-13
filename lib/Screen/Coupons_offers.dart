import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Components/Coupon_Component.dart';
import 'package:pickndeliver/Components/ShimmerLoading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Coupons_offers extends StatefulWidget {
  @override
  _Coupons_offersState createState() => _Coupons_offersState();
}

class _Coupons_offersState extends State<Coupons_offers> {
  bool isLoading = true;
  List couponsList = [];

  @override
  void initState() {
    _getCouponsOffers();
  }

  _getCouponsOffers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _customerId = prefs.getString(cnst.Session.Id);
    var data = {
      "customerId": _customerId,
    };
    Services.Couponoffers(data).then((data) async {
      if (data.IsSuccess == true) {
        setState(() {
          isLoading = false;
          couponsList = data.Content;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // showMsg(data.Message);
      }
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });

      //showMsg("Try Again.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light, // or use Brightness.dark
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: cnst.appPrimaryMaterialColor1),
        title: Text("Coupons & Offers",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cnst.appPrimaryMaterialColor1)),
      ),
      body: Container(
          color: Colors.grey[100],
          child: isLoading
              ? Center(child: ShimmerLoading())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: couponsList.length > 0
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return Coupon_Component(
                                    couponsList[index], index);
                              },
                              itemCount: couponsList.length,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset("images/coupon.png",
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No coupons available",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600)),
                                  )
                                ],
                              ),
                            ),
                    ),
                  ],
                )),
    );
  }
}
