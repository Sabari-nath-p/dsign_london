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

    checkLogin();
  }

  bool loginCheck = false;

  checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String check = pref.getString("LOGIN").toString();
    if (check == "null" || check == "OUT") {
      //Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: (loginCheck)
            ? Container(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    Positioned(
                      width: w,
                      height: h,
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(.7),
                                Colors.black.withOpacity(.2),
                                Colors.transparent,
                                Colors.transparent,
                              ]).createShader(bounds);
                        },
                        child: Image.asset(
                          'assets/image/splashbg.png',
                          fit: BoxFit.cover,
                        ),
                        blendMode: BlendMode.srcATop,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.asset(
                                  "assets/icons/bgclearIcon.png",
                                  fit: BoxFit.fill,
                                )),
                            Text(
                              "City Fesh",
                              style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Axiforma"),
                            ),
                            Text("Groceries Delivered in 90 Minute",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Monsterrat")),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => login()));
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 35, bottom: 35),
                                width: 300,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  color: primaryColor(),
                                ),
                                child: Text(
                                  "Get Started",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Axiforma"),
                                ),
                              ),
                            )
                          ]),
                    )
                  ],
                ),
              )
            : Container());
  }
}
