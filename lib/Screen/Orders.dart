import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Components/ActiveOrderComponent.dart';
import 'package:pickndeliver/Components/CompleteOrderComponent.dart';
import 'package:pickndeliver/Components/OrderScreenLoading.dart';
import 'package:pickndeliver/Components/ShimmerLoading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light, // or use Brightness.dark
            iconTheme: new IconThemeData(color: cnst.appPrimaryMaterialColor1),
            backgroundColor: Colors.white,

            title: Text(
              'Orders',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cnst.appPrimaryMaterialColor1),
            ),
            centerTitle: true,
            bottom: TabBar(
                indicatorColor: cnst.appPrimaryMaterialColor1,
                unselectedLabelColor: Colors.grey,
                labelColor: cnst.appPrimaryMaterialColor1,
                tabs: [
                  Tab(
                    child: Text(
                      //"Inside",
                      "ACTIVE",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: cnst.appPrimaryMaterialColor1),
                    ),
                  ),
                  Tab(
                    child: Text(
                      //"OutSide",
                      "COMPLETED",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  )
                ]),
          ),
          body: TabBarView(
            children: <Widget>[ActiveOrderTab(), CompleteOrderTab()],
          ),
        ));
  }
}

class ActiveOrderTab extends StatefulWidget {
  @override
  _ActiveOrderTabState createState() => _ActiveOrderTabState();
}

class _ActiveOrderTabState extends State<ActiveOrderTab> {
  bool isLoading = true;
  List activeOrder = [];
  List completeOrder = [];

  @override
  void initState() {
    _activeOrder();
  }

  _activeOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);

    var data = {
      "customerId": CId,
    };
    Services.ActiveOrder(data).then((data) async {
      if (data.IsSuccess == true) {
        setState(() {
          isLoading = false;
          activeOrder = data.Content;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showMsg(data.Message);
      }
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });

      showMsg("Try Again.");
    });
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Orders"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.grey[100],
          child: isLoading
              ? Center(child: OrderLoading())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: activeOrder.length > 0
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return ActiveOrderComponent(
                                    activeOrder: activeOrder[index]);
                              },
                              itemCount: activeOrder.length,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset("images/empty.png",
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No Active Orders",
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

class CompleteOrderTab extends StatefulWidget {
  @override
  _CompleteOrderTabState createState() => _CompleteOrderTabState();
}

class _CompleteOrderTabState extends State<CompleteOrderTab> {
  bool isLoading = true;
  List completeOrder = [];

  @override
  void initState() {
    _completeOrder();
  }

  _completeOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CustomerId = prefs.getString(cnst.Session.Id);

    var data = {
      "customerId": CustomerId,
    };
    Services.CompleteOrder(data).then((data) async {
      if (data.IsSuccess == true) {
        setState(() {
          isLoading = false;
          completeOrder = data.Content;
        });
      } else {
        setState(() {
          isLoading = false;
        });

        showMsg(data.Message);
      }
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });

      showMsg("Try Again.");
    });
  }

  showMsg(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Orders"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.grey[100],
          child: isLoading
              ? Center(child: OrderLoading())
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: completeOrder.length > 0
                          ? ListView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                return CompleteOrderComponent(
                                    completeOrder: completeOrder[index]);
                              },
                              itemCount: completeOrder.length,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset("images/empty.png",
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No Complete Order Found",
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
