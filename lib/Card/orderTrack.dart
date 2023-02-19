import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dashed_rect/dashed_rect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class OrderTrack extends StatefulWidget {
  var data;
  OrderTrack({super.key, required this.data});

  @override
  State<OrderTrack> createState() => _OrderTrackState(data: data);
}

class _OrderTrackState extends State<OrderTrack> {
  var data;
  _OrderTrackState({required this.data});
  double val = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convert();
  }

  convert() {
    setState(() {
      if (data["status"]["slug"] == "order-received") val = 1;
      if (data["status"]["slug"] == "order-processing") val = 2;
      if (data["status"]["slug"] == "ready-to-dispatch") val = 2.5;
      if (data["status"]["slug"] == "order-dispatched") val = 3;
      if (data["status"]["slug"] == "at-local-facility") val = 4;
      if (data["status"]["slug"] == "out-for-delivery") val = 5;
      if (data["status"]["slug"] == "delivered") val = 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.only(left: 22),
        width: 390,
        height: 370,
        decoration: BoxDecoration(
            border: Border(
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey),
          bottom: BorderSide(color: Colors.grey),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            sizeheight(30),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 0) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 0)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "Order Received",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                )
              ],
            ),
            Container(
              width: 2,
              color: (val > 1) ? primaryColor() : null,
              height: 30,
              margin: EdgeInsets.only(left: 14),
              child: (val <= 1)
                  ? DashedRect(
                      gap: 1.5,
                      strokeWidth: 2,
                      color: primaryColor(),
                    )
                  : null,
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 1) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 1)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "Order Processing",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                )
              ],
            ),
            Container(
              width: 2,
              color: (val > 2) ? primaryColor() : null,
              height: 30,
              margin: EdgeInsets.only(left: 14),
              child: (val <= 2)
                  ? DashedRect(
                      gap: 1.5,
                      strokeWidth: 2,
                      color: primaryColor(),
                    )
                  : null,
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 2) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 2)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "Order Dispatched",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                )
              ],
            ),
            Container(
              width: 2,
              color: (val > 3) ? primaryColor() : null,
              height: 30,
              margin: EdgeInsets.only(left: 14),
              child: (val <= 3)
                  ? DashedRect(
                      gap: 1.5,
                      strokeWidth: 2,
                      color: primaryColor(),
                    )
                  : null,
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 3) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 3)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "At local Facility",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                )
              ],
            ),
            Container(
              width: 2,
              color: (val > 4) ? primaryColor() : null,
              height: 30,
              margin: EdgeInsets.only(left: 14),
              child: (val <= 4)
                  ? DashedRect(
                      gap: 1.5,
                      strokeWidth: 2,
                      color: primaryColor(),
                    )
                  : null,
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 4) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 4)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "Out of delivery",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                )
              ],
            ),
            Container(
              width: 2,
              color: (val > 5) ? primaryColor() : null,
              height: 30,
              margin: EdgeInsets.only(left: 14),
              child: (val <= 5)
                  ? DashedRect(
                      gap: 1.5,
                      strokeWidth: 2,
                      color: primaryColor(),
                    )
                  : null,
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: (val > 5) ? primaryColor() : null,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: primaryColor())),
                  child: (val > 5)
                      ? Image.asset(
                          "assets/icons/tick.png",
                          color: Colors.white,
                        )
                      : null,
                ),
                sizewidth(17),
                Text(
                  "Delivered",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Montserrat"),
                ),
                sizeheight(8)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
