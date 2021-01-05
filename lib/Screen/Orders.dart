import 'package:flutter/material.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Screen/EmployeeDeliveryDateFilter.dart';
import 'package:pickndeliver/Screen/Login.dart';
import 'package:pickndeliver/Screen/VendorsDeliveryHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'EmployeeDeliveryHistory.dart';
import 'ProcessingOrderData.dart';
import 'dailyExpensesList.dart';


class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light, // or use Brightness.dark
          iconTheme: new IconThemeData(color: cnst.appPrimaryMaterialColor1),
          backgroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right:12.0),
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Icon(
                  Icons.logout,
                ),
              ),
            ),
          ],
          title: Text(
            'Orders',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: cnst.appPrimaryMaterialColor1,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: cnst.appPrimaryMaterialColor1,
            unselectedLabelColor: Colors.black,
            labelColor: cnst.appPrimaryMaterialColor1,
            tabs: [
              Tab(
                child: Text(
                  //"Inside",
                  "Processing",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: cnst.appPrimaryMaterialColor1,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Running",
                  style:
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Cancelled",
                  style:
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              // Tab(
              //   child: Text(
              //     "COMPLETED",
              //     style:
              //     TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 9,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
        body:
        TabBarView(
          children: <Widget>[
            ProcessingOrderData('pendingOrders'),
            ProcessingOrderData('runningOrders'),
            ProcessingOrderData('cancelledOrders'),
          ],
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Image.asset('images/logo.png',
                    color: Colors.white, width: 90, height: 70),
                decoration: BoxDecoration(
                  color: Colors.purple,
                ),
              ),
              ListTile(
                title: Text(
                  'Employee Delivery History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EmployeeDeliveryHistory()),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Vendors History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VendorsDeliveryHistory()),
                  );
                },
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Daily Expenses',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Expense()),
                  );
                },
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
