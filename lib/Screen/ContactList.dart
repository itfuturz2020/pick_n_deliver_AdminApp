import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pickndeliver/Common/Constants.dart';
import 'package:pickndeliver/Common/Services.dart';
import 'package:pickndeliver/Screen/AddNewOrder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickndeliver/Common/Constants.dart' as cnst;

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<Contact> _contacts = new List<Contact>();
  List<CustomContact> _uiCustomContacts = List<CustomContact>();
  List<CustomContact> _searchContact = List<CustomContact>();

  bool _isLoading = true, isSearching = false;
  List _selectedContact = [];
  List _dataPass = [];

  TextEditingController txtSearch = new TextEditingController();

  @override
  void initState() {
    refreshContacts();
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts(
        withThumbnails: false, photoHighResolution: false);
    _populateContacts(contacts);
  }

  void _populateContacts(Iterable<Contact> contacts) {
    _contacts = contacts.where((item) => item.displayName != null).toList();
    _contacts.sort((a, b) => a.displayName.compareTo(b.displayName));
    setState(() {
      _uiCustomContacts =
          _contacts.map((contact) => CustomContact(contact: contact)).toList();
      _searchContact =
          _contacts.map((contact) => CustomContact(contact: contact)).toList();
      _isLoading = false;
    });
  }

  ListTile _buildListTile(CustomContact c, List<Item> list) {
    return ListTile(
      onTap: () {
        print(list[0].value);
        _dataPass.add(list[0].value.replaceAll("+91", ""));
        _dataPass.add(c.contact.displayName);
        Navigator.pop(context, _dataPass);
      },
      leading: CircleAvatar(
        child: Text(
          c.contact.displayName.toUpperCase().substring(0, 1) ?? "",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
      ),
      title: Text(c.contact.displayName ?? ""),
      subtitle: list.length >= 1 && list[0]?.value != null
          ? Text(list[0].value)
          : Text(''),
      /*trailing: Checkbox(
          activeColor: Colors.green,
          value: c.isChecked,
          onChanged: (bool value) {
            _onChange(value, c, list);
          }),*/
    );
  }

  _onChange(value, CustomContact c, List<Item> list) {
    if (list.length >= 1 &&
        list[0]?.value != null &&
        c.contact.displayName != "") {
      String mobile = list[0].value.toString();
      String name = c.contact.displayName.toString();
      mobile = mobile.replaceAll(" ", "");
      mobile = mobile.replaceAll("-", "");
      mobile = mobile.replaceAll("+91", "");
      mobile = mobile.replaceAll(RegExp("^091"), "");
      mobile = mobile.replaceAll("+091", "");
      mobile = mobile.replaceAll(RegExp("^0"), "");
      print("mobile" + mobile);
      if (value) {
        if (mobile.length == 10) {
          setState(() {
            c.isChecked = value;
          });
          _selectedContact.add({
            "Name": "${name}",
            "MobileNo": "${mobile}",
          });
        } else
          Fluttertoast.showToast(
              msg: "Mobile Number Is Not Valid",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              gravity: ToastGravity.TOP,
              toastLength: Toast.LENGTH_SHORT);
      } else {
        setState(() {
          c.isChecked = value;
        });
        for (int i = 0; i < _selectedContact.length; i++) {
          if (_selectedContact[i]["MobileNo"].toString() == mobile)
            _selectedContact.removeAt(i);
        }
      }
      print(_selectedContact);
    } else {
      Fluttertoast.showToast(
          msg: "Contact Is Not Valid",
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_SHORT);
    }
  }

  void searchOperation(String searchText) {
    if (searchText != "") {
      setState(() {
        _searchContact.clear();
        isSearching = true;
      });
      String mobile = "";
      for (int i = 0; i < _uiCustomContacts.length; i++) {
        String name = _uiCustomContacts[i].contact.displayName;
        var _phonesList = _uiCustomContacts[i].contact.phones.toList();
        if (_phonesList.length > 0) mobile = _phonesList[0].value;
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            mobile.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            _searchContact.add(_uiCustomContacts[i]);
          });
        }
      }
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light, // or use Brightness.dark
          title: Text("Choose Contacts",
              style: TextStyle(color: appPrimaryMaterialColor2, fontSize: 18)),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: appPrimaryMaterialColor2,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
              child: TextFormField(
                controller: txtSearch,
                onChanged: searchOperation,
                scrollPadding: EdgeInsets.all(0),
                decoration: InputDecoration(
                    counter: Text(""),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    suffixIcon: Icon(
                      Icons.search,
                      color: cnst.appPrimaryMaterialColor2,
                    ),
                    hintText: "Search Contact"),
                maxLength: 10,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _uiCustomContacts.length > 0
                      ? isSearching
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: _searchContact?.length,
                              itemBuilder: (BuildContext context, int index) {
                                CustomContact _contact = _searchContact[index];
                                var _phonesList =
                                    _contact.contact.phones.toList();
                                return _buildListTile(_contact, _phonesList);
                              },
                            )
                          : ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: _uiCustomContacts?.length,
                              itemBuilder: (BuildContext context, int index) {
                                CustomContact _contact =
                                    _uiCustomContacts[index];
                                var _phonesList =
                                    _contact.contact.phones.toList();
                                return _buildListTile(_contact, _phonesList);
                              },
                            )
                      : Center(
                          child: Text(
                            "No Data Available",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomContact {
  final Contact contact;
  bool isChecked;

  CustomContact({
    this.contact,
    this.isChecked = false,
  });
}
