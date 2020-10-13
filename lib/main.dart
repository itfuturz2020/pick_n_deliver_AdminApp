import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pickndeliver/Screen/ActiveOrderDetails.dart';
import 'package:pickndeliver/Screen/AddNewOrder.dart';
import 'package:pickndeliver/Screen/ContactList.dart';
import 'package:pickndeliver/Screen/Coupons_offers.dart';
import 'package:pickndeliver/Screen/Help.dart';
import 'package:pickndeliver/Screen/Home.dart';
import 'package:pickndeliver/Screen/Login.dart';
import 'package:pickndeliver/Screen/MyProfile.dart';
import 'package:pickndeliver/Screen/OTP.dart';

import 'package:pickndeliver/Screen/OrderPlaced.dart';
import 'package:pickndeliver/Screen/Orders.dart';
import 'package:pickndeliver/Screen/Setting.dart';
import 'package:pickndeliver/Screen/SignUp.dart';
import 'package:pickndeliver/Screen/Splash.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Screen/TermsAndCondition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotification(
            message["notification"]["title"], message["notification"]["body"]);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings);
  }

  showNotification(String title, String body) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin
        .show(0, '${title}', '${body}', platform, payload: 'Pick N Delivere');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick n Delivere',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/ActiveOrderDetails': (context) => ActiveOrderDetails(),
        '/AddNewOrder': (context) => AddNewOrder(),
        '/Help': (context) => Help(),
        '/Home': (context) => Home(),
        '/Login': (context) => Login(),
        '/MyProfile': (context) => MyProfile(),
        '/OrderPlaced': (context) => OrderPlaced(),
        '/Setting': (context) => Setting(),
        '/SignUp': (context) => SignUp(),
        '/OTP': (context) => OTP(),
        '/Orders': (context) => OrderScreen(),
        '/TermsAndCondition': (context) => TermsAndCondition(),
        '/ContactList': (context) => ContactList(),
        '/Coupons_offers': (context) => Coupons_offers(),
      },
      theme: ThemeData(
        fontFamily: 'Helvetica',
        primarySwatch: cnst.appPrimaryMaterialColor2,
        accentColor: cnst.appPrimaryMaterialColor2,
      ),
    );
  }
}
