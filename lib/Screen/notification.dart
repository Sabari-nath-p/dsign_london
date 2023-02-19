import 'package:dsign_london/Constant/custom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lottie/lottie.dart';

import '../Constant/Color.dart';

class notifcationScreen extends StatefulWidget {
  const notifcationScreen({super.key});

  @override
  State<notifcationScreen> createState() => _notifcationScreenState();
}

class _notifcationScreenState extends State<notifcationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
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
                      backgroundColor:
                          Color.fromARGB(223, 240, 240, 235).withOpacity(0.2),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      )),
                ),
                sizewidth(density(28)),
                Expanded(
                  child: Text(
                    "Notification",
                    style: TextStyle(
                        fontSize: density(20),
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat",
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
              alignment: Alignment.center,
              height: 500,
              margin: EdgeInsets.all(20),
              child: Lottie.asset(
                "assets/animation/no-notification.json",
              ))
        ],
      )),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }
}
