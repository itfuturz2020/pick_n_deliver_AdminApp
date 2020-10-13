import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_launch/flutter_launch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import '../Common/Constants.dart' as cnst;
import '../Common/Services.dart';
import '../Components/HomeScreenShimmer.dart';
import '../Screen/AddNewOrder.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool isLoading = true;
  List ordersettings = [];
  List dashboardDataList = [];
  List bannerList = [];
  List categoryList = [];
  String name, email, Profile, MobileNo;
  ProgressDialog pr;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription iosSubscription;
  String fcmToken = "";
  Location location = new Location();
  LocationData currentLocation;
  bool _serviceEnabled = false;

  void launchWhatsApp({
    @required String phone,
    @required String message,
  }) async {
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(message)}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(message)}";
      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  _configureNotification() async {
    if (Platform.isIOS) {
      iosSubscription =
          _firebaseMessaging.onIosSettingsRegistered.listen((data) {
        print("Firebase Messaging---->" + data.toString());
        saveDeviceToken();
      });
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      await saveDeviceToken();
    }
  }

  saveDeviceToken() async {
    _firebaseMessaging.getToken().then((String token) {
      print("Original Token:$token");
      var tokendata = token.split(':');
      setState(() {
        fcmToken = token;
        _OTPVerification(token);
      });
      print("FCM Token : $fcmToken");
    });
  }

  _OTPVerification(String token) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isLoading = true;
        var data = {
          "mobileNo": '${MobileNo}',
          "fcmToken": token,
        };
        Services.OTVerification(data).then((data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }, onError: (e) {
          setState(() {
            isLoading = false;
          });
          print("Error : on otp $e");
          //showMsg("Try again");
        });
      }
    } on SocketException catch (_) {
      //showMsg("No internet connection");
    }
  }

  Future<void> _requestService() async {
    if (_serviceEnabled == null || !_serviceEnabled) {
      final bool serviceRequestedResult = await location.requestService();
      setState(() {
        _serviceEnabled = serviceRequestedResult;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _requestService();
    //getLocation();
    _banners();
    _getOrderSettings();
    _getLocal();
    _configureNotification();
  }

  getLocation() async {
    currentLocation = await location.getLocation();
  }

  _getLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString(cnst.Session.Name);
      email = prefs.getString(cnst.Session.Email);
      Profile = prefs.getString(cnst.Session.Image);
      MobileNo = prefs.getString(cnst.Session.Mobile);
    });
  }

  void _showChooseDialog() {
    List<Widget> lstWidget = List<Widget>();
    for (int i = 0; i < categoryList.length; i++) {
      lstWidget.add(_getItemList(i, close: true));
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Pick n Delivere"),
              Text(
                "Please choose what you want to deliver first",
                style: Theme.of(context).textTheme.bodyText2,
              )
            ],
          ),
          children: lstWidget,

          //content: new Text("Please! Choose what you want to deliver"),
          /*content: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: categoryList.length,
            itemBuilder: (BuildContext context, int index) {
              return _getItemList(index);
            },
          ),*/
          /*actions: <Widget>[

          ]*/
        );
      },
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Pick n Delivere"),
          content: new Text("Are You Sure You Want To Logout ?"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("No",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushNamedAndRemoveUntil(
        context, "/Login", (Route<dynamic> route) => false);
  }

  _getOrderSettings() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String CId = prefs.getString(cnst.Session.Id);
        Services.GetOrderSettings().then((data) async {
          if (data.IsSuccess == true) {
            if (data.Content.length > 0) {
              setState(() {
                ordersettings = data.Content;
              });
              print(ordersettings[0]["PerUnder5KM"]);
            }
          } else {
            showMsg(data.Message);
          }
        }, onError: (e) {
          print("Error : on OrderSetting Data Call $e");
          showMsg("$e");
        });
      } else {
        showMsg("Something went Wrong!");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  _banners() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Services.Banners().then((data) async {
          if (data.IsSuccess == true) {
            if (data.Content.length > 0) {
              setState(() {
                dashboardDataList = data.Content;
                bannerList = data.Content[0]["banners"];
                categoryList = data.Content[0]["categories"];
              });
            }
          } else {
            showMsg(data.Message);
          }
        }, onError: (e) {
          print("Error : on Banners Data Call $e");
          showMsg("$e");
        });
      } else {
        showMsg("Something went Wrong!");
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
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

  _launchWhatsApp() async {
    String phoneNumber = '+91 ${ordersettings[0]["settings"][0]['WhatsAppNo']}';
    String message = '${ordersettings[0]["settings"][0]['DefaultWMessage']}';
    var whatsappUrl = "whatsapp://send?phone=$phoneNumber&text=$message";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press Back Again to Exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  Widget _getGridView() {
    return Container(
      height: 150,
      child: new GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        itemBuilder: (BuildContext context, int index) {
          return _getItemList(index);
        },
      ),
    );
  }

  Widget _getItemList(int index, {bool close = false}) {
    return GestureDetector(
      onTap: () {
        if (close) Navigator.pop(context);

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewOrder(
                  orderSetting: ordersettings[0]["deliverytypes"],
                  categoryList: categoryList,
                  index: index),
            ));
      },
      child: new Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.network(
                '${cnst.API_URL + categoryList[index]["image"]}',
                width: 45,
              ),
              new Text(
                '${categoryList[index]["title"]}',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            // or use Brightness.dark
            iconTheme: new IconThemeData(color: cnst.appPrimaryMaterialColor1),
            backgroundColor: Colors.white,
            title: Image.asset(
              'images/logo.png',
              fit: BoxFit.contain,
              height: 28,
            ),
            centerTitle: true,
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  accountName:
                      new Text("${name}", style: TextStyle(fontSize: 16)),
                  accountEmail: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/MyProfile');
                    },
                    child: Row(
                      children: <Widget>[
                        Text("${email}"),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child:
                              Icon(Icons.edit, size: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: new ExactAssetImage('images/drawe_background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  currentAccountPicture: Container(
                    width: 0,
                    height: 0,
                    decoration: BoxDecoration(
                        image: new DecorationImage(
                            image: AssetImage('images/avtarprofile.png'),
                            fit: BoxFit.cover),
                        borderRadius:
                            BorderRadius.all(new Radius.circular(200.0)),
                        border: Border.all(width: 0.5, color: Colors.black54)),
                  ),
                ),
                new ListTile(
                    leading: Icon(
                      Icons.home,
                      size: 20,
                    ),
                    title: new Text("Home"),
                    onTap: () {
                      Navigator.pop(context);
                    }),
                new ListTile(
                    leading: Icon(Icons.local_offer, size: 20),
                    title: new Text("Coupons & Offers"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Coupons_offers');
                    }),
                new ListTile(
                    leading: Icon(
                      Icons.shopping_cart,
                      size: 20,
                    ),
                    title: new Text("Orders"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/Orders');
                    }),
                new ListTile(
                    leading: Icon(Icons.question_answer, size: 20),
                    title: new Text("Help"),
                    onTap: () {
                      Navigator.pop(context);
                      launchWhatsApp(
                          phone:
                              "+91${ordersettings[0]["settings"][0]['WhatsAppNo']}",
                          message:
                              "${ordersettings[0]["settings"][0]['DefaultWMessage']}");
                      //whatsAppOpen();
                    }),
/*
                new ListTile(
                    leading: Icon(Icons.insert_drive_file,size: 20),
                    title: new Text("Terms & Conditions"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/TermsAndCondition');
                    }),
*/
                Divider(),
                new ListTile(
                    leading: Icon(
                      Icons.share,
                      size: 20,
                    ),
                    title: new Text("Share"),
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(
                          "${ordersettings[0]["settings"][0]["AppLink"]}");
                    }),
                new ListTile(
                    leading: Icon(
                      Icons.assignment,
                      size: 20,
                    ),
                    title: new Text("Terms & Conditions"),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/TermsAndCondition');
                    }),
                new ListTile(
                    leading: Icon(Icons.power_settings_new, size: 20),
                    title: new Text("Logout"),
                    onTap: () {
                      Navigator.pop(context);
                      _showConfirmDialog();
                    }),
              ],
            ),
          ),
          body: dashboardDataList.length > 0
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4.0)),
                        width: MediaQuery.of(context).size.width,
                        height: 28,
                        child: Center(
                            child: Text(
                                "Delivery Timing: " +
                                    "${ordersettings[0]["settings"][0]["FromTime"]}" +
                                    " to " +
                                    "${ordersettings[0]["settings"][0]["ToTime"]}",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          viewportFraction: 0.9,
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 1500),
                          height: 170.0,
                          enlargeCenterPage: false,
                          autoPlay: true,
                          disableCenter: true,
                          initialPage: 0,
                          reverse: false,
                        ),
                        items: bannerList.map((i) {
                          return new Builder(
                            builder: (BuildContext context) {
                              return new Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: new EdgeInsets.only(
                                    left: 2.0,
                                  ),
                                  child: new Image.network(
                                      "${cnst.API_URL + i["image"]}",
                                      fit: BoxFit.cover,
                                      width:
                                          MediaQuery.of(context).size.width));
                            },
                          );
                        }).toList(),
                      ),
                    ),
/*
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 12, right: 12.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              //color: cnst.appPrimaryMaterialColor1[100],
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6.0))),
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.local_offer,
                                  color: cnst.appPrimaryMaterialColor1,
                                  size: 20),
                              Text(
                                " Coupon & Offers",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: cnst.appPrimaryMaterialColor1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6.0))),
                          height: 45,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.shopping_cart,
                                  color: cnst.appPrimaryMaterialColor1,
                                  size: 20),
                              Text(
                                "  Orders",
                                style: TextStyle(
                                    color: cnst.appPrimaryMaterialColor1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
*/
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 2.0),
                      child: Text(
                        "What you want to deliver ?",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(
                      endIndent: 50,
                      indent: 50,
                    ),
                    _getGridView(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      // 'images/logo.png'
                      child: Image.asset(
                        'images/sub_banner.jpg',
                      ),
                      // 'http://www.pickndelivere.com/Assets/img/LatestNews/Pick%20N%20Deliver%20Banner.jpg'),
                    )
                  ],
                )
              : HomeScreenShimmer(),
          floatingActionButton: FloatingActionButton.extended(
              backgroundColor: cnst.appPrimaryMaterialColor1,
              onPressed: () {
                // added new toast for selection  of new category
                Fluttertoast.showToast(msg: "Please  Select a Category");
                // added a pop of categories
                /*_showChooseDialog();*/
                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNewOrder(
                          orderSetting: ordersettings[0]["deliverytypes"],
                          categoryList: categoryList),
                    ));*/
              },
              label: Row(
                children: <Widget>[Icon(Icons.add), Text('Add New Order')],
              )),
        ));
  }
}
