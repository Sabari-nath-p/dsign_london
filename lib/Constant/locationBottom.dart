import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Constant/link.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

TextEditingController title = TextEditingController();
TextEditingController country = TextEditingController();
TextEditingController state = TextEditingController();
TextEditingController city = TextEditingController();
TextEditingController zip = TextEditingController();
TextEditingController address = TextEditingController();
setAdress(
  BuildContext context,
  ValueNotifier addressNotify,
) async {
  title.text = "";
  country.text = "India";
  state.text = "Kerala";
  city.text = "";
  zip.text = "";
  address.text = "";
  Box user = await Hive.openBox("user");
  userData udata = user.get(1);

  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              width: 390,
              height: 470,
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeheight(10),
                    Row(children: [
                      SizedBox(
                          height: 50,
                          width: 40,
                          child: Image.asset("assets/image/mapIcon.JPG")),
                      sizewidth(8),
                      Text(
                        "Shipping Address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )
                    ]),
                    Text("  Enter delivery address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                    sizeheight(12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: title,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Title"),
                      ),
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: country,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Country"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: state,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "State"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: city,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "City"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: zip,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Zip"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Container(
                      height: 115,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: address,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Street Address"),
                      ),
                    ),
                    sizeheight(25),
                    InkWell(
                      onTap: () async {
                        if (title.text.trim() != "" &&
                            country.text.trim() != "" &&
                            state.text.trim() != "" &&
                            city.text.trim() != "" &&
                            zip.text.trim() != "" &&
                            address.text.trim() != "") {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();

                          String token =
                              preferences.getString("TOKEN").toString();
                          final Response = await http.put(
                              Uri.parse("$baseUrl/users/${udata.id}"),
                              headers: ({
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer $token'
                              }),
                              body: json.encode({
                                "address": [
                                  {
                                    "title": title.text.trim(),
                                    "type": "Shipping",
                                    "default": true,
                                    "address": {
                                      "country": country.text.trim(),
                                      "state": state.text.trim(),
                                      "zip": zip.text.trim(),
                                      "city": city.text.trim(),
                                      "street_address": address.text.trim()
                                    }
                                  }
                                ]
                              }));

                          if (Response.statusCode == 200) {
                            Navigator.of(context).pop();
                            FetchUserData(token, addressNotify);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please fill all data to continue");
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: primaryColor(),
                            borderRadius: BorderRadius.circular(70)),
                        child: Text("Set Location",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: "Montserrat")),
                      ),
                    ),
                    sizeheight(25)
                  ],
                ),
              ),
            ),
          ));
}

editAddress(BuildContext context, ValueNotifier addressNotify,
    addressData adata) async {
  title.text = adata.title;
  country.text = adata.country;
  state.text = adata.state;
  city.text = adata.city;
  zip.text = adata.zip;
  address.text = adata.address;
  Box user = await Hive.openBox("user");
  userData udata = user.get(1);
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              width: double.infinity,
              height: 470,
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeheight(10),
                    Row(children: [
                      SizedBox(
                          height: 50,
                          width: 40,
                          child: Image.asset("assets/image/mapIcon.JPG")),
                      sizewidth(8),
                      Text(
                        "Shipping Address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )
                    ]),
                    Text("  Enter delivery address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                    sizeheight(12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: title,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Title"),
                      ),
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: country,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Country"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: state,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "State"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: city,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "City"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: zip,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Zip"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Container(
                      height: 115,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: address,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Street Address"),
                      ),
                    ),
                    sizeheight(25),
                    InkWell(
                      onTap: () async {
                        if (title.text.trim() != "" &&
                            country.text.trim() != "" &&
                            state.text.trim() != "" &&
                            city.text.trim() != "" &&
                            zip.text.trim() != "" &&
                            address.text.trim() != "") {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();

                          String token =
                              preferences.getString("TOKEN").toString();
                          final Response = await http.put(
                              Uri.parse(
                                  "https://api.ecom.alpha.logidots.com/users/${udata.id}"),
                              headers: ({
                                'Content-Type': 'application/json',
                                'Accept': 'application/json',
                                'Authorization': 'Bearer $token'
                              }),
                              body: json.encode({
                                "id": udata.id,
                                "address": [
                                  {
                                    "id": adata.id,
                                    "title": title.text.trim(),
                                    "type": "Shipping",
                                    "default": true,
                                    "address": {
                                      "country": country.text.trim(),
                                      "state": state.text.trim(),
                                      "zip": zip.text.trim(),
                                      "city": city.text.trim(),
                                      "street_address": address.text.trim()
                                    }
                                  }
                                ]
                              }));

                          if (Response.statusCode == 200) {
                            Navigator.of(context).pop();
                            FetchUserData(token, addressNotify);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please fill all data to continue");
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: primaryColor(),
                            borderRadius: BorderRadius.circular(70)),
                        child: Text("Update Location",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: "Montserrat")),
                      ),
                    ),
                    sizeheight(25)
                  ],
                ),
              ),
            ),
          ));
}

deleteAddress(BuildContext context, addressData adata,
    ValueNotifier addressNotifier) async {
  Box user = await Hive.openBox("user");
  userData udata = user.get(1);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String token = preferences.getString("TOKEN").toString();
  final Response = await http.delete(
    Uri.parse("https://api.ecom.alpha.logidots.com/address/${adata.id}"),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    },
  );

  if (Response.statusCode == 200) {
    FetchUserData(token, addressNotifier);
  }
}
