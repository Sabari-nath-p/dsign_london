import 'dart:convert';
import 'package:dsign_london/Constant/link.dart';
import 'package:dsign_london/Screen/myAddress.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import "package:http/http.dart" as http;

sizewidth(double width) => SizedBox(
      width: width,
    );
sizeheight(double heigth) => SizedBox(
      height: heigth,
    );

noData(String Message) {
  return Stack(
    children: [
      Container(
          height: 600,
          width: 300,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/image/emptyCart.JPG",
          )),
      Positioned(
        top: 390,
        left: 30,
        right: 30,
        child: Text(
          Message,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "Monsterrat",
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w600),
        ),
      )
    ],
  );
}

FetchUserData(String token, ValueNotifier notify) async {
  Box user = await Hive.openBox("user");

  final response = await http.get(Uri.parse("$baseUrl/me"),
      headers: ({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }));

  if (response.statusCode == 200) {
    var js = json.decode(response.body);
    List<addressData> adata = [];
    for (var address in js["address"]) {
      addressData ad = addressData(
          address: (address["address"]["street_address"] != null)
              ? address["address"]["street_address"]
              : "test address",
          city: address["address"]["city"],
          country: address["address"]["country"],
          details: "nil",
          state: address["address"]["state"],
          zip: address["address"]["zip"],
          title: address["title"],
          id: address["id"]);
      adata.add(ad);
    }
    newAdata = adata;
    String profileUrl =
        "https://www.oseyo.co.uk/wp-content/uploads/2020/05/empty-profile-picture-png-2.png";

    if (js["profile"]["avatar"] != null)
      profileUrl = js["profile"]["avatar"]["thumbnail"];
    userData ud = user.get(1);
    userData udata = new userData(
        name: js["name"],
        email: js["email"],
        id: js['id'],
        phone: ud.phone,
        address: adata,
        profileUrl: profileUrl,
        availablePoint: js["wallet"]["available_points"]);

    user.put(1, udata);
    user.close();
    notify.value++;
  }
}
