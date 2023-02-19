import 'dart:convert';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/home.dart';
import 'package:dsign_london/Screen/otp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/link.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController phoneText = TextEditingController();
  bool match = false;
  bool trigger = false;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        margin: EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 40),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 27,
                  ),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setString("LOGIN", "SKIP");
                    Navigator.pop(context);
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: ((context) => Home())));
                  },
                  child: Container(
                    width: 64,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: primaryColor()),
                        borderRadius: BorderRadius.circular(70)),
                    child: Text(
                      "Skip",
                      style: TextStyle(fontSize: 14, fontFamily: "Montserrat"),
                    ),
                  ),
                ),
              ],
            ),
            sizeheight(30),
            Text("Enter Your Mobile number to get OTP",
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Montserrat",
                    color: Colors.black,
                    fontWeight: FontWeight.w600)),
            sizeheight(30),
            Container(
              height: 54,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black54)),
              child: Row(
                children: [
                  sizewidth(10),
                  Text(
                    "+91 |  ",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Montserrat"),
                  ),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: phoneText,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Montserrat"),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "10 digit Mobile number",
                        hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Montserrat"),
                      ),
                      onChanged: (value) {
                        if (value.length == 10) {
                          setState(() {
                            match = true;
                          });
                        } else {
                          setState(() {
                            match = false;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
            sizeheight(30),
            RichText(
              text: TextSpan(
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: "Montserrat"),
                children: <TextSpan>[
                  TextSpan(text: 'By clicking. i accept the '),
                  TextSpan(
                      text: 'terms of service',
                      style: TextStyle(color: Colors.blue)),
                  TextSpan(
                    text: ' and privacy policy',
                  )
                ],
              ),
            ),
            Expanded(child: Container()),
            InkWell(
              onTap: () {
                if (match && !trigger) {
                  setState(() {
                    trigger = true;
                  });
                  sendOtp();
                }
              },
              child: Container(
                height: 54,
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(70),
                    color: (!match) ? Colors.grey : primaryColor()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!trigger)
                      Text(
                        "  GET OTP  ",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Montserrat"),
                      ),
                    if (trigger)
                      LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white, size: 30)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  test() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((context) => otpScreen(
              phoneNumber: phoneText.text.trim(),
              otpId: "1234567", //data["id"].toString(),
              newUser: true,
            ))));
  }

  sendOtp() async {
    final request = await http.post(
        Uri.parse(
          '$baseUrl/send-otp-code',
        ),
        body: ({
          "phone_number": "+91${phoneText.text.trim()}",
        }),
        headers: {'Accept': 'application/json'});
    if (request.statusCode == 200) {
      var data = json.decode(request.body);
      var newUser = true;
      if (data["is_contact_exist"]) {
        newUser = false;
      }

      Navigator.of(context).push(MaterialPageRoute(
          builder: ((context) => otpScreen(
                phoneNumber: phoneText.text.trim(),
                otpId: data["id"].toString(),
                newUser: newUser,
              ))));
    } else {
      setState(() {
        trigger = false;
      });
    }
  }
}
