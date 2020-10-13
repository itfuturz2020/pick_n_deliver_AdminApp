import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animations/simple_animations.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> animation;

  @override
  void initState() {
    //getSuggestion();
    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);
    animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1, 0.0),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticIn,
    ));

    Timer(Duration(milliseconds: 4000), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String Id = prefs.getString(cnst.Session.Id);
      FirebaseFirestore.instance.collection("PND-URL").get().then((value) {
        cnst.API_URL = "${value.docs[0]["PND-URL"]}";
        if (Id != null && Id != "") {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/Home', (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/Login', (Route<dynamic> route) => false);
        }
      });
    });
    // TODO: implement initState
    super.initState();
  }

  Future getSuggestion() =>
      FirebaseFirestore.instance.collection('PND-URL').get().then((snapshot) {
        print("Firebase Collection" + snapshot.toString());
      });

  @override
  dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF532273), Color(0xFFA33370)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 100.0),
            child: Opacity(
                opacity: 0.1,
                child: Image.asset('images/background.png',
                    height: 550, width: 800)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Center(
                        child: Text(
                          "Parcel\nat your\ndoorstep\n__",
                          style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.justify, // or Alignment.topLeft
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SlideTransition(
                  position: animation,
                  child: Image.asset('images/deliveryBoy.png', height: 200)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Image.asset('images/logo.png',
                          color: Colors.white, width: 120, height: 100),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class FadeIn extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeIn(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final tween = MultiTrackTween([
      // ignore: deprecated_member_use
      Track("opacity")
          .add(Duration(milliseconds: 3000), Tween(begin: 0.0, end: 1.0)),
      Track("translateX").add(
          Duration(milliseconds: 3000), Tween(begin: 0.0, end: 0.0),
          curve: Curves.easeOut)
    ]);

    // ignore: deprecated_member_use
    return ControlledAnimation(
      delay: Duration(milliseconds: (1000 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],
        child: Transform.translate(
            offset: Offset(animation["translateX"], 0), child: child),
      ),
    );
  }
}
