import 'dart:convert';

import 'package:dsign_london/Card/orderTrack.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/orderDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class orderCard extends StatefulWidget {
  var data;
  ValueNotifier notifier;
  orderCard({super.key, required this.data, required this.notifier});

  @override
  State<orderCard> createState() => _orderCardState(data: data);
}

class _orderCardState extends State<orderCard> {
  var data;
  _orderCardState({required this.data});
  bool showTimeline = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convert();
  }

  convert() {
    DateTime dt = DateTime.parse(data["created_at"]);

    Date = DateFormat('MMM-dd-yyyy ').format(dt);
    setState(() {
      Status.add(data["status"]["name"]);

      Status.add(data["status"]["color"]);
    });
  }

  Color HexaColor(String strcolor, {int opacity = 15}) {
    //opacity is optional value
    strcolor = strcolor.replaceAll("#", ""); //replace "#" with empty value
    String stropacity = opacity.toRadixString(16);
    try {
      return Color(int.parse("$stropacity$stropacity" + strcolor, radix: 16));
    } on Exception catch (_, e) {
      return Colors.orange.shade100;
    } //convert integer opacity to Hex String

    //here color format is 0xFFDDDDDD, where FF is opacity, and DDDDDD is Hex Color
  }

  List Status = [];
  String Date = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        sizeheight(16),
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              return orderDetails(
                data: data,
                notifier: widget.notifier,
              );
            })));
          },
          child: Container(
            height: 136,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey)),
            margin: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                    top: 12,
                    left: 12,
                    child: Text(
                      "Order#${data["id"]}",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 40,
                    left: 13,
                    child: Text(
                      "Total Amount   :",
                      style: TextStyle(
                          color: Color(0XFFB5B3B3),
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 72,
                    left: 13,
                    child: Text(
                      "No.items           :",
                      style: TextStyle(
                          color: Color(0XFFB5B3B3),
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 102,
                    left: 13,
                    child: Text(
                      "Order Date   :",
                      style: TextStyle(
                          color: Color(0XFFB5B3B3),
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 40,
                    left: 117,
                    child: Text(
                      "₹ ${data["total"]}",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 72,
                    left: 117,
                    child: Text(
                      "${(data["products"].length)} Items",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                Positioned(
                    top: 102,
                    left: 117,
                    child: Text(
                      "$Date",
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    )),
                if (Status.length == 2)
                  Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: HexaColor(Status[1], opacity: 40),
                        ),
                        child: Text(Status[0],
                            style: TextStyle(
                                fontSize: 12,
                                color: HexaColor(Status[1], opacity: 100),
                                fontFamily: "Montserrat",
                                fontWeight: FontWeight.w600)),
                      )),
                Positioned(
                    right: 20,
                    bottom: 20,
                    child: AnimatedSize(
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 200),
                      child: InkWell(
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            (showTimeline)
                                ? showTimeline = false
                                : showTimeline = true;
                          });
                        },
                        child: AnimatedRotation(
                          turns: (showTimeline) ? 2 / 8 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ),
        AnimatedContainer(
            height: (showTimeline) ? 370 : 0,
            curve: Curves.easeIn,
            duration: const Duration(milliseconds: 200),
            child: (showTimeline)
                ? OrderTrack(
                    data: data,
                  )
                : OrderTrack(
                    data: data,
                  )), // Visibility(visible: showTimeline,child: OrderTrack())),
      ],
    );
  }
}
