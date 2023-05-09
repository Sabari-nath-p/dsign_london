import 'dart:io';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Screen/home.dart';
import 'package:dsign_london/Screen/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checkLogin();
  }

  bool loginCheck = false;

  checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String check = pref.getString("LOGIN").toString();

    if (check == "null" || check == "OUT") {
      Navigator.pop(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: ((context) => login())));
      setState(() {
        loginCheck = true;
      });

      //Navigator.of(context)
      // .push(MaterialPageRoute(builder: ((context) => login())));
    } else if (check == "SKIP") {
      Navigator.pop(context);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: ((context) => Home())));
    } else {
      Navigator.pop(context);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: ((context) => Home())));
    }
  }

  delay() {
    print("first");
    Future.delayed(Duration(microseconds: 600), () {
      print("after");

      load();
    });
  }

  load() {
    setState(() {
      width = 200;
      first = false;
    });
    Future.delayed(Duration(seconds: 1), () {
      print("after");
      checkLogin();
    });
  }

  bool first = true;
  double width = 100;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    print(w);
    if (first) {
      setState(() {
        delay();
      });
    }
    return Scaffold(
        body: (!loginCheck)
            ? Container(
                width: w,
                height: h,
                alignment: Alignment.center,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        width: width,
                        height: width,
                        decoration: BoxDecoration(),
                        duration: Duration(seconds: 1),
                        curve: Curves.fastOutSlowIn,
                        child: Image.asset("assets/icons/appIcon.png"),
                      ),
                    ]))
            : Container());
  }
}
