import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pickndeliver/Common/Constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

bool termscondition = false;


class TermsAndCondition extends StatefulWidget {

  String websiteName;
  String websiteUrl;
  TermsAndCondition({this.websiteName,this.websiteUrl});

  @override
  _TermsAndConditionState createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  bool _isLoadingPage;


  @override
  void initState() {
    _isLoadingPage = true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
           automaticallyImplyLeading: false,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
            Navigator.pop(context);
          }),
          centerTitle: true,
          title: Text("Terms & Conditions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          //title: Text(widget.websiteName,style: TextStyle(fontSize: 15),),
        ),
        body: Stack(
          children: <Widget>[
            WebView(
              initialUrl: "https://webnappmaker.in/pnd/TermsnCondition.html",
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onPageFinished: (finish) {
                setState(() {
                  _isLoadingPage = false;
                });
              },
            ),
            _isLoadingPage
                ? Container(
              alignment: FractionalOffset.center,
              child: CupertinoActivityIndicator(
                radius: 10,
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}