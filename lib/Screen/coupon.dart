import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dashed_rect/dashed_rect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Constant/link.dart';

class coupon extends StatefulWidget {
  ValueNotifier notify;
  coupon({super.key, required this.notify});

  @override
  State<coupon> createState() => _couponState();
}

class _couponState extends State<coupon> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCoupon();
  }

  List CoopData = [];

  int selectedCouponID = -1;
  String selectedCouponName = "";
  TextEditingController selectedCoupon = TextEditingController();
  String errorText = "";
  bool veriftying = false;

  loadCoupon() async {
    final Response = await http.get(Uri.parse("$baseUrl/coupons"));
    if (Response.statusCode == 200) {
      var js = json.decode(Response.body);
      for (var coop in js["data"]) {
        setState(() {
          CoopData.add(coop);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: density(390),
                height: density(114),
                color: primaryColor(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    sizewidth(density(16)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                          radius: density(20),
                          backgroundColor: Color.fromARGB(223, 240, 240, 235)
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          )),
                    ),
                    sizewidth(density(28)),
                    Text(
                      "Apply/Coupon",
                      style: TextStyle(
                          fontSize: density(20),
                          fontWeight: FontWeight.w600,
                          fontFamily: "Montserrat",
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeheight(density(20)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: density(48),
                      margin: EdgeInsets.all(density(20)),
                      padding: EdgeInsets.symmetric(horizontal: density(20)),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(77),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: selectedCoupon,
                              style: TextStyle(
                                  fontSize: density(14),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w500),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: (selectedCouponID == -1)
                                      ? "Enter  Coupon Code"
                                      : "",
                                  hintStyle: TextStyle(
                                      fontSize: density(12),
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w300)),
                            ),
                          ),
                          if (!veriftying)
                            InkWell(
                              onTap: () async {
                                if (selectedCoupon.text.isNotEmpty) {
                                  setState(() {
                                    veriftying = true;
                                  });
                                  final Response = await http.get(Uri.parse(
                                      "$baseUrl/coupons/${selectedCoupon.text.toString()}"));
                                  if (Response.statusCode == 200) {
                                    var js = json.decode(Response.body);
                                    couponData.add(selectedCoupon.text.trim());
                                    couponData.add(js["amount"].toString());
                                    Navigator.pop(context);

                                    widget.notify.value++;
                                  } else {
                                    setState(() {
                                      veriftying = false;
                                      errorText = "Invalid";
                                    });
                                  }
                                }
                              },
                              child: Text("Apply",
                                  style: TextStyle(
                                      color: primaryColor(),
                                      fontSize: density(12),
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w300)),
                            ),
                          if (veriftying)
                            LoadingAnimationWidget.staggeredDotsWave(
                                color: primaryColor(), size: 20)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: density(25)),
                      child: Text(
                        errorText,
                        style: TextStyle(
                            fontSize: density(14),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Montserrat",
                            color: Colors.red),
                      ),
                    ),
                    sizeheight(density(12)),
                    Container(
                      width: double.infinity,
                      height: 1,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    for (int i = 0; i < CoopData.length; i++)
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedCoupon.text =
                                CoopData[i]["code"].toString();
                            selectedCouponID = CoopData[i]["id"];
                            selectedCouponName = CoopData[i]["code"];
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(density(16)),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.withOpacity(.3)))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashedRect(
                                color: primaryColor(),
                                strokeWidth: 1.3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: density(12),
                                      vertical: density(4)),
                                  child: Text(CoopData[i]["code"].toString(),
                                      style: TextStyle(
                                          color: primaryColor(),
                                          fontSize: density(13),
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600)),
                                ),
                              ),
                              sizeheight(density(10)),
                              Text(
                                  (CoopData[i]["description"] != null)
                                      ? CoopData[i]["description"]
                                      : " Save ${CoopData[i]["amount"]}Rs",
                                  style: TextStyle(
                                      fontSize: density(12),
                                      color: Colors.black87,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w300))
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }
}
