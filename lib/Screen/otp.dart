import 'dart:convert';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../Constant/link.dart';

class otpScreen extends StatefulWidget {
  String phoneNumber;
  String otpId;
  bool newUser;
  otpScreen(
      {super.key,
      required this.newUser,
      required this.otpId,
      required this.phoneNumber});

  @override
  State<otpScreen> createState() =>
      _otpScreenState(otpId: otpId, newUser: newUser, phoneNumber: phoneNumber);
}

class _otpScreenState extends State<otpScreen> {
  String phoneNumber;
  String otpId;
  bool newUser;
  _otpScreenState(
      {required this.newUser, required this.otpId, required this.phoneNumber});
  void initState() {
    // TODO: implement initState
    super.initState();
    resend.restart();
  }

  TextEditingController phoneText = TextEditingController();
  bool match = false; // varible to activate button
  bool trigger =
      true; // varible to check verify button is waiting for result  or not
  bool invalid = false;
  CountdownController resend = CountdownController();
  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController otpText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        width: w,
        height: h,
        margin: EdgeInsets.only(left: 20, right: 20, top: 80),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 27,
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              if (newUser) sizeheight(31),
              if (newUser)
                Text("Name",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Montserrat",
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              if (newUser) sizeheight(12),
              if (newUser)
                Container(
                  width: 390,
                  height: 52,
                  padding: EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Color(0XFF6B7280)),
                      color: Colors.white),
                  child: TextField(
                    controller: nameText,
                    onChanged: (value) {
                      if (otpText.text.length > 5 &&
                          nameText.text != "" &&
                          emailText.text != "") {
                        setState(() {
                          match = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Enter Name"),
                  ),
                ),
              if (newUser) sizeheight(16),
              if (newUser)
                Text("Email",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Montserrat",
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              if (newUser) sizeheight(12),
              if (newUser)
                Container(
                  width: 390,
                  height: 52,
                  padding: EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: Color(0XFF6B7280)),
                      color: Colors.white),
                  child: TextField(
                    controller: emailText,
                    onChanged: (value) {
                      if (otpText.text.length > 5 &&
                          nameText.text != "" &&
                          emailText.text != "") {
                        setState(() {
                          match = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Enter Email"),
                  ),
                ),
              sizeheight(30),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text("Enter the OTP sent to \n${phoneNumber}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Montserrat",
                        color: Colors.black,
                        fontWeight: FontWeight.w600)),
              ),
              sizeheight(30),
              Container(
                width: 390,
                alignment: Alignment.centerLeft,
                child: Pinput(
                  length: 6,
                  controller: otpText,
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  defaultPinTheme: PinTheme(
                    width: density(55),
                    height: density(55),
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                    decoration: BoxDecoration(
                        border: Border.all(color: primaryColor()),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.length > 5 && !newUser)
                        match = true;
                      else {
                        if (otpText.text.length > 5 &&
                            nameText.text != "" &&
                            emailText.text != "") {
                          match = true;
                        }
                      }
                    });
                  },
                ),
              ),
              sizeheight(20),
              if (invalid)
                Text(" Invalid OTP",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w500,
                    )),
              sizeheight(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  sizewidth(5),
                  Text(
                    'Didn’t receive it ?',
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ' Retry In 00:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0XFF3AC274),
                        fontFamily: 'Montserrat'),
                  ),
                  Countdown(
                    seconds: 30,
                    build: (BuildContext context, double time) {
                      int rev = time.toInt();
                      String t = rev.toString();
                      if (rev < 10) {
                        t = '0$rev';
                      }
                      return Text(t,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0XFF3AC274),
                              fontFamily: 'Montserrat'));
                    },
                    controller: resend.resume(),
                    onFinished: () {},
                  )
                ],
              ),
              sizeheight(32),
              InkWell(
                onTap: () async {
                  if (trigger && match) {
                    setState(() {
                      trigger = false;
                    });

                    if (newUser) {
                      final response =
                          await http.post(Uri.parse("$baseUrl/otp-login"),
                              body: ({
                                "email": emailText.text.trim(),
                                "name": nameText.text.trim(),
                                "code": otpText.text.trim(),
                                "phone_number": "+91${phoneNumber.trim()}",
                                "otp_id": otpId
                              }));
                      if (response.statusCode == 200) {
                        var js = json.decode(response.body);
                        if (js["success"] != null ||
                            js["success"] == false && js["email"] != null) {
                          if (js["email"] != null)
                            Fluttertoast.showToast(
                                msg: "Email Id already taken");
                          setState(() {
                            trigger = true;
                            invalid = true;
                          });
                        } else {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.setString("TOKEN", js["token"]);
                          preferences.setString("LOGIN", "IN");
                          FetchUserData(js["token"], phoneNumber);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => Home())));
                        }
                      } else {
                        setState(() {
                          trigger = true;
                        });
                        Fluttertoast.showToast(
                            msg: "Something went to wrong \nplease try again");
                      }
                    } else {
                      final response =
                          await http.post(Uri.parse("$baseUrl/otp-login"),
                              body: ({
                                "code": otpText.text.trim(),
                                "phone_number": "+91${phoneNumber.trim()}",
                                "otp_id": otpId
                              }));

                      if (response.statusCode == 200) {
                        var js = json.decode(response.body);
                        if (js["success"] != null && js["success"] == false) {
                          setState(() {
                            invalid = true;
                            trigger = true;
                          });
                        } else {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.setString("TOKEN", js["token"]);
                          preferences.setString("LOGIN", "IN");
                          FetchUserData(js["token"], phoneNumber);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) => Home())));
                        }
                      } else {
                        setState(() {
                          trigger = true;
                        });
                        Fluttertoast.showToast(
                            msg: "Something went to wrong \nplease try again");
                      }
                    }
                  } else if (!match) {
                    Fluttertoast.showToast(msg: "Please fill to continue");
                  }
                },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      color: (!match) ? Colors.grey : primaryColor()),
                  child: (trigger)
                      ? Text(
                          "Verify",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Montserrat"),
                        )
                      : LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white, size: 30),
                ),
              )
            ],
          ),
        ),
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

FetchUserData(String token, String phone) async {
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
    String profileUrl =
        "https://www.oseyo.co.uk/wp-content/uploads/2020/05/empty-profile-picture-png-2.png";

    if (js["profile"]["avatar"] != null)
      profileUrl = js["profile"]["avatar"]["thumbnail"];

    userData udata = new userData(
        name: js["name"],
        email: js["email"],
        id: js['id'],
        phone: phone,
        address: adata,
        profileUrl: profileUrl,
        availablePoint: js["wallet"]["available_points"]);

    user.put(1, udata);
  }
}
