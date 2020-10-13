import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;
import 'package:pickndeliver/Common/Services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  TextEditingController edtName = new TextEditingController();
  TextEditingController edtMobileNo = new TextEditingController();
  TextEditingController edtEmail = new TextEditingController();
  File _userImage;
  String _path, _fileName;
  ProgressDialog pr;
  String Id, Name, Email, Mobile;

  @override
  void initState() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
    _getLocal();
  }

  _getLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Id = prefs.getString(cnst.Session.Id);
      Name = prefs.getString(cnst.Session.Name);
      Email = prefs.getString(cnst.Session.Email);
      Mobile = prefs.getString(cnst.Session.Mobile);
    });
    _setData();
  }

  _setData() {
    edtName.text = Name;
    edtEmail.text = Email;
    edtMobileNo.text = Mobile;
  }

/*
  _userImagePopup(BuildContext context) {
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
                          _userImage = image;
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
                          _userImage = image;
                        });
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }
*/

  _updateProfile() async {
    if (edtName.text == "") {
      Fluttertoast.showToast(
          msg: "Please enter Name",
          backgroundColor: cnst.appPrimaryMaterialColor2,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG);
    } else if (edtEmail.text == "") {
      Fluttertoast.showToast(
          msg: "Please enter Email",
          backgroundColor: cnst.appPrimaryMaterialColor2,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG);
    } else if (edtMobileNo.text == "") {
      Fluttertoast.showToast(
          msg: "Please enter Mobile No",
          backgroundColor: cnst.appPrimaryMaterialColor2,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG);
    } else {
      try {
        //check Internet Connection
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          pr.show();
          String filename = "";
          String filePath = "";
          File compressedFile;

          if (_userImage != null) {
            ImageProperties properties =
                await FlutterNativeImage.getImageProperties(_userImage.path);

            compressedFile = await FlutterNativeImage.compressImage(
              _userImage.path,
              quality: 100,
              targetWidth: 600,
              targetHeight:
                  (properties.height * 600 / properties.width).round(),
            );

            filename = _userImage.path.split('/').last;
            filePath = compressedFile.path;
          } else if (_path != null && _path != '') {
            filePath = _path;
            filename = _fileName;
          }

          var data = {
            "id": Id,
            "name": edtName.text,
            "email": edtEmail.text,
            "profilepic":
                /*(filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                filename: filename.toString())
                : null*/
                "",
          };
          //UpdateProfile
          Services.UpdateProfile(data).then((data) async {
            if (data.IsSuccess == true) {
              pr.hide();
              print("dataaaaa: ${data.Data}");
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.setString(cnst.Session.Name, edtName.text);
              prefs.setString(cnst.Session.Email, edtEmail.text);
              //prefs.setString(cnst.Session.Image, data.Content[0]["mobileno"]);
              Navigator.pushReplacementNamed(context, '/Home');
            } else {
              pr.hide();
              showMsg("Try Again.");
            }
          }, onError: (e) {
            pr.hide();
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        showMsg("No Internet Connection.");
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light, // or use Brightness.dark
          centerTitle: true,
          iconTheme: new IconThemeData(color: cnst.appPrimaryMaterialColor1),
          title: Text("Profile",
              style: TextStyle(
                  color: cnst.appPrimaryMaterialColor1,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          /* flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                cnst.appPrimaryMaterialColor2,
                cnst.appPrimaryMaterialColor1
              ]))),*/
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).padding.top),
                /*Center(
                  child: GestureDetector(
                    onTap: () {
                      _userImagePopup(context);
                    },
                    child: ClipOval(
                      child: Image.asset(
                        "images/user.png",
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),*/
/*
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _userImagePopup(context);
                    },
                    child: _userImage == null
                        ? ClipOval(
                            child: Image.asset(
                              "images/user.png",
                              width: 150,
                              height: 150,
                            ),
                          )
                        : ClipOval(
                            child: Image.file(
                              File(_userImage.path),
                              width: 150.0,
                              height: 150.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
*/
                SizedBox(height: 30),
                Column(
                  children: <Widget>[
                    Container(
                      height: 55,
                      child: TextFormField(
                        controller: edtName,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "FULL NAME"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: edtEmail,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "EMAIL"),
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Container(
                      height: 55,
                      margin: EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: edtMobileNo,
                        enabled: false,
                        readOnly: true,
                        cursorColor: cnst.appPrimaryMaterialColor2,
                        scrollPadding: EdgeInsets.all(0),
                        decoration: InputDecoration(
                            counterText: "",
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            hintText: "ENTER MOBILE"),
                        maxLength: 10,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 30, bottom: 15),
                      height: 45,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cnst.appPrimaryMaterialColor2,
                                cnst.appPrimaryMaterialColor1
                              ]),
                          borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        //color: cnst.appPrimaryMaterialColor1,
                        minWidth: MediaQuery.of(context).size.width - 20,
                        onPressed: () {
                          _updateProfile();
                        },
                        child: Text(
                          "UPDATE",
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
        ));
  }
}
