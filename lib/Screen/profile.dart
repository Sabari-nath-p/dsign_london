import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/Notification.dart';
import 'package:dsign_london/Screen/home.dart';
import 'package:dsign_london/Screen/myAddress.dart';
import 'package:dsign_london/Screen/order.dart';
import 'package:dsign_london/Screen/personal.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/link.dart';
import '../dataType/adressData.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
    listenprofile();
  }

  String name = "";
  String ppUrl =
      "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg";
  String Total = "";
  String token = "";
  String usedCoin = "";
  String available = "";
  late userData personalData;
  int pid = 0;
  ValueNotifier<int> profileUpdate = ValueNotifier(0);

  listenprofile() {
    profileUpdate.addListener(() {
      loadUser();
    });
  }

  loadUser() async {
    Box box = await Hive.openBox("user");
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString("TOKEN").toString();

    final response = await http.get(Uri.parse("$baseUrl/me"),
        headers: ({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }));

    userData u = box.get(1);

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

      if (js["profile"]["avatar"] != null)
        ppUrl = js["profile"]["avatar"]["thumbnail"];

      profileUrl = ppUrl;

      userData udata = new userData(
          name: js["name"],
          email: js["email"],
          id: js['id'],
          phone: u.phone,
          address: adata,
          profileUrl: ppUrl,
          availablePoint: js["wallet"]["available_points"]);
      name = udata.name;
      Total = js["wallet"]["total_points"].toString();
      available = js["wallet"]["available_points"].toString();
      usedCoin = js["wallet"]["points_used"].toString();
      pid = js["profile"]["id"];
      box.put(1, udata);
      personalData = udata;

      setState(() {
        loading = 1;
      });
    }
  }

  int loading = 0;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
          body: (loading == 1)
              ? Container(
                  height: h,
                  width: w,
                  color: primaryColor(),
                  child: Column(
                    children: [
                      Container(
                        height: density(238),
                        width: w,
                        child: Stack(
                          children: [
                            Positioned(
                                left: density(16),
                                top: density(45),
                                right: density(334),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: primaryColor(),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                            Positioned(
                                left: density(100),
                                right: density(100),
                                top: density(30),
                                height: density(100),
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white)),
                                  child: CircleAvatar(
                                    backgroundColor: (ppUrl ==
                                            "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                        ? Colors.white24
                                        : Colors.white,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: SizedBox(
                                        width: density(95),
                                        height: density(95),
                                        child: Image.network(
                                          ppUrl,
                                          color: (ppUrl ==
                                                  "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                              ? Colors.white
                                              : null,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            Positioned(
                                left: density(80),
                                right: density(80),
                                top: density(135),
                                height: density(100),
                                child: Text(
                                  "$name",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Montserrat",
                                      color: Colors.white),
                                )),
                            Positioned(
                                top: density(170),
                                left: density(55),
                                right: density(55),
                                child: Container(
                                  width: density(263),
                                  height: density(63),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 7),
                                  decoration: BoxDecoration(
                                      color: Colors.black12.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                          color: Colors.yellowAccent
                                              .withOpacity(.2))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      coinBox("$available", "Available"),
                                      Container(
                                        width: 1,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        height: double.infinity,
                                        color: Colors.white10,
                                      ),
                                      coinBox("$usedCoin", "Used Coins"),
                                      Container(
                                        width: 1,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        height: double.infinity,
                                        color: Colors.white10,
                                      ),
                                      coinBox("$Total", "  Total"),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                      sizeheight(25),
                      Expanded(
                        child: Container(
                          width: w,
                          height: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(35),
                                  topRight: Radius.circular(35))),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                sizeheight(25),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: ((context) => Personal(
                                                  udata: personalData,
                                                  profileNotify: profileUpdate,
                                                  pid: pid,
                                                ))));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        sizewidth(5),
                                        SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                "assets/icons/profileDetails.png")),
                                        sizewidth(10),
                                        Expanded(
                                          child: Text(
                                            "Profile details",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.grey,
                                        ),
                                        sizewidth(
                                          10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                sizeheight(30),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: ((context) => orderScreen(
                                                  token: token,
                                                ))));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        sizewidth(5),
                                        SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                "assets/icons/myOrder.png")),
                                        sizewidth(10),
                                        Expanded(
                                          child: Text(
                                            "My Order",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.grey,
                                        ),
                                        sizewidth(
                                          10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                sizeheight(30),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: ((context) => myAddress(
                                                  token: token,
                                                ))));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        sizewidth(5),
                                        SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                "assets/icons/myAddress.png")),
                                        sizewidth(10),
                                        Expanded(
                                          child: Text(
                                            "My Address",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.grey,
                                        ),
                                        sizewidth(
                                          10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                sizeheight(30),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                notifcationScreen())));
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        sizewidth(5),
                                        SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                "assets/icons/notification.png")),
                                        sizewidth(10),
                                        Expanded(
                                          child: Text(
                                            "Notification",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.grey,
                                        ),
                                        sizewidth(
                                          10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                          width: 390,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: Colors.white, width: 10)),
                          padding: EdgeInsets.only(left: 22, bottom: 22),
                          child: InkWell(
                            onTap: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              Box box = await Hive.openBox("user");
                              box.deleteFromDisk();
                              pref.setString("LOGIN", "OUT");
                              isLogged = false;
                              profileUrl =
                                  "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg";
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Log Out",
                              style: TextStyle(
                                fontSize: 16,
                                color: primaryColor(),
                                fontFamily: "Montserrat",
                              ),
                            ),
                          ))
                    ],
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: primaryColor(), size: 40),
                )),
    );
  }

  coinBox(String point, String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: density(20),
                height: density(20),
                child: Image.asset("assets/icons/coin.png"),
              ),
              sizewidth(5),
              Text(
                "$point",
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: "Montserrat",
                    color: Colors.white),
              )
            ],
          ),
          Text(
            "$type",
            style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                fontFamily: "Montserrat",
                color: Colors.white.withOpacity(.8)),
          )
        ],
      ),
    );
  }

  double density(
    double d,
  ) {
    double height = MediaQuery.of(context).size.width;
    double value = d * (height / 390);
    return value;
  }
}
