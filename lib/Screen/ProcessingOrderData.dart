import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Components/OrderScreenLoading.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';
import 'package:url_launcher/url_launcher.dart';

class ProcessingOrderData extends StatefulWidget {
  String processdata = '';
  Function getcoureirid;

  ProcessingOrderData(this.processdata, {this.getcoureirid});

  @override
  _ProcessingOrderDataState createState() => _ProcessingOrderDataState();
}

class _ProcessingOrderDataState extends State<ProcessingOrderData> {
  bool isLoading = true;
  var ProcessingOrder = new Map();
  List ordersettings = [], availableBoysList = [];
  List dashboardDataList = [];
  List bannerList = [];
  List categoryList = [];
  List courierId = [];
  String name, email, Profile, MobileNo;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  StreamSubscription iosSubscription;
  String fcmToken = "";
  Location location = new Location();
  LocationData currentLocation;
  bool _serviceEnabled = false;
  ProgressDialog pr;

  @override
  void initState() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
    availableDeliveryBoys();
    _configureNotification();
    super.initState();
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
          if (data.Data == "0" && data.IsSuccess == true) {
            setState(() {
              isLoading = false;
            });
            _ProcessigData();
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

  _ProcessigData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);

    var data = {
      "customerId": CId,
    };
    Services.Processing(data).then((data) async {
      setState(() {
        isLoading = false;
        ProcessingOrder = data;
      });
      for (int i = 0;
          i < ProcessingOrder["Data"][0][widget.processdata].length;
          i++) {
        // courierId.add(ProcessingOrder['Data'][0][widget.processdata][i]["courierId"][0]["_id"]);
      }
      print("ProcessingOrder");
      print(ProcessingOrder["Data"][0][widget.processdata]);
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });
      showMsg("Try Again.");
    });
  }

  List<S2Choice<String>> copyofavailableboys = [];

  ListofavailbleBoys() {
    copyofavailableboys.clear();
    for (int i = 0; i < availableBoysList.length; i++) {
      copyofavailableboys.add(
        S2Choice<String>(
          value: '${availableBoysList[i]["name"]}',
          title: "${availableBoysList[i]["name"]}",
        ),
      );
    }
    return copyofavailableboys;
  }

  String value = 'Select Delivery Boys';
  String title = "";

  availableDeliveryBoys() async {
    pr.show();
    Services.availableDeliveryBoys().then((data) async {
      pr.hide();
      if (data.length > 0) {
        setState(() {
          isLoading = false;
          availableBoysList = data;
        });
      } else {
        showMsg("No Employee Available");
      }
    }, onError: (e) {
      setState(() {
        isLoading = false;
      });
      showMsg("Try Again.");
    });
  }

  orderAssigned(String selectedBoyId,String orderId) async {
    pr.show();
    var data = {
      "courierId" : selectedBoyId,
      "orderId" : orderId
    };
    Services.orderAssigned(data).then((data) async {
      pr.hide();
      if (data["IsSuccess"]) {
        showMsg("${data["Message"]}");
        setState(() {
          isLoading = false;
        });
      } else {
        showMsg("No Employee Available");
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
                      child: ProcessingOrder.length > 0
                          ? RefreshIndicator(
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  String amorpm = "";
                                  String currentdate =
                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['dateTime']}";

                                  String dateFormatted =
                                      DateFormat("yyyy-MM-dd HH:mm:ss")
                                          .format(DateTime.parse(currentdate));
                                  //DateTimeFormatter myFormatObj = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
                                  int n = dateFormatted.length;

                                  String tm = DateFormat("HH:mm:ss")
                                      .format(DateTime.parse(currentdate));

                                  DateTime datetime =
                                      DateTime.parse(dateFormatted);

                                  var today = datetime;
                                  var fiftyDaysFromNow = today
                                      .add(new Duration(hours: 5, minutes: 30));

                                  String time = DateFormat("HH:mm:ss").format(
                                      DateTime.parse(
                                          fiftyDaysFromNow.toString()));
                                  String date = DateFormat("dd-MM-yyyy").format(
                                      DateTime.parse(
                                          fiftyDaysFromNow.toString()));

                                  print(time);

                                  //  print(time);
                                  String newtime = time[0] + time[1];
                                  int x = int.parse(newtime);
                                  x += 5;
                                  time.replaceRange(0, 1, x.toString());
                                  if (time[0] == "0") {
                                    amorpm = "AM";
                                  } else if (time[0] == "1" &&
                                      (time[1] == "1" || time[1] == "0")) {
                                    amorpm = "AM";
                                  } else {
                                    amorpm = "PM";
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Card(
                                        elevation: 3,
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['orderNo']}",
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      "Pick Up : ",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']['name']}",
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.042,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        String telephoneUrl =
                                                            "tel:${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']['mobileNo']}";
                                                        if (await canLaunch(
                                                            telephoneUrl)) {
                                                          await launch(
                                                              telephoneUrl);
                                                        } else {
                                                          throw "Can't phone that number.";
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.call,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 8.0),
                                                        child: Text(
                                                            "${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']['completeAddress']}" +
                                                                " ${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']['address']}"),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final String
                                                            googleMapsUrl =
                                                            "comgooglemaps://?center=${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']["lat"]},${ProcessingOrder['Data'][index][widget.processdata][index]['pickupPoint']["long"]}";
                                                        final String
                                                            appleMapsUrl =
                                                            "https://maps.apple.com/?q=${ProcessingOrder['Data'][0][widget.processdata][index]['pickupPoint']["lat"]},${ProcessingOrder['Data'][index][widget.processdata][index]['pickupPoint']["long"]}";

                                                        if (await canLaunch(
                                                            googleMapsUrl)) {
                                                          await launch(
                                                              googleMapsUrl);
                                                        }
                                                        if (await canLaunch(
                                                            appleMapsUrl)) {
                                                          await launch(
                                                              appleMapsUrl,
                                                              forceSafariVC:
                                                                  false);
                                                        } else {
                                                          throw "Couldn't launch URL";
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 12.0),
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    // Text("${cnst.Inr_Rupee} ${widget.completeOrder["amount"]}",
                                                    //     style: TextStyle(fontSize: 18)),
                                                    Text(
                                                      "Drop :",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["name"]}",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    SizedBox(
                                                      width: 2,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        String telephoneUrl =
                                                            "tel:${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["mobileNo"]}";

                                                        if (await canLaunch(
                                                            telephoneUrl)) {
                                                          await launch(
                                                              telephoneUrl);
                                                        } else {
                                                          throw "Can't phone that number.";
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.call,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 8.0),
                                                        child: Text(
                                                            "${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']['completeAddress']}" +
                                                                " ${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']['address']}"),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final String
                                                            googleMapsUrl =
                                                            "comgooglemaps://?center=${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["lat"]},${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["long"]}";
                                                        final String
                                                            appleMapsUrl =
                                                            "https://maps.apple.com/?q=${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["lat"]},${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']}";

                                                        if (await canLaunch(
                                                            googleMapsUrl)) {
                                                          await launch(
                                                              googleMapsUrl);
                                                        }
                                                        if (await canLaunch(
                                                            appleMapsUrl)) {
                                                          await launch(
                                                              appleMapsUrl,
                                                              forceSafariVC:
                                                                  false);
                                                        } else {
                                                          throw "Couldn't launch URL";
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 15.0),
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Text(
                                                      "Distance: ",
                                                      style: TextStyle(
                                                        fontSize: 17.5,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['deliveryPoint']["distance"]}" +
                                                          " Kms",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                    ),
                                                    Text(
                                                      "Amount :",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${ProcessingOrder['Data'][0][widget.processdata][index]['finalAmount']}" +
                                                          " Rs",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    // Text("${cnst.Inr_Rupee} ${widget.completeOrder["amount"]}",
                                                    //     style: TextStyle(fontSize: 18)),
                                                    Text(
                                                      "Date: ",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      date,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    SizedBox(
                                                      width: 13,
                                                    ),
                                                    Text(
                                                      "Time:",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),

                                                    Text(
                                                      time,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors
                                                              .grey.shade800),
                                                    ),
                                                    Text(
                                                      " ${amorpm}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                widget.processdata=="pendingOrders" || widget.processdata=="runningOrders" ?  Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top:7.0),
                                                      child: Container(
                                                        width: MediaQuery.of(context).size.width*0.95,
                                                        child: RaisedButton(
                                                          onPressed: () {},
                                                          color:
                                                              Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                              side: BorderSide(color: Colors.black)
                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SmartSelect<String>.single(
                                                      title: title=="" ? "Select Delivery Boy":title,
                                                      value: value,
                                                      choiceItems: ListofavailbleBoys(),
                                                      onChange: (state) {
                                                        var selectedBoyId="";
                                                        for(int i=0;i<availableBoysList.length;i++){
                                                          if(availableBoysList[i]["name"] == state.value){
                                                            selectedBoyId = availableBoysList[i]["Id"];
                                                            orderAssigned(selectedBoyId,ProcessingOrder['Data'][0][widget.processdata][index]["_id"]);
                                                            break;
                                                          }
                                                        }
                                                        print("selectedBoyId");
                                                        print(selectedBoyId);
                                                        setState(() {
                                                          value = state.value;
                                                          title = "Delivery Boy";
                                                        });
                                                      }
                                                    ),
                                                  ],
                                                ):Container(),
                                              ],
                                            ),
                                          ),
                                        )),
                                  );
                                },
                                itemCount: ProcessingOrder['Data'][0]
                                        [widget.processdata]
                                    .length,
                              ),
                              onRefresh: _getData,
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                              // child: Column(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   crossAxisAlignment: CrossAxisAlignment.center,
                              //   children: <Widget>[
                              //     Image.asset("images/empty.png",
                              //         width: 50,
                              //         height: 50,
                              //         color: Colors.grey),
                              //     Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Text("No Active Orders",
                              //           style: TextStyle(
                              //               color: Colors.grey,
                              //               fontWeight: FontWeight.w600)),
                              //     )
                              //   ],
                              // ),
                            ),
                    ),
                  ],
                )),
    );
  }

  Future<void> _getData() async {
    setState(() {
      _ProcessigData();
    });
  }
}
