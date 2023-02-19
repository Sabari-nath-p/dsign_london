import 'dart:convert';

import 'package:dsign_london/Card/productBox.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Converter/verify.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

import '../Constant/link.dart';

class searchScreen extends StatefulWidget {
  ValueNotifier notify;
  String slug;
  searchScreen({super.key, required this.notify, required this.slug});

  @override
  State<searchScreen> createState() => _searchScreenState();
}

class _searchScreenState extends State<searchScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProduct(widget.slug);
    searchController.text = widget.slug;

    Slist.add(widget.slug);

    loadCart();
    UpdateCart();
  }

  TextEditingController searchController = TextEditingController();
  String pageName = "";
  List Product = [];
  List Slist = [];
  UpdateCart() {
    widget.notify.addListener(() {
      loadCart();
    });
  }

  int loading = 0;
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
          }
        });
      }
    }
  }

  loadProduct(String SLUG) async {
    try {
      final response = await http.get(Uri.parse(
          "$baseUrl/products?searchJoin=and&with=type%3Bauthor&searchFields=variations.slug:in&limit=30&language=en&search=name:$SLUG%3Bstatus:publish"));
      var js = json.decode(response.body);
      setState(() {
        Product.clear();
      });

      if (response.statusCode == 200) {
        if (js["data"] != null) {
          for (var v in js['data']) {
            try {
              setState(() {
                if (v['name'] != null) {
                  Product.add(productBox(pdata: v, notify: widget.notify));
                }
              });
            } on Exception catch (_, e) {}
          }
          setState(() {
            loading = 1;
          });
        }
      } else {
        setState(() {
          loading = 2;
        });
      }
    } catch (e) {
      setState(() {
        loading = 2;
      });
    }
  }

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
        body: (loading == 1)
            ? Container(
                width: w,
                height: h,
                color: Colors.white,
                //  color: primaryColor(),
                child: Stack(
                  children: [
                    Positioned(
                      width: w,
                      height: h,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              top: 24,
                            ),
                            width: 390,
                            height: 110,
                            color: primaryColor(),
                            child: Row(
                              children: [
                                sizewidth(16),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                sizewidth(10),
                                Expanded(
                                  child: Container(
                                    height: 46,
                                    padding: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white),
                                    child: TextField(
                                      controller: searchController,
                                      onSubmitted: (value) {
                                        setState(() {
                                          Product = [];
                                        });
                                        loadProduct(value);
                                      },
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.search),
                                          border: InputBorder.none,
                                          hintText: "Search for items in cart",
                                          hintStyle: TextStyle(
                                              color: offsetWhite(),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Montserrat')),
                                    ),
                                  ),
                                ),
                                sizewidth(16)
                              ],
                            ),
                          ),
                          if (Product.isNotEmpty)
                            Expanded(
                                child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (int i = 0; i < Product.length; i++)
                                    Product[i],
                                  sizeheight(20),
                                  if (count > 0) sizeheight(105)
                                ],
                              ),
                            )),
                          if (Product.isEmpty)
                            noData("Sorry, No Product Found :( ")
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (ctx) => cart(
                                                    notify: widget.notify,
                                                  )));
                                    },
                                    child: Container(
                                      width: 128,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(77),
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
              )
            : (loading == 0)
                ? Container(
                    alignment: Alignment.center,
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: primaryColor(), size: 40),
                  )
                : Container(
                    alignment: Alignment.center,
                    child: Lottie.asset("assets/animation/networkError.json")));
  }
}
