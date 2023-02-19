import 'dart:convert';

import 'package:dsign_london/Card/catBox.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Card/flashSale.dart';
import 'package:dsign_london/Screen/Notification.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/Screen/login.dart';
import 'package:dsign_london/Screen/profile.dart';
import 'package:dsign_london/Screen/searchScreen.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/link.dart';

bool isLogged = false;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

String profileUrl =
    "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg";

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadpromotional();
    loadUser();
    UpdateCart();
    loadCart();
  }

  UpdateCart() {
    notify.addListener(() {
      loadCart();
    });
  }

  int count = 0;
  int total = 0;
  int save = 0;
  loadCart() async {
    setState(() {
      save = 0;
      total = 0;
      count = 0;
    });
    Box box = await Hive.openBox("cart");
    for (var id in box.keys) {
      if (box.get(id) != null) {
        productData pd = box.get(id);
        setState(() {
          if (pd.quantity > 0) {
            count++;
            total = total + pd.subTotal;
            save = save + pd.save;
          } else {}
        });
      }
    }
  }

  loadUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("TOKEN").toString();
    if (preferences.getString("LOGIN").toString() == "IN") isLogged = true;
    Box user = await Hive.openBox("user");

    if (user.isNotEmpty && isLogged) {
      userData udata = user.get(1);
      setState(() {
        profileUrl = udata.profileUrl;
      });
    }
  }

  ValueNotifier<int> notify = ValueNotifier<int>(0);
  loadpromotional() async {
    final Response =
        await http.get(Uri.parse("$baseUrl/types/designlondon?language=en"));

    if (Response.statusCode == 200) {
      var js = json.decode(Response.body);

      for (var image in js["banners"]) {
        setState(() {
          promoImage.add(Image.network(
            image["image"]["original"],
            fit: BoxFit.fill,
          ));
        });
      }
    }
  }

  List promoImage = [];
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    String sqty; // convert quantity count to fromatted String model
    if (count < 10)
      sqty = "0$count";
    else
      sqty = count.toString();

    return Scaffold(
      body: Container(
        width: w,
        height: h,
        child: Stack(
          children: [
            Container(
              color: primaryColor(),
              width: w,
              height: h,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: 110,
                        height: 60,
                        child: Image.asset(
                          "assets/icons/newIcon.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Expanded(
                          child: Container(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                  onTap: () {
                                    if (!isLogged) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: ((context) => login())));
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: ((context) =>
                                                  profileScreen())));
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: CircleAvatar(
                                      backgroundColor: (profileUrl ==
                                              "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                          ? Colors.white24
                                          : Colors.white,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          profileUrl,
                                          color: (profileUrl ==
                                                  "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                              ? Colors.white
                                              : null,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  )))),
                      if (!isLogged)
                        SizedBox(
                          width: 19.2,
                        ),
                      if (isLogged)
                        InkWell(
                          onTap: () {
                            loadUser();
                          },
                          child: InkWell(
                            onTap: (() {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) => notifcationScreen())));
                            }),
                            child: Icon(
                              Icons.notifications_none_outlined,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 19.2,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 27,
                  ),
                  Container(
                    width: 358,
                    height: 48,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(70)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.7,
                        ),
                        Icon(
                          Icons.search,
                          color: offsetWhite(),
                        ),
                        const SizedBox(
                          width: 20.7,
                        ),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            onSubmitted: (value) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) => searchScreen(
                                      notify: notify, slug: value))));
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search for items in cart",
                                hintStyle: TextStyle(
                                    color: offsetWhite(),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat')),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                      child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(top: .3, left: 1, right: 1),
                    decoration: BoxDecoration(
                        color:
                            Colors.white, //Color.fromARGB(241, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25))),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (promoImage.length > 1)
                            Container(
                              height: 180,
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 28, bottom: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: ImageSlideshow(
                                    indicatorColor: primaryColor(),
                                    isLoop: true,
                                    autoPlayInterval: 3000,
                                    children: [
                                      for (int i = 1;
                                          i < promoImage.length;
                                          i++)
                                        promoImage[i]
                                    ],
                                  )),
                            ),
                          sizeheight(6),
                          flashSale(
                            notify: notify,
                          ),
                          sizeheight(1),
                          catBox(
                            notify: notify,
                          ),
                          sizeheight(6),
                          if (promoImage.length > 0)
                            Container(
                              width: 390,
                              height: 195,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              padding: EdgeInsets.all(15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: promoImage[0],
                              ),
                            ),
                          if (false) sizeheight(16),
                          if (false)
                            Container(
                              width: 316,
                              height: 111,
                              margin: EdgeInsets.only(left: 23, right: 51),
                              child: Text(
                                "Oops we can't find What your were looking for?",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontFamily: "Montserrat",
                                    color: Color(0xFFC0C0C0),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          if (false) sizeheight(16),
                          if (false)
                            Container(
                              margin: EdgeInsets.only(left: 16, right: 144),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  color: primaryColor()),
                              width: 230,
                              height: 52,
                              alignment: Alignment.center,
                              child: Text(
                                "Request For a Product",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Montserrat",
                                    color: Colors.white),
                              ),
                            ),
                          sizeheight(60),
                          if (count > 0) sizeheight(60)
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                  bottom: 0,
                  width: 390,
                  height: 100,
                  child: Stack(
                    children: [
                      Container(
                        width: 390,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  spreadRadius: .05,
                                  blurRadius: 9.2)
                            ]),
                      ),
                      Positioned(
                          top: 25,
                          left: 28,
                          bottom: 40,
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 40,
                            color: primaryColor(),
                          )),
                      Positioned(
                          top: 26,
                          left: 76,
                          child: Text(
                            "$sqty items",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Montserrat"),
                          )),
                      Positioned(
                          top: 26,
                          left: 151,
                          child: Text("$total",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: primaryColor(),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat"))),
                      Positioned(
                          right: 22,
                          bottom: 35,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => cart(
                                        notify: notify,
                                      )));
                            },
                            child: Container(
                              width: 128,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(77),
                                  color: primaryColor()),
                              child: Text("View Cart",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Montserrat")),
                            ),
                          )),
                      Positioned(
                          top: 50,
                          left: 78,
                          child: Text(
                            "90 mins",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w200,
                                fontFamily: "Montserrat"),
                          )),
                      Positioned(
                          right: 173,
                          bottom: 28,
                          child: Container(
                            alignment: Alignment.center,
                            width: 74,
                            height: 21,
                            color: Color.fromARGB(100, 243, 210, 102),
                            child: Text(
                              "Save $save",
                              style: TextStyle(color: primaryColor()),
                            ),
                          ))
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}
