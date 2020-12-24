import 'package:flutter/material.dart';

//const String API_URL = "https://shrouded-savannah-05270.herokuapp.com/";
String API_URL = "http://13.126.231.240/";
//const String API_URL = "http://13.126.231.240/";
const Inr_Rupee = "₹";
const String whatsAppLink = "https://wa.me/#mobile?text=#msg";
const String smsLink = "sms:#mobile?body=#msg";
const String mailLink = "mailto:#mail?subject=#subject&body=#msg";
const String API_URL_RazorPay_Order =
    "http://razorpayapi.itfuturz.com/Service.asmx/";
String CouponCode = "CouponCode";

class Session {
  static const String Id = "Id";
  static const String Name = "Name";
  static const String Mobile = "Mobile";
  static const String Email = "Email";
  static const String IsVerified = "IsVerified";
  static const String RegCode = "RegCode";
  static const String Image = "Image";
}

class MESSAGES {
  static const String INTERNET_ERROR = "No Internet Connection";
  static const String INTERNET_ERROR_RETRY =
      "No Internet Connection.\nPlease Retry";
}

Map<int, Color> appColorMap1 = {
  50: Color.fromRGBO(56, 31, 113, .1),
  100: Color.fromRGBO(56, 31, 113, .2),
  200: Color.fromRGBO(56, 31, 113, .3),
  300: Color.fromRGBO(56, 31, 113, .4),
  400: Color.fromRGBO(56, 31, 113, .5),
  500: Color.fromRGBO(56, 31, 113, .6),
  600: Color.fromRGBO(56, 31, 113, .7),
  700: Color.fromRGBO(56, 31, 113, .8),
  800: Color.fromRGBO(56, 31, 113, .9),
  900: Color.fromRGBO(56, 31, 113, 1),
};

MaterialColor appPrimaryMaterialColor1 =
    MaterialColor(0xFF381F71, appColorMap1);

Map<int, Color> appColorMap2 = {
  50: Color.fromRGBO(170, 53, 111, .1),
  100: Color.fromRGBO(170, 53, 111, .2),
  200: Color.fromRGBO(170, 53, 111, .3),
  300: Color.fromRGBO(170, 53, 111, .4),
  400: Color.fromRGBO(170, 53, 111, .5),
  500: Color.fromRGBO(170, 53, 111, .6),
  600: Color.fromRGBO(170, 53, 111, .7),
  700: Color.fromRGBO(170, 53, 111, .8),
  800: Color.fromRGBO(170, 53, 111, .9),
  900: Color.fromRGBO(170, 53, 111, 1),
};
MaterialColor appPrimaryMaterialColor2 =
    MaterialColor(0xFFaa356f, appColorMap2);
