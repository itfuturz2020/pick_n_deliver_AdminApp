import 'dart:io';
import 'dart:ui';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../Common/ClassList.dart';
import '../Common/Constants.dart' as cnst;
import '../Common/Services.dart';
import '../Screen/ContactList.dart';
import '../Screen/Coupons_offers.dart';
import 'ContactList.dart';

const kGoogleApiKey = "AIzaSyCm9L8-lLCSpRYME1D4lfMb4CS-oX1U6eQ";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class AddNewOrder extends StatefulWidget {
  var orderSetting;
  String CouponCode;
  String Mobileno;
  var categoryList;
  int index;

  AddNewOrder(
      {this.orderSetting,
      this.CouponCode,
      this.Mobileno,
      this.categoryList,
      this.index});

  @override
  _AddNewOrderState createState() => _AddNewOrderState();
}

class _AddNewOrderState extends State<AddNewOrder> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int choossedPickUpAddress, choossedDeliveryAddress;
  String timeErrorMsg = "",
      pickAddressErrorMsg = "",
      ariveTypeErrorMsg = "",
      deliverAddressErrorMsg = "",
      cashFromErrorMsg = "",
      _cashFrom = "pickUp",
      PaymentMode = 'COD',
      DeliverMode = "Express Delivery",
      arriveType = "";
  GlobalKey<AutoCompleteTextFieldState<String>> autokey = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> autokey2= new GlobalKey();
  TextEditingController edtName = new TextEditingController();
  TextEditingController edtMobile = new TextEditingController();
  TextEditingController edtAddress = new TextEditingController();
  TextEditingController edtCompleteAddress = new TextEditingController();
  TextEditingController edtWhenToArive = new TextEditingController();
  TextEditingController edtReceiverName = new TextEditingController();
  TextEditingController edtReceiverMobile = new TextEditingController();
  TextEditingController edtReceiverAddress = new TextEditingController();
  TextEditingController edtReceiverCompleteAddress =
      new TextEditingController();
  TextEditingController edtPromoCode = new TextEditingController();
  String arivalTime = "";
  File _contentImage;
  List _parcelContents = [];
  List _categoryList = [];
  List<DeliveryType> deliveryTypeList = [];
  DeliveryType deliveryType;
  String pickAddress = "", deliverAddress = "";
  double pickLat, pickLong, deliveryLat, deliveryLong;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  List data;

  // double distance_km=0.0,extrakmamount=0.0, amount=0.0, discount=0.0, finalamount=0.0,ExtraKm=0.0;

  bool ariveRightNow = false, isLoading = false;
  ProgressDialog pr;
  List existingPickUpAddress = [];
  List existingDeliveryAddress = [];
  List amountcal = [];
  List suggestions = [];
  PermissionStatus _permissionStatus = PermissionStatus.undetermined;
  String note,
      totaldistance,
      totalamount,
      extracharges,
      //before
      // extradeliverycharge,
      //after  17-08-2020 kd
      extadeliverycharges,
      amount,
      promoused,
      totaldistanceamount;
  String email, MobileNo;
  loc.Location location = new loc.Location();
  loc.LocationData currentLocation;
  Razorpay _razorpay;

  _getLocal() async {
    print("->>" + widget.categoryList.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString(cnst.Session.Email);
      MobileNo = prefs.getString(cnst.Session.Mobile);
    });
  }

  @override
  void initState() {
    getLocation();
    _getLocal();
    _pickExistingPickUpAddress();
    super.initState();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
    if (widget.index != null) {
      setState(() {
        _parcelContents.add(widget.categoryList[widget.index]["title"]);
      });
      for (var i = 0; i < _parcelContents.length; i++) {
        _categoryList.add("${_parcelContents[i]}");
      }
    }
    setDeliveryData();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("sucess:" + response.toString());
    _placeOrder();
    Navigator.pushReplacementNamed(context, '/Orders');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("error::: ${response.message}");
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        backgroundColor: cnst.appPrimaryMaterialColor1);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName,
        backgroundColor: cnst.appPrimaryMaterialColor1);
  }

  setDeliveryData() {
    DeliveryTypeData data = DeliveryTypeData.fromJson(widget.orderSetting);
    setState(() {
      deliveryTypeList = data.Data;
      deliveryType = data.Data[0];
    });
    print(deliveryTypeList[0].title);
    print(deliveryTypeList[1].title);
  }

  getLocation() async {
    currentLocation = await location.getLocation();
  }

  _movetocontact(BuildContext context) async {
    if (await Permission.contacts.request().isGranted) {
      List contactdata = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactList()),
      );
      edtMobile.text = contactdata[0];
      edtName.text = contactdata[1];
    }
  }

  _receiverContact(BuildContext context) async {
    /*requestPermission(PermissionGroup.contacts);

    Permission.contacts.status*/
    if (await Permission.contacts.request().isGranted) {
      List contactdata = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContactList()),
      );
      edtReceiverMobile.text = contactdata[0];
      edtReceiverName.text = contactdata[1];
    }
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Coupons_offers()),
    );
    edtPromoCode.text = result;
  }

  searchPickLocation() async {
    try {
      print("Current Location");
      //print(currentLocation);

      Prediction p = await PlacesAutocomplete.show(
        context: context,
        //strictbounds: currentLocation == null ? false : true,
        hint: "Search your pick location",
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: Mode.overlay,
        language: "en",
        components: [Component(Component.country, "in")],
        location: currentLocation == null
            ? null
            : Location(currentLocation.latitude, currentLocation.longitude),
        //radius: currentLocation == null ? null : 10000
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      setState(() {
        pickAddress = p.description;
        pickLat = detail.result.geometry.location.lat;
        pickLong = detail.result.geometry.location.lng;
      });
      if (deliverAddress != null) {
        setState(() {
          deliverAddress = "";
        });
      }
      print("Pick : ${pickLat},${pickLong}");
    } catch (e) {
      return;
    }
  }

  searchDeliverLocation() async {
    try {
      Prediction p = await PlacesAutocomplete.show(
        context: context,
        //strictbounds: currentLocation == null ? false : true,
        hint: "Search your deliver location",
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: Mode.overlay,
        language: "en",
        // we have added country india  and  also language
        components: [Component(Component.country, "in")],
        location: currentLocation == null
            ? null
            : Location(currentLocation.latitude, currentLocation.longitude),
        // radius is for get location by this much radius only
        // radius: currentLocation == null ? null : 10000
      ); //radiussssss

      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      setState(() {
        deliverAddress = p.description;
        deliveryLat = detail.result.geometry.location.lat;
        deliveryLong = detail.result.geometry.location.lng;
      });
      print("Delivery :  ${deliverAddress},${deliveryLat},${deliveryLong}");
      if (pickAddress != null && deliverAddress != null) {
        _amountCal(pickLat.toString(), pickLong.toString(),
            deliveryLat.toString(), deliveryLong.toString());
        /*setState(() {
          distance_km = distance(pickLat, pickLong, deliveryLat, deliveryLong);
          ExtraKm = distance_km - 5.0;
        });
        print('-------------------------------------------------------------------');
        print(distance_km);
        print(ExtraKm);*/
        // amountcalc();
      }
      //Navigator.pop(context);
    } catch (e) {
      return;
    }
  }

  _contentImagePopup(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () async {
                      var image = await ImagePicker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null)
                        setState(() {
                          _contentImage = image;
                        });
                      Navigator.pop(context);
                    }),
                new ListTile(
                    leading: new Icon(Icons.photo),
                    title: new Text('Gallery'),
                    onTap: () async {
                      var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null)
                        setState(() {
                          _contentImage = image;
                        });
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }

  _amountCal(
      String pickLat, String pickLong, String dropLat, String dropLong) async {
    deliveryType = DeliverMode == "Normal Delivery"
        ? deliveryTypeList[0]
        : deliveryTypeList[1];

    if (pickAddress != "" && deliverAddress != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var data = {
            "picklat": "$pickLat",
            "picklong": "$pickLong",
            "droplat": "$dropLat",
            "parcelcontents": _categoryList,
            "droplong": "$dropLong",
            "deliverytype": deliveryType.title,
            "promocode": edtPromoCode.text,
          };
          print(data);
          await Services.AmountCal(data).then((data) async {
            if (data.IsSuccess == true) {
              if (data.Content.length > 0) {
                setState(() {
                  amountcal = data.Content;
                  note = amountcal[0]["note"];
                  totaldistance = amountcal[0]["totaldistance"].toString();
                  totalamount = amountcal[0]["totalamt"].toString();
                  extracharges = amountcal[0]["extracharges"].toString();
                  //before
                  //extradeliverycharge =amountcal[0]["extradeliverycharge"].toString();
                  //after 17-08-2020 kd
                  extadeliverycharges =
                      amountcal[0]["extadeliverycharges"].toString();
                  amount = amountcal[0]["amount"].toString();
                  promoused = amountcal[0]["promoused"].toString();
                  totaldistanceamount = amountcal[0]["totaldistamt"].toString();
                });
                print("Amount Data" + "${amountcal}");
              }
            }
          }, onError: (e) {
            print("Error : on amountCal Data Call $e");
            //showMsg("$e");
          });
        } else {
          //showMsg("Something went Wrong!");
        }
      } on SocketException catch (_) {
        //showMsg("No Internet Connection.");
      }
    } else {
      //Fluttertoast.showToast(msg: "Please Selec");
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  _placeOrder() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        pr.show();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String CId = prefs.getString(cnst.Session.Id);
        String selContents = _parcelContents.toString().replaceAll("[", "");
        selContents = selContents.toString().replaceAll("]", "");
        String filename = "";
        String filePath = "";
        File compressedFile;
        if (_contentImage != null) {
          ImageProperties properties =
              await FlutterNativeImage.getImageProperties(_contentImage.path);

          compressedFile = await FlutterNativeImage.compressImage(
            _contentImage.path,
            quality: 80,
            targetWidth: 600,
            targetHeight: (properties.height * 600 / properties.width).round(),
          );

          filename = _contentImage.path.split('/').last;
          filePath = compressedFile.path;
        }
        FormData data = FormData.fromMap({
          "customerId": "${CId}",
          "deliveryType": deliveryType.title,
          "weightLimit":
              "${deliveryType == "Normal Delivery" ? deliveryType.weightlimit : deliveryType.weightlimit}",
          "pkName": edtName.text,
          "pkMobileNo": edtMobile.text,
          "pkAddress": pickAddress,
          "pkLat": pickLat,
          "pkLong": pickLong,
          "pkCompleteAddress": edtCompleteAddress.text,
          "pkContent": selContents,
          "pkArriveType": "",
          "pkArriveTime": "",
          "dpName": edtReceiverName.text,
          "dpMobileNo": edtReceiverMobile.text,
          "dpAddress": deliverAddress,
          "dpLat": deliveryLat,
          "orderimg": (filePath != null && filePath != '')
              ? await MultipartFile.fromFile(filePath,
                  filename: filename.toString())
              : null,
          "dpLong": deliveryLong,
          "dpCompleteAddress": edtReceiverCompleteAddress.text,
          "dpDistance": totaldistance,
          "collectCash": _cashFrom,
          "promoCode": edtPromoCode.text != "" ? edtPromoCode.text : "0",
          "amount": amount,
          "discount": promoused != "" || promoused != null ? promoused : 0.00,
          "finalAmount": totalamount,
          "additionalAmount": extracharges
        });
        print(data.toString());
        print("Customer_Id: $CId");
        print("DeliveryType: ${deliveryType.title}");
        print("limit: ${deliveryType.weightlimit}");
        print("pkName: ${edtName.text}");
        print("mobile: ${edtMobile.text}");
        print("Addres:${edtCompleteAddress.text}");
        print("Complete Addres:${pickAddress}");
        print("dname: ${edtReceiverName.text}");
        print("mobile: ${edtReceiverMobile.text}");
        print("Addres:${deliverAddress}");
        print("Complete Addres:${edtReceiverCompleteAddress.text}");

        print("dpLong${deliveryLong}");
        print("dpCompleteAddress${edtReceiverCompleteAddress.text}");
        print("dpDistance${totaldistance}");
        print("collectCash: ${_cashFrom}");
        Services.PlaceOrder(data).then((data) async {
          if (data.IsSuccess == true) {
            pr.hide();


            Fluttertoast.showToast(
                msg: "New Order Added Successfully !!!",
                backgroundColor: cnst.appPrimaryMaterialColor1,
                textColor: Colors.white,
                gravity: ToastGravity.BOTTOM,
                toastLength: Toast.LENGTH_LONG);
            Navigator.pushReplacementNamed(context, '/Orders');
          } else {
            pr.hide();
            Fluttertoast.showToast(msg: "Try Agian");
          }
        }, onError: (e) {
          pr.hide();
          showMsg(e.toString());
        });
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

  _clearData() {
    deliveryType.title = "";
    edtName.text = "";
    edtMobile.text = "";
    pickAddress = "";
    edtCompleteAddress.text = "";
    arriveType = "";
    arivalTime = "";
    edtReceiverName.text = "";
    edtReceiverMobile.text = "";
    deliverAddress = "";
    edtReceiverCompleteAddress.text = "";
    _cashFrom = "";
  }

  setMonth(String mn) {
    String month = "";
    switch (mn) {
      case "01":
        month = "JANUARY";
        break;
      case "02":
        month = "FEBRUARY";
        break;
      case "03":
        month = "MARCH";
        break;
      case "04":
        month = "APRIL";
        break;
      case "05":
        month = "MAY";
        break;
      case "06":
        month = "JUNE";
        break;
      case "07":
        month = "JULY";
        break;
      case "08":
        month = "AUGUST";
        break;
      case "09":
        month = "SEPTEMBER";
        break;
      case "10":
        month = "OCTOBER";
        break;
      case "11":
        month = "NOVEMBER";
        break;
      case "12":
        month = "DECEMBER";
        break;
    }
    return month;
  }

  _savePickUpAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);
    var data = {
      "customerId": CId,
      "name": edtName.text,
      "mobileNo": edtMobile.text,
      "address": pickAddress,
      "lat": pickLat,
      "long": pickLong,
      "completeAddress": edtCompleteAddress.text,
    };
    Services.AddPickUpAddress(data).then((data) async {
      if (data.IsSuccess == true) {
        Fluttertoast.showToast(
            msg: "Address Added Successfully !!!",
            backgroundColor: cnst.appPrimaryMaterialColor1,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG);
      } else {
        showMsg(data.Message);
      }
    }, onError: (e) {
      showMsg("Try Again.");
    });
    _pickExistingPickUpAddress();
  }

  void _BottomSheetAddress(context, String type) {
    _pickExistingPickUpAddress();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return existingPickUpAddress.length > 0
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0)),
                    height: 80 *
                        double.parse(existingPickUpAddress.length.toString()),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: existingPickUpAddress.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            print(
                                "${existingPickUpAddress[index]["lat"]},${existingPickUpAddress[index]["long"]}");
                            setState(() {
                              Navigator.pop(context);
                              choossedPickUpAddress = index;
                              if (type == "Pick") {
                                edtName.text =
                                    existingPickUpAddress[index]["name"];
                                edtMobile.text =
                                    existingPickUpAddress[index]["mobileNo"];
                                pickAddress =
                                    existingPickUpAddress[index]["address"];
                                pickLat = double.parse(
                                    existingPickUpAddress[index]["lat"]);
                                pickLong = double.parse(
                                    existingPickUpAddress[index]["long"]);
                                edtCompleteAddress.text =
                                    existingPickUpAddress[index]
                                        ["completeAddress"];
                              } else {
                                edtReceiverName.text =
                                    existingPickUpAddress[index]["name"];
                                edtReceiverMobile.text =
                                    existingPickUpAddress[index]["mobileNo"];
                                deliverAddress =
                                    existingPickUpAddress[index]["address"];
                                deliveryLat = double.parse(
                                    existingPickUpAddress[index]["lat"]);
                                deliveryLong = double.parse(
                                    existingPickUpAddress[index]["long"]);
                                edtReceiverCompleteAddress.text =
                                    existingPickUpAddress[index]
                                        ["completeAddress"];
                              }
                              //to calculate tot amt on selecting drop point-kd -17-08-2020
                              print("call amt on delviery");
                              if (pickAddress != null &&
                                  deliverAddress != null) {
                                _amountCal(
                                    pickLat.toString(),
                                    pickLong.toString(),
                                    deliveryLat.toString(),
                                    deliveryLong.toString());
                              }
                              //print("pick ${pickAddress}");
                              //print("de;liver ${deliverAddress}");
                              /*if (deliverAddress != "") {
                          print("py");

                          distance_km = distance(pickLat, pickLong,
                              deliveryLat, deliveryLong);

                          amount =
                          (distance_km * double.parse('${widget.orderSetting[0]["PerKM"]}'));

                          print("py ${distance_km}");
                        }*/
                            });
                            // amountcalc();
                          },
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "${existingPickUpAddress[index]["name"]} - ${existingPickUpAddress[index]["mobileNo"]}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${existingPickUpAddress[index]["address"]} - ${existingPickUpAddress[index]["completeAddress"]}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                        choossedPickUpAddress == index
                                            ? Icons.beenhere
                                            : Icons.remove_circle,
                                        color: choossedPickUpAddress == index
                                            ? Colors.green
                                            : Colors.red)
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 1.5,
                                width: MediaQuery.of(context).size.width,
                                child: Container(color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Container();
        });
  }

  void _BottomSheetInfo(context) {
    //_pickExistingPickUpAddress();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: Center(
                            child: Text(
                          "Payment Detail",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        )),
                      ),
                    ),
                    Container(
                      width: 50,
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
/*
                      Text(
                          "Minimum Amount: (${totaldistance != null ? totaldistance : 0.0} Km)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
*/
                      Text(
                          "Minimum Amount: (${totaldistance != null ? totaldistance : 0.0} Km)",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                          "${cnst.Inr_Rupee} " +
                              "${totaldistanceamount != null ? totaldistanceamount + ".00" : 0.00}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Extra Charges:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                          "${cnst.Inr_Rupee} " +
                              "${extracharges != null ? extracharges + ".00" : 0.00}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                //express delivery charge
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text("Express Delivery",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16))),
                      Icon(Icons.add, size: 20),
                      Text(
                          //before
                          //"${cnst.Inr_Rupee} " + "${extradeliverycharge != null ? extradeliverycharge : 0.00}",
                          //after 17-08-2020
                          "${cnst.Inr_Rupee} " +
                              "${extadeliverycharges != null ? extadeliverycharges + ".00" : 0.00}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: Text("Promo Applied",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16))),
                      Icon(Icons.remove, size: 20),
                      Text(
                          cnst.Inr_Rupee +
                              "${promoused != null ? promoused + ".00" : 0.00}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Total Amount",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      totalamount == "" || totalamount == null
                          ? Text(cnst.Inr_Rupee + "0.00",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24))
                          : Text(cnst.Inr_Rupee + "${totalamount}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  _pickExistingPickUpAddress() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);
    var data = {
      "customerId": CId,
    };
    Services.GetPickUpAddress(data).then((data) async {
      if (data.IsSuccess == true) {
        setState(() {
          isLoading = false;
        });

        if (data.Content.length > 0) {
          setState(() {
            existingPickUpAddress = data.Content;
            print(' $existingPickUpAddress');
          });
        } else {
          isLoading = false;
          /* Fluttertoast.showToast(
              msg: "Address Not Found !!!",
              backgroundColor: cnst.appPrimaryMaterialColor1,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG);*/
        }
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
    setState(() {
      isLoading = false;
    });
  }

  _saveDeliveryAddress() async {
    //pr.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);
    var data = {
      "customerId": CId,
      "name": edtReceiverName.text,
      "mobileNo": edtReceiverMobile.text,
      //"address": edtReceiverAddress.text,
      "address": deliverAddress,
      "lat": deliveryLat,
      "long": deliveryLong,
      "completeAddress": edtReceiverCompleteAddress.text,
    };
    //Services.AddDeliveryAddress(data).then((data) async {
    Services.AddPickUpAddress(data).then((data) async {
      if (data.IsSuccess == true) {
        //pr.hide();
        Fluttertoast.showToast(
            msg: "Address Added Successfully !!!",
            backgroundColor: cnst.appPrimaryMaterialColor1,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_LONG);
      } else {
        //pr.hide();
        showMsg(data.Message);
      }
    }, onError: (e) {
      // pr.hide();
      showMsg("Try Again.");
    });
    //pr.hide();
    //_pickExistingDeliveryAddress();
    _pickExistingPickUpAddress();
  }

  _pickExistingDeliveryAddress() async {
    pr.show();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String CId = prefs.getString(cnst.Session.Id);
    var data = {
      "customerId": CId,
    };
    Services.GetDeliveryAddress(data).then((data) async {
      if (data.IsSuccess == true) {
        pr.hide();
        if (data.Content.length > 0) {
          setState(() {
            existingDeliveryAddress = data.Content;
          });
        } else {
          Fluttertoast.showToast(
              msg: "Address Not Found !!!",
              backgroundColor: cnst.appPrimaryMaterialColor1,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG);
        }
      } else {
        pr.hide();
        showMsg(data.Message);
      }
    }, onError: (e) {
      pr.hide();
      showMsg("Try Again.");
    });
    //pr.hide();
  }

  startPayment() async {
    double payableAmount = double.parse(totalamount);
    //double payableAmount=1;

    print(int.parse(payableAmount.roundToDouble().floor().toString() + "00"));
    Services.GetOrderIDForPayment(
            int.parse(payableAmount.roundToDouble().floor().toString() + "00"),
            'ORD1001')
        .then((data) async {
      if (data != null) {
        print("order Id---> ${data.Data}");
        var options = {
          'image': '',
          'key': 'rzp_live_XCxat4CzDhDGNj',
          'order_id': data.Data,
          'amount': payableAmount.toString(),
          'name': 'Pick N DeliverE',
          'description': 'Order Payment',
          'prefill': {'contact': MobileNo, 'email': email},
        };
        try {
          _razorpay.open(options);
        } catch (e) {
          debugPrint(e);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Payment Gateway Not Open",
            backgroundColor: Colors.red,
            gravity: ToastGravity.TOP,
            toastLength: Toast.LENGTH_LONG);
      }
    }, onError: (e) {
      Fluttertoast.showToast(
          msg: "Data Not Saved" + e.toString(), backgroundColor: Colors.red);
    });
  }

  /* Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);
    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[permission];
      print(_permissionStatus);
    });
    if (permissionRequestResult[permission] == PermissionStatus.granted) {
      _movetocontact(context);
    } else {
      Fluttertoast.showToast(
          msg: "Permission Not Granted",
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_SHORT);
    }
  }*/

  void setDeliveryMode(String value) {
    setState(() {
      DeliverMode = value;
    });
    _amountCal(pickLat.toString(), pickLong.toString(), deliveryLat.toString(),
        deliveryLong.toString());
  }

  @override
  Widget build(BuildContext context) {
    deliveryType = DeliverMode == "Normal Delivery"
        ? deliveryTypeList[0]
        : deliveryTypeList[1];

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        key: homeScaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          // or use Brightness.dark
          backgroundColor: Colors.white,
          title: Text(
            "NEW ORDER",
            style: TextStyle(color: cnst.appPrimaryMaterialColor1),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.cancel,
              color: cnst.appPrimaryMaterialColor1,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                _clearData();
              },
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.only(right: 13),
                child: Text("CLEAR",
                    style: TextStyle(
                        color: cnst.appPrimaryMaterialColor1, fontSize: 17)),
              )),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Container(
                    child: Row(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: cnst.appPrimaryMaterialColor1,
                                    width: 2)),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("1",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: cnst.appPrimaryMaterialColor1,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: <Widget>[
                          // TextFormField(
                          //   validator: (String value) {
                          //     if (value.trim() == "") {
                          //       return 'Please enter your Name';
                          //     }
                          //     return null;
                          //   },
                          //   controller: edtName,
                          //   textCapitalization: TextCapitalization.words,
                          //   keyboardType: TextInputType.text,
                          //   decoration: InputDecoration(
                          //     labelText: "Name",
                          //   ),
                          // ),
                          SimpleAutoCompleteTextField(
                            key: autokey,
                            decoration: new InputDecoration(
                              labelText: "Name",
                              errorText: 'Please enter your Name',
                            ),
                            controller: edtName,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            suggestions: ['abc', 'adb', 'ad'],
                            textChanged: (text) {},
                            textSubmitted: (text) => setState(() {
                              //TODO set edtname controller
                            }),
                          ),
                          TextFormField(
                            validator: (String value) {
                              if (value.trim() == "" || value.length != 10) {
                                return 'Please enter your Mobile Number';
                              }
                              return null;
                            },
                            controller: edtMobile,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                labelText: "Mobile Number",
                                counterText: "",
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        edtMobile.text = "";
                                      });
                                      //requestPermission(PermissionGroup.contacts);
                                      _movetocontact(context);
                                    },
                                    icon: Icon(Icons.contacts))),
                            maxLength: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              searchPickLocation();
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: pickAddressErrorMsg == ""
                                              ? Colors.black26
                                              : Colors.redAccent.shade700))),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Address",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 5, bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                pickAddress == ""
                                                    ? ""
                                                    : pickAddress,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        Colors.grey.shade800),
                                              ),
                                            ),
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          pickAddressErrorMsg == ""
                              ? Container()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(pickAddressErrorMsg,
                                        style: TextStyle(
                                            color: Colors.redAccent.shade700,
                                            fontSize: 13)),
                                  ),
                                ),
                          TextFormField(
                            validator: (String value) {
                              if (value.trim() == "") {
                                return 'Please enter your Complete Address';
                              }
                              return null;
                            },
                            controller: edtCompleteAddress,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Flat, Building, Street ",
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 35,
                                decoration: BoxDecoration(
                                    // color: cnst.appPrimaryMaterialColor1,
                                    border: Border.all(
                                        color: cnst.appPrimaryMaterialColor1,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    if (edtName.text == "" ||
                                        edtMobile.text == "" ||
                                        pickAddress == "" ||
                                        edtCompleteAddress.text == "") {
                                      Fluttertoast.showToast(
                                          msg: "Please fill all fields!!!",
                                          backgroundColor:
                                              cnst.appPrimaryMaterialColor1,
                                          textColor: Colors.white,
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_LONG);
                                    } else {
                                      _savePickUpAddress();
                                    }
                                  },
                                  child: Text(
                                    "Add This",
                                    style: TextStyle(
                                      color: cnst.appPrimaryMaterialColor1,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 35,
                                decoration: BoxDecoration(
                                    // color: cnst.appPrimaryMaterialColor1,
                                    border: Border.all(
                                        color: cnst.appPrimaryMaterialColor1,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    _BottomSheetAddress(context, "Pick");
                                  },
                                  child: Text(
                                    "Choose Existing",
                                    style: TextStyle(
                                      color: cnst.appPrimaryMaterialColor1,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /*    existingPickUpAddress.length > 0
                              ? Container(
                                  height: 85 *
                                      double.parse(existingPickUpAddress.length
                                          .toString()),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: existingPickUpAddress.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          print(
                                              "${existingPickUpAddress[index]["lat"]},${existingPickUpAddress[index]["long"]}");
                                          setState(() {
                                            choossedPickUpAddress = index;
                                            edtName.text =
                                                existingPickUpAddress[index]
                                                    ["name"];
                                            edtMobile.text =
                                                existingPickUpAddress[index]
                                                    ["mobileNo"];
                                            pickAddress =
                                                existingPickUpAddress[index]
                                                    ["address"];
                                            pickLat = double.parse(
                                                existingPickUpAddress[index]
                                                    ["lat"]);
                                            pickLong = double.parse(
                                                existingPickUpAddress[index]
                                                    ["long"]);
                                            edtCompleteAddress.text =
                                                existingPickUpAddress[index]
                                                    ["completeAddress"];
                                            print("pick ${pickAddress}");
                                            print("de;liver ${deliverAddress}");
                                            if (deliverAddress != "") {
                                              print("py");
                                              distance_km = distance(
                                                  pickLat,
                                                  pickLong,
                                                  deliveryLat,
                                                  deliveryLong);
                                              amount =
                                                  (double.parse(distance_km) *
                                                          amountPerKM)
                                                      .toStringAsFixed(2);
                                              print("py ${distance_km}");
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "${existingPickUpAddress[index]["name"]} - ${existingPickUpAddress[index]["mobileNo"]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "${existingPickUpAddress[index]["address"]} - ${existingPickUpAddress[index]["completeAddress"]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                      choossedPickUpAddress ==
                                                              index
                                                          ? Icons.beenhere
                                                          : Icons.remove_circle,
                                                      color:
                                                          choossedPickUpAddress ==
                                                                  index
                                                              ? Colors.green
                                                              : Colors.red)
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 1.5,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),*/
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    /*Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "When to Arive at this Address",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade600),
                            ),
                            Row(
                              children: <Widget>[
                                Radio(
                                  value: "rightnow",
                                  onChanged: (value) {
                                    setState(() {
                                      arriveType = value;
                                      ariveRightNow = true;
                                    });
                                    //arivalTime
                                    DateTime dateTime = new DateTime.now();
                                    var time = dateTime.toString().split(" ");
                                    var date = time[0].split("-");
                                    String at = "";
                                    at =
                                        "${setMonth(date[1])} ${date[2]} ${date[0]} ";
                                    var t = time[1].toString().split(":");
                                    String tm = "", meridian = "";
                                    if (int.parse(t[1]) >= 45) {
                                      int diff = 60 - int.parse(t[1]);
                                      int hour;
                                      if (int.parse(t[0]) >= 12) {
                                        meridian = "PM";
                                        if (int.parse(t[0]) > 12) {
                                          hour = int.parse(t[0]) - 12;
                                        }
                                      } else {
                                        meridian = "AM";
                                        hour = int.parse(t[0]);
                                      }
                                      tm = (hour + 1).toString() +
                                          ":" +
                                          (int.parse(t[1]) + diff).toString();
                                    } else {
                                      int hour;
                                      if (int.parse(t[0]) >= 12) {
                                        meridian = "PM";
                                        if (int.parse(t[0]) > 12) {
                                          hour = int.parse(t[0]) - 12;
                                        }
                                      } else {
                                        meridian = "AM";
                                        hour = int.parse(t[0]);
                                      }
                                      tm = hour.toString() +
                                          ":" +
                                          (int.parse(t[1]) + 15).toString();
                                    }
                                    arivalTime = "${at} ${tm} ${meridian}";
                                    print("arival: ${arivalTime}");
                                    // "${month} ${d[2]} ${d[0]} ${t[0]}:${t[1]} ${maridian}";
                                  },
                                  groupValue: arriveType,
                                ),
                                Text(
                                  "Right Now",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Radio(
                                  value: "scheduled",
                                  onChanged: (value) {
                                    setState(() {
                                      arriveType = value;
                                      ariveRightNow = false;
                                    });
                                    if (ariveRightNow == false) {
                                      DatePicker.showTimePicker(context,
                                          showTitleActions: true,
                                          onConfirm: (date) {
                                        setState(() {
                                          var time = date.toString().split(" ");
                                          print("t: ${time[0]}");
                                          var d = time[0].split("-");
                                          var t = time[1].split(":");
                                          var maridian = "";
                                          if (int.parse(t[0]) >= 12) {
                                            maridian = "PM";
                                            if (int.parse(t[0]) != 12) {
                                              t[0] = (int.parse(t[0]) - 12)
                                                  .toString();
                                            }
                                          } else {
                                            maridian = "AM";
                                          }
                                          var month = setMonth(d[1]);
                                          arivalTime =
                                              "${month} ${d[2]} ${d[0]} ${t[0]}:${t[1]} ${maridian}";
                                        });
                                      }, currentTime: DateTime.now());
                                    }
                                  },
                                  groupValue: arriveType,
                                ),
                                Text(
                                  "Scheduled",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ariveTypeErrorMsg == ""
                        ? Container()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 25, bottom: 10),
                              child: Text(ariveTypeErrorMsg,
                                  style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 13)),
                            ),
                          ),
                    GestureDetector(
                      onTap: () {
                        */ /*if (ariveRightNow == false) {
                          DatePicker.showTimePicker(context,
                              showTitleActions: true, onConfirm: (date) {
                            setState(() {
                              var time = date.toString().split(" ");
                              print("t: ${time[0]}");
                              var d = time[0].split("-");
                              var t = time[1].split(":");
                              var maridian = "";
                              if (int.parse(t[0]) >= 12) {
                                maridian = "PM";
                                if (int.parse(t[0]) != 12) {
                                  t[0] = (int.parse(t[0]) - 12).toString();
                                }
                              } else {
                                maridian = "AM";
                              }
                              var month = setMonth(d[1]);
                              arivalTime =
                                  "${month} ${d[2]} ${d[0]} ${t[0]}:${t[1]} ${maridian}";
                            });
                          }, currentTime: DateTime.now());
                        }*/ /*
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: timeErrorMsg == ""
                                        ? Colors.black26
                                        : Colors.redAccent.shade700))),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 7),
                              child: Text(
                                arivalTime == "" ? "Select Time" : arivalTime,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey.shade800),
                              ),
                            )),
                      ),
                    ),
                    timeErrorMsg == ""
                        ? Container()
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30, top: 10),
                              child: Text(timeErrorMsg,
                                  style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 13)),
                            ),
                          ),*/
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: MultiSelectFormField(
                        autovalidate: false,
                       // titleText: 'Parcel Content',
                        validator: (value) {
                          if (value == null || value.length == 0) {
                            return 'Please select one or more options';
                          }
                        },
                        change: (value) {},
                        dataSource: widget.categoryList,
                        initialValue: _parcelContents,
                        textField: 'title',
                        valueField: 'title',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        // required: true,
                        //hintText: 'Please choose one or more',
                        onSaved: (value) {
                          print(value);
                          if (value == null) return;
                          setState(() {
                            _parcelContents = value;
                          });
                          _categoryList.clear();
                          bool alreadyShowedMessage = false;
                          String content;
                          for (var i = 0; i < _parcelContents.length; i++) {
                            _categoryList.add("${_parcelContents[i]}");
                            content = _parcelContents[i];
                            if ((content == 'Big cake' ||
                                    content == 'Handle with care') &&
                                alreadyShowedMessage == false) {
                              showTopMessage(
                                  "Delivery will be done after 2 hours only");
                              alreadyShowedMessage = true;
                            }
                          }
                          if (pickAddress != null && deliverAddress != null) {
                            _amountCal(
                                pickLat.toString(),
                                pickLong.toString(),
                                deliveryLat.toString(),
                                deliveryLong.toString());
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "Add Image",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "(optional)",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                _contentImagePopup(context);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border.all(color: Colors.black12),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey.shade500,
                                    ),
                                  )),
                            ),
                            _contentImage == null
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Image.file(
                                      File(_contentImage.path),
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
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
                                    color: cnst.appPrimaryMaterialColor1,
                                    width: 2)),
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("2",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: cnst.appPrimaryMaterialColor1,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: <Widget>[
                          // TextFormField(
                          //   validator: (String value) {
                          //     if (value.trim() == "") {
                          //       return 'Please enter Receiver Name';
                          //     }
                          //     return null;
                          //   },
                          //   controller: edtReceiverName,
                          //   textCapitalization: TextCapitalization.words,
                          //   keyboardType: TextInputType.text,
                          //   decoration: InputDecoration(
                          //     labelText: "Name",
                          //   ),
                          //   textInputAction: TextInputAction.next,
                          // ),
                          SimpleAutoCompleteTextField(
                            key: autokey2,
                            decoration: new InputDecoration(
                              labelText: "Name",
                              errorText: 'Please enter Receiver Name',
                            ),
                            controller: edtReceiverName,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            suggestions: [
                              'abc',
                              'adb',
                              'ad'
                            ], //TODO replace with suggestion string
                            textChanged: (text) {},
                            textSubmitted: (text) => setState(() {
                              //TODO populate other fields
                            }),
                          ),
                          TextFormField(
                            validator: (String value) {
                              if (value.trim() == "") {
                                return 'Please enter Receiver Mobile Number';
                              }
                              return null;
                            },
                            controller: edtReceiverMobile,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        edtReceiverMobile.text = "";
                                      });
                                      _receiverContact(context);
                                    },
                                    icon: Icon(Icons.contacts)),
                                labelText: "Mobile",
                                counterText: ""),
                            maxLength: 10,
                            textInputAction: TextInputAction.next,
                          ),
                          GestureDetector(
                            onTap: () {
                              searchDeliverLocation();
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: deliverAddressErrorMsg == ""
                                              ? Colors.black26
                                              : Colors.redAccent.shade700))),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Address",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, top: 5, bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                deliverAddress == ""
                                                    ? ""
                                                    : deliverAddress,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        Colors.grey.shade800),
                                              ),
                                            ),
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.black38,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          deliverAddressErrorMsg == ""
                              ? Container()
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(deliverAddressErrorMsg,
                                        style: TextStyle(
                                            color: Colors.redAccent.shade700,
                                            fontSize: 13)),
                                  ),
                                ),
                          TextFormField(
                            validator: (String value) {
                              if (value.trim() == "") {
                                return 'Please enter Receiver Complete Address';
                              }
                              return null;
                            },
                            controller: edtReceiverCompleteAddress,
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Flat, Building, Street",
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 35,
                                decoration: BoxDecoration(
                                    // color: cnst.appPrimaryMaterialColor1,
                                    border: Border.all(
                                        color: cnst.appPrimaryMaterialColor1,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    if (edtReceiverName.text == "" ||
                                        edtReceiverMobile.text == "" ||
                                        deliverAddress == "" ||
                                        edtReceiverCompleteAddress.text == "") {
                                      Fluttertoast.showToast(
                                          msg: "Please fill all fields!!!",
                                          backgroundColor:
                                              cnst.appPrimaryMaterialColor1,
                                          textColor: Colors.white,
                                          gravity: ToastGravity.BOTTOM,
                                          toastLength: Toast.LENGTH_LONG);
                                    } else {
                                      _saveDeliveryAddress();
                                    }
                                  },
                                  child: Text(
                                    "Add This",
                                    style: TextStyle(
                                      color: cnst.appPrimaryMaterialColor1,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 35,
                                decoration: BoxDecoration(
                                    // color: cnst.appPrimaryMaterialColor1,
                                    border: Border.all(
                                        color: cnst.appPrimaryMaterialColor1,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0)),
                                  onPressed: () {
                                    _BottomSheetAddress(context, "Drop");

                                    //_pickExistingDeliveryAddress();
                                  },
                                  //drop  point  choose address
                                  child: Text(
                                    "Choose Existing",
                                    style: TextStyle(
                                      color: cnst.appPrimaryMaterialColor1,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          existingDeliveryAddress.length > 0
                              ? Container(
                                  height: 85 *
                                      double.parse(existingDeliveryAddress
                                          .length
                                          .toString()),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: existingDeliveryAddress.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            choossedDeliveryAddress = index;
                                            edtReceiverName.text =
                                                existingDeliveryAddress[index]
                                                    ["name"];
                                            edtReceiverMobile.text =
                                                existingDeliveryAddress[index]
                                                    ["mobileNo"];
                                            deliverAddress =
                                                existingDeliveryAddress[index]
                                                    ["address"];
                                            deliveryLat = double.parse(
                                                existingDeliveryAddress[index]
                                                    ["lat"]);
                                            deliveryLong = double.parse(
                                                existingDeliveryAddress[index]
                                                    ["long"]);
                                            edtReceiverCompleteAddress.text =
                                                existingDeliveryAddress[index]
                                                    ["completeAddress"];
                                            print("pick ${pickAddress}");
                                            print("de;liver ${deliverAddress}");
                                            //to call function  after delivery order is punched  -kd after  17-08-2020
                                            /*if (pickAddress != "") {
                                        print("dy");
                                        distance_km = distance(
                                            pickLat,
                                            pickLong,
                                            deliveryLat,
                                            deliveryLong);

                                        amount =(distance_km * double.parse('${widget.orderSetting[0]["PerKM"]}'));
                                        print("dy ${distance_km}");
                                      }*/
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "${existingDeliveryAddress[index]["name"]} - ${existingDeliveryAddress[index]["mobileNo"]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "${existingDeliveryAddress[index]["address"]} - ${existingDeliveryAddress[index]["completeAddress"]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                      choossedDeliveryAddress ==
                                                              index
                                                          ? Icons.beenhere
                                                          : Icons.remove_circle,
                                                      color:
                                                          choossedDeliveryAddress ==
                                                                  index
                                                              ? Colors.green
                                                              : Colors.red)
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 1.5,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Container(
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                  backgroundColor: Colors.white,
                ),
                SizedBox(
                  height: 15,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border(
                              top: BorderSide(color: Colors.grey.shade500),
                              bottom:
                                  BorderSide(color: Colors.grey.shade500)))),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Mode of Payment for Delivery",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Radio(
                                value: "COD",
                                onChanged: (value) {
                                  setState(() {
                                    PaymentMode = value;
                                    _cashFrom = "pickUp";
                                  });
                                  //amountcalc();
                                },
                                groupValue: PaymentMode,
                              ),
                              Text(
                                "COD",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Radio(
                                value: "Online",
                                onChanged: (value) {
                                  setState(() {
                                    PaymentMode = value;
                                    //temp for checking
                                    _cashFrom = "online";
                                  });
                                  //amountcalc();
                                },
                                groupValue: PaymentMode,
                              ),
                              Text(
                                "Online",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                PaymentMode == "COD"
                    ? Padding(
                        padding: const EdgeInsets.only(left: 30, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Collect Cash From",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Radio(
                                  value: "pickUp",
                                  onChanged: (value) {
                                    setState(() {
                                      _cashFrom = value;
                                    });
                                    //amountcalc();
                                  },
                                  groupValue: _cashFrom,
                                ),
                                Text(
                                  "Pickup Point",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Radio(
                                  value: "delivery",
                                  onChanged: (value) {
                                    setState(() {
                                      _cashFrom = value;
                                    });
                                    //amountcalc();
                                  },
                                  groupValue: _cashFrom,
                                ),
                                Text(
                                  "Delivery Point",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    : Container(),
                cashFromErrorMsg == ""
                    ? Container()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 25, bottom: 15),
                          child: Text(cashFromErrorMsg,
                              style: TextStyle(
                                  color: Colors.redAccent.shade700,
                                  fontSize: 13)),
                        ),
                      ),
                SizedBox(
                  height: 15,
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border(
                              top: BorderSide(color: Colors.grey.shade500),
                              bottom:
                                  BorderSide(color: Colors.grey.shade500)))),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border:
                          Border(bottom: BorderSide(color: Colors.black38))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "WEIGHT LIMIT    ",
                            style: TextStyle(
                                fontSize: 15,
                                color: cnst.appPrimaryMaterialColor1,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(deliveryType.weightlimit,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54)),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, top: 8.0),
                            child: Text(
                              "Delivery Type",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Radio(
                                value: "Normal Delivery",
                                onChanged: (value) {
                                  setDeliveryMode(value);
                                  /*setState(() {
                                    DeliverMode = value;
                                  });*/
                                  //amountcalc();
                                  showTopMessage(
                                      "Your Delivery will be done in next 2.5 hours");
                                },
                                groupValue: DeliverMode,
                              ),
                              Text(
                                "Normal",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Radio(
                                value: "Express Delivery",
                                onChanged: (value) {
                                  setDeliveryMode(value);
                                  showTopMessage(
                                      "Your Delivery will be done in next 1 hour");
                                },
                                groupValue: DeliverMode,
                              ),
                              Text(
                                "Express",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 15, bottom: 15),
                  child: Column(
                    children: <Widget>[
                      /*Row(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: <Widget>[
                                                            Text(
                                                              "Promo Code ",
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                            Text(
                                                              "See Offers",
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: cnst.appPrimaryMaterialColor1,
                                                                  fontWeight: FontWeight.bold),
                                                            ),
                                                          ],
                                                        ),*/
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _navigateAndDisplaySelection(context);
                              },
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: edtPromoCode,
                                  cursorColor: cnst.appPrimaryMaterialColor2,
                                  scrollPadding: EdgeInsets.all(0),
                                  decoration: InputDecoration(
                                      counterText: "",
                                      border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.black),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      hintText: "PROMO CODE"),
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: SizedBox(
                              height: 45,
                              child: FlatButton(
                                disabledColor: Colors.grey,
                                color: cnst.appPrimaryMaterialColor2,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(4.0)),
                                onPressed: () {
                                  _amountCal(
                                      pickLat.toString(),
                                      pickLong.toString(),
                                      deliveryLat.toString(),
                                      deliveryLong.toString());
                                },
                                child: Text(
                                  "APPLY",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade600),
                // Container added beloew the promo code -kd 17-08-2020
                Container(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 5, bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade400))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      note == "" || note == null
                          ? Container()
                          : Text("Note : ${note}",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: IconButton(
                                icon: Icon(Icons.info_outline),
                                onPressed: () {
                                  _BottomSheetInfo(context);
                                }),
                          ),
                          Expanded(
                            child: totalamount == null || totalamount == ""
                                ? Text(cnst.Inr_Rupee + "0.00",
                                    style: TextStyle(
                                        color: cnst.appPrimaryMaterialColor1,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold))
                                : Text(
                                    cnst.Inr_Rupee + " ${totalamount + ".00"}",
                                    style: TextStyle(
                                        color: cnst.appPrimaryMaterialColor1,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 5),
                            height: 40,
                            decoration: BoxDecoration(
                                color: cnst.appPrimaryMaterialColor1,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(10.0)),
                              onPressed: () {
                                bool isValidate = true;
                                if (_formkey.currentState.validate()) {
                                  if (pickAddress == "") {
                                    setState(() {
                                      pickAddressErrorMsg =
                                          "Please select PickUp Address";
                                    });
                                    isValidate = false;
                                  }
                                  /*if (arriveType == "") {
                                                              setState(() {
                                                                ariveTypeErrorMsg = "Please select Arive Time";
                                                              });
                                                              isValidate = false;
                                                            }
                                                            if (arivalTime == "") {
                                                              setState(() {
                                                                timeErrorMsg = "Please select Time";
                                                              });
                                                              isValidate = false;
                                                            }*/
                                  if (deliverAddress == "") {
                                    setState(() {
                                      deliverAddressErrorMsg =
                                          "Please select Delivery Address";
                                    });
                                    isValidate = false;
                                  }
                                  if (isValidate == true) {
                                    if (PaymentMode == "COD") {
                                      _placeOrder();
                                    } else {
                                      startPayment();
                                      //added  bt -arpit payment chaecking  17-08-2020
                                      //_placeOrder();
                                    }
                                  }
                                } else {
                                  if (pickAddress == "") {
                                    setState(() {
                                      pickAddressErrorMsg =
                                          "Please select PickUp Address";
                                    });
                                  }
                                  if (arriveType == "") {
                                    setState(() {
                                      ariveTypeErrorMsg =
                                          "Please select Arive Time";
                                    });
                                  }
                                  if (arivalTime == "") {
                                    setState(() {
                                      timeErrorMsg = "Please select Time";
                                    });
                                  }
                                  if (deliverAddress == "") {
                                    setState(() {
                                      deliverAddressErrorMsg =
                                          "Please select Delivery Address";
                                    });
                                  }
                                  if (_cashFrom == "") {
                                    setState(() {
                                      cashFromErrorMsg =
                                          "Please select Point of collectibng Cash";
                                    });
                                  }
                                }
                              },
                              child: Text(
                                "Place Order",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        /*bottomNavigationBar: Container(
                                            padding:
                                            const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border(top: BorderSide(color: Colors.grey.shade400))),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                note == "" || note == null
                                                    ? Container()
                                                    : Text("Note : ${note}",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold)),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 2.0),
                                                      child: IconButton(
                                                          icon: Icon(Icons.info_outline),
                                                          onPressed: () {
                                                            _BottomSheetInfo(context);
                                                          }),
                                                    ),
                                                    Expanded(
                                                      child: totalamount == null || totalamount == ""
                                                          ? Text(cnst.Inr_Rupee + "0.00",
                                                          style: TextStyle(
                                                              color: cnst.appPrimaryMaterialColor1,
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.bold))
                                                          : Text(cnst.Inr_Rupee + " ${totalamount + ".00"}",
                                                          style: TextStyle(
                                                              color: cnst.appPrimaryMaterialColor1,
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.bold)),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                          color: cnst.appPrimaryMaterialColor1,
                                                          borderRadius: BorderRadius.all(Radius.circular(10))),
                                                      child: MaterialButton(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: new BorderRadius.circular(10.0)),
                                                        onPressed: () {
                                                          bool isValidate = true;
                                                          if (_formkey.currentState.validate()) {
                                                            if (pickAddress == "") {
                                                              setState(() {
                                                                pickAddressErrorMsg =
                                                                "Please select PickUp Address";
                                                              });
                                                              isValidate = false;
                                                            }
                                                            */ /*if (arriveType == "") {
                                                              setState(() {
                                                                ariveTypeErrorMsg = "Please select Arive Time";
                                                              });
                                                              isValidate = false;
                                                            }
                                                            if (arivalTime == "") {
                                                              setState(() {
                                                                timeErrorMsg = "Please select Time";
                                                              });
                                                              isValidate = false;
                                                            }*/ /*
                                                            if (deliverAddress == "") {
                                                              setState(() {
                                                                deliverAddressErrorMsg =
                                                                "Please select Delivery Address";
                                                              });
                                                              isValidate = false;
                                                            }
                                                            if (isValidate == true) {
                                                              if (PaymentMode == "COD") {
                                                                _placeOrder();
                                                              } else {
                                                                startPayment();
                                                              }
                                                            }
                                                          } else {
                                                            if (pickAddress == "") {
                                                              setState(() {
                                                                pickAddressErrorMsg =
                                                                "Please select PickUp Address";
                                                              });
                                                            }
                                                            if (arriveType == "") {
                                                              setState(() {
                                                                ariveTypeErrorMsg = "Please select Arive Time";
                                                              });
                                                            }
                                                            if (arivalTime == "") {
                                                              setState(() {
                                                                timeErrorMsg = "Please select Time";
                                                              });
                                                            }
                                                            if (deliverAddress == "") {
                                                              setState(() {
                                                                deliverAddressErrorMsg =
                                                                "Please select Delivery Address";
                                                              });
                                                            }
                                                            if (_cashFrom == "") {
                                                              setState(() {
                                                                cashFromErrorMsg =
                                                                "Please select Point of collectibng Cash";
                                                              });
                                                            }
                                                          }
                                                        },
                                                        child: Text(
                                                          "Place Order",
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 17.0,
                                                              fontWeight: FontWeight.w600),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),*/
      ),
    );
  }

  showTopMessage(String s) {
    Vibration.vibrate();
    Flushbar(
      title: "Note:",
      message: s,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      backgroundColor: Color(0xFFaa356f),
      margin: EdgeInsets.all(16.0),
      borderRadius: 16.0,
    )..show(context);
  }
}
