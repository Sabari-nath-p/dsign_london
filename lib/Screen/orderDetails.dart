import 'dart:convert';
import 'dart:io';

import 'package:dsign_london/Card/orderTrack.dart';
import 'package:dsign_london/Constant/locationBottom.dart';
import 'package:dsign_london/Converter/refundOrder.dart';
import 'package:dsign_london/Converter/verify.dart';
import 'package:dashed_rect/dashed_rect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Color.dart';
import '../Constant/custom.dart';
import 'package:http/http.dart' as http;

import '../Constant/link.dart';

class orderDetails extends StatefulWidget {
  var data;
  ValueNotifier notifier;
  orderDetails({super.key, required this.data, required this.notifier});

  @override
  State<orderDetails> createState() => _orderDetailsState(data: data);
}

class _orderDetailsState extends State<orderDetails> {
  var data;
  _orderDetailsState({required this.data});
  bool showTimeline = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    convert();

    loadOder();
    refundcheck();
  }

  String token = "0";
  int val = 0;
  convert() {
    DateTime dt = DateTime.parse(data["created_at"]);
    Date = DateFormat('MMM-dd-yyyy ').format(dt);
    setState(() {
      Status.add(data["status"]["name"]);

      Status.add(data["status"]["color"]);
      if (data["status"]["slug"] == "order-received") val = 1;
      if (data["status"]["slug"] == "order-processing") val = 2;
      if (data["status"]["slug"] == "ready-to-dispatch") val = 2;
      if (data["status"]["slug"] == "order-dispatched") val = 3;
      if (data["status"]["slug"] == "at-local-facility") val = 4;
      if (data["status"]["slug"] == "out-for-delivery") val = 5;
      if (data["status"]["slug"] == "delivered") val = 6;
    });
  }

  loadOder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString("TOKEN").toString();

    final Response = await http.get(
        Uri.parse("$baseUrl/orders/${data["tracking_number"]}?with=refund"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': "application/json"
        });

    if (Response.statusCode == 200) {
      var temp = json.decode(Response.body);

      setState(() {
        data = temp;
        refundcheck();
      });
    }
  }

  refundcheck() {
    setState(() {
      if (data["refund"].toString() == "null")
        refundStatus = 0;
      else if (data["refund"]["status"] == "pending")
        refundStatus = 1;
      else if (data["refund"]["status"] == "approved")
        refundStatus = 2;
      else
        refundStatus = 3;
    });
  }

  Color HexaColor(String strcolor, {int opacity = 15}) {
    //opacity is optional value
    strcolor = strcolor.replaceAll("#", ""); //replace "#" with empty value
    String stropacity =
        opacity.toRadixString(16); //convert integer opacity to Hex String
    try {
      return Color(int.parse("$stropacity$stropacity" + strcolor, radix: 16));
    } on Exception catch (_, e) {
      return Colors.orange.shade100;
    } //c
    //here color format is 0xFFDDDDDD, where FF is opacity, and DDDDDD is Hex Color
  }

  List Status = [];
  String Date = "";
  int refundStatus = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                height: 114,
                width: double.infinity,
                color: primaryColor(),
                child: Row(
                  children: [
                    sizewidth(17),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(.2),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    sizewidth(17),
                    Text(
                      "My Orders",
                      style: TextStyle(
                          fontSize: 25,
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
                    sizeheight(10),
                    Container(
                      height: 142,
                      width: 390,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Colors.grey.withOpacity(.3),
                      ))),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned(
                              top: 18,
                              left: 12,
                              child: Text(
                                "Order#${data["id"]}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600),
                              )),
                          Positioned(
                              top: 46,
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
                              top: 76,
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
                              top: 106,
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
                              top: 46,
                              left: 117,
                              child: Text(
                                "₹ ${data["total"]}",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600),
                              )),
                          Positioned(
                              top: 76,
                              left: 117,
                              child: Text(
                                "${(data["products"].length)} Items",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600),
                              )),
                          Positioned(
                              top: 106,
                              left: 117,
                              child: Text(
                                "$Date",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600),
                              )),
                          if (Status.length == 2)
                            Positioned(
                                right: 10,
                                height: 35,
                                top: 16,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: HexaColor(Status[1], opacity: 40),
                                  ),
                                  child: Text(Status[0],
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: HexaColor(Status[1],
                                              opacity: 100),
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.w600)),
                                )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.only(left: 22),
                      width: 390,
                      height: 370,
                      decoration: BoxDecoration(
                          border: Border(
                        left: BorderSide(color: Colors.grey.withOpacity(.3)),
                        right: BorderSide(color: Colors.grey.withOpacity(.3)),
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
                              ),
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
                            ],
                          ),
                          sizeheight(8)
                        ],
                      ),
                    ),
                    Container(
                      width: 390,
                      height: 1,
                      color: Colors.grey.withOpacity(.3),
                    ),
                    sizeheight(24),
                    Text(
                      "     Order Number- ${data["tracking_number"]}",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    ),
                    sizeheight(11),
                    Row(
                      children: [
                        sizewidth(18),
                        if (refundStatus == 0)
                          InkWell(
                            onTap: () {
                              askforRefund();
                            },
                            child: Container(
                              width: 114,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: primaryColor(),
                                  borderRadius: BorderRadius.circular(40)),
                              child: Text("Ask For Refund",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        if (refundStatus == 1)
                          Container(
                            width: 114,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color(0XFF9D59EE),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text("Refund Pending",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400)),
                          ),
                        if (refundStatus == 2)
                          Container(
                            width: 114,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color(0XFF34D66B),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text("Refund Approved",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400)),
                          ),
                        if (refundStatus == 3)
                          Container(
                            width: 114,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color(0XFFD64734),
                                borderRadius: BorderRadius.circular(40)),
                            child: Text("Refund Rejected",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w400)),
                          ),
                        sizewidth(17),
                        if (false)
                          Icon(
                            Icons.visibility_outlined,
                            size: 22,
                            color: primaryColor(),
                          ),
                        if (false)
                          Text(" Details",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: primaryColor(),
                                  fontFamily: "Montserrat",
                                  fontWeight: FontWeight.w500))
                      ],
                    ),
                    sizeheight(13),
                    Container(
                      width: 390,
                      height: 1,
                      color: Colors.grey.withOpacity(.3),
                    ),
                    sizeheight(20),
                    Text(
                      "      Shipping Address",
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 22, top: 9, bottom: 20),
                      child: Text(
                        "${data["shipping_address"]["street_address"]} ${data["shipping_address"]["city"]} ${data["shipping_address"]["state"]} ,${data["shipping_address"]["zip"]} ${data["shipping_address"]["country"]}",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 390,
                      height: 1,
                      color: Colors.grey.withOpacity(.3),
                    ),
                    Container(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      width: density(390),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sizeheight(density(12)),
                          Text(
                            "    Payment Details",
                            style: TextStyle(
                              fontSize: density(18),
                              fontWeight: FontWeight.w600,
                              fontFamily: "Montserrat",
                            ),
                          ),
                          paymentBox(
                              "Item Total", "₹${data["amount"]}", Colors.black),
                          paymentBox("Partner Delivery charge",
                              "₹${data["delivery_fee"]}", Colors.green),
                          paymentBox("Coupon Discount", "₹${data["discount"]}",
                              Colors.red),
                          paymentBox(
                              "Total", "₹${data["paid_total"]}", Colors.black),
                        ],
                      ),
                    ),
                    sizeheight(10),
                    Text(
                      "    Order Items",
                      style: TextStyle(
                        fontSize: density(18),
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                      ),
                    ),
                    sizeheight(10),
                    if (data["products"] != null)
                      for (var pdata in data["products"]) orderItems(pdata),
                    sizeheight(50)
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  paymentBox(String data1, String data2, Color color) {
    return Container(
      width: density(390),
      height: density(39),
      padding: EdgeInsets.only(
        left: density(19),
        right: density(16),
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(
            data1,
            style: TextStyle(
              fontSize: density(16),
              fontWeight: FontWeight.w500,
              fontFamily: "Montserrat",
            ),
          )),
          Text(
            data2,
            style: TextStyle(
                fontSize: density(16),
                fontWeight: FontWeight.w500,
                fontFamily: "Montserrat",
                color: color),
          )
        ],
      ),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }

  orderItems(var pdata) {
    num aprice = 0;

    if (pdata["price"] != null)
      num aprice = int.parse(pdata["pivot"]["order_quantity"]) * pdata["price"];
    return Container(
      width: density(390),
      height: density(102),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.3)))),
      child: Row(
        children: [
          sizewidth(density(20)),
          SizedBox(
              width: density(70),
              height: density(70),
              child: Image.network(pdata["image"]["thumbnail"])),
          sizewidth(density(8)),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sizeheight(density(20)),
              Expanded(
                flex: 1,
                child: Text(
                  pdata["name"],
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: density(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  pdata["unit"],
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: density(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              sizeheight(density(20)),
            ],
          )),
          Container(
            width: 39,
            height: 39,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primaryColor())),
            child: Text(
              pdata["pivot"]["order_quantity"],
              softWrap: true,
              style: TextStyle(
                color: primaryColor(),
                fontFamily: "Montserrat",
                fontSize: density(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          sizewidth(density(20)),
          SizedBox(
            width: density(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "₹${pdata["pivot"]["subtotal"]}",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: density(17),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                /*     Text(
                  "₹$aprice",
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      fontSize: density(12),
                      color: primaryColor(),
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough),
                )*/
              ],
            ),
          ),
          sizewidth(density(10)),
        ],
      ),
    );
  }

  // File("");
  askforRefund() {
    File? file;
    bool isfile = false;
    bool loading = false;
    TextEditingController reason = TextEditingController();
    TextEditingController Description = TextEditingController();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: ((context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(builder: ((context, setState) {
              return Container(
                height: 492,
                width: 390,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Column(
                  children: [
                    sizeheight(24),
                    Row(
                      children: [
                        sizewidth(17),
                        SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.asset(
                              "assets/icons/refundIcon_01.JPG",
                              fit: BoxFit.fill,
                            )),
                        Text(
                          "Refund",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Montserrat"),
                        )
                      ],
                    ),
                    sizeheight(24),
                    Container(
                      width: 390,
                      height: 46,
                      margin: EdgeInsets.symmetric(horizontal: 17),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey.withOpacity(.3))),
                      child: TextField(
                        controller: reason,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Reason"),
                      ),
                    ),
                    sizeheight(12),
                    Container(
                      width: 390,
                      height: 115,
                      margin: EdgeInsets.symmetric(horizontal: 17),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey.withOpacity(.3))),
                      child: TextField(
                        controller: Description,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Description"),
                      ),
                    ),
                    sizeheight(12),
                    InkWell(
                      onTap: () async {
                        var status = await Permission.storage.request();
                        if (status.isDenied) {
                          if (await Permission.storage.request().isGranted) {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                          } else {
                            Fluttertoast.showToast(
                                msg: " Please grant permission to continue ");
                          }
                        }
                        if (await Permission.storage.isRestricted) {
                          Fluttertoast.showToast(
                              msg: "Permission is not granted");
                        }
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          setState(() {
                            file = File(result.files.single.path!);
                            isfile = true;
                          });
                        }
                      },
                      child: Container(
                          width: 390,
                          height: 115,
                          margin: EdgeInsets.symmetric(horizontal: 17),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(.3))),
                          child: (isfile)
                              ? Image.file(file!)
                              : Image.asset("assets/icons/refundimage_01.JPG")),
                    ),
                    sizeheight(24),
                    if (!loading)
                      InkWell(
                        onTap: () async {
                          if (reason.text == "" && Description.text == "") {
                            Fluttertoast.showToast(
                                msg: "Please enter reason and description");
                            return;
                          } else {
                            RefundOrderData refundOrderData = RefundOrderData();
                            refundOrderData.title = reason.text.trim();
                            refundOrderData.description =
                                Description.text.trim();
                            refundOrderData.orderId = data["id"];

                            var headers = {
                              'Accept': 'application/json',
                              'Authorization': 'Bearer $token',
                              'content-type': 'application/json; charset=utf-8',
                              "content-type": "application/json"
                            };
                            if (isfile) {
                              setState(() {
                                loading = true;
                              });

                              var imagerequest = http.MultipartRequest(
                                'POST',
                                Uri.parse(
                                    'https://api.ecom.alpha.logidots.com/attachments/'),
                              );

                              imagerequest.files
                                  .add(await http.MultipartFile.fromPath(
                                "attachment[]",
                                file!.path,
                              ));
                              imagerequest.headers.addAll(headers);

                              http.StreamedResponse response =
                                  await imagerequest.send();

                              if (response.statusCode == 200) {
                                var igdata =
                                    await response.stream.bytesToString();
                                var imageData = json.decode(igdata);

                                List<Images> images = [];

                                for (var img in imageData) {
                                  Images image = Images();
                                  image.id =
                                      int.parse(img["id"].toString()).toInt();
                                  image.original = img["original"];
                                  image.thumbnail = img["thumbnail"];

                                  images.add(image);
                                }
                                refundOrderData.images = images;
                                //
                                var request = http.Request(
                                    'POST', Uri.parse('$baseUrl/refunds'));
                                request.body =
                                    refundOrderData.toJson().toString();
                                request.headers.addAll(headers);
                                http.StreamedResponse finalResponse =
                                    await request.send();

                                if (finalResponse.statusCode == 200) {
                                  Navigator.of(context).pop();
                                  updateRefundStatus();
                                } else {
                                  Fluttertoast.showToast(msg: "Please retry");
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              } else {
                                Fluttertoast.showToast(msg: "Please retry");
                                setState((() {
                                  loading = false;
                                }));
                              }
                            } else {
                              var request = http.Request(
                                  'POST', Uri.parse('$baseUrl/refunds'));

                              request.body =
                                  refundOrderData.toJson().toString();
                              request.headers.addAll(headers);

                              http.StreamedResponse response =
                                  await request.send();

                              if (response.statusCode == 200) {
                                loadOder();
                                Navigator.pop(context);
                                updateRefundStatus();
                              } else {
                                Fluttertoast.showToast(msg: "Please retry");

                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                          }
                        },
                        child: Container(
                            width: 390,
                            height: 52,
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 17),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: primaryColor()),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat"),
                            )),
                      ),
                    if (loading)
                      Container(
                          width: 390,
                          height: 52,
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 17),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: primaryColor()),
                          child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.white, size: density(20))),
                  ],
                ),
              );
            })),
          );
        }));
  }

  updateRefundStatus() {
    setState(() {
      refundStatus = 1;
    });
  }
}
