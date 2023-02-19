import 'dart:convert';
import 'package:dsign_london/Card/productBox.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Constant/link.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

class categoryList extends StatefulWidget {
  String id;
  String slug;
  ValueNotifier notify;
  categoryList(
      {super.key, required this.id, required this.slug, required this.notify});

  @override
  State<categoryList> createState() => _categoryListState(id: id, slug: slug);
}

class _categoryListState extends State<categoryList> {
  String id;
  String slug;
  _categoryListState({required this.id, required this.slug});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProduct(widget.slug);
    loadFilter();
    Slist.add(slug);

    loadCart();
    UpdateCart();
  }

  List Category = [
    "ALL",
  ];
  String pageName = "";
  List Product = [];
  List Slist = [];
  loadFilter() async {
    try {
      print(id);
      final response = await http.get(Uri.parse("$baseUrl/categories/$id"));
      if (response.statusCode == 200) {
        var js = json.decode(response.body);
        pageName = js["name"];
        setState(() {
          for (var v in js["children"]) {
            Category.add(v["name"].toString());
            Slist.add(v["slug"]);
          }
        });
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
          "$baseUrl/products?searchJoin=and&with=type%3Bauthor&searchFields=variations.slug:in&limit=200&orderBy=created_at&sortedBy=DESC&category=ladies-wear&category_id=180&language=en&search=categories.slug:$SLUG%3Bstatus:publish"));

      var js = json.decode(response.body);

      Product.clear();
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        if (js["data"] != null) {
          setState(() {
            for (var v in js['data']) {
              try {
                if (v['name'] != null) {
                  Product.add(productBox(pdata: v, notify: widget.notify));
                }
              } on Exception catch (_, e) {
                print(e);
              }
            }
          });
          print(Product.length);
          setState(() {
            loading = 1;
            catLoading = false;
          });
          print(Product.length);
          print(loading);
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

  int cSelect = 0;
  bool catLoading = true; // varible to control current selected in category
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
                            height: 25,
                            width: double.infinity,
                            color: primaryColor(),
                          ),
                          Container(
                            width: double.infinity,
                            height: 148,
                            child: Stack(
                              children: [
                                Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: primaryColor(),
                                    ) /*Image.asset(
                                      "assets/image/catbg.JPG",
                                      fit: BoxFit.fill,
                                    )*/
                                    ),
                                Positioned(
                                    left: 16,
                                    top: 50,
                                    bottom: 66,
                                    right: 334,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: primaryColor(),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )),
                                Positioned(
                                    left: 16,
                                    bottom: 20,
                                    right: 120,
                                    child: Text(
                                      "$pageName",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat",
                                          color: Colors.white),
                                    ))
                              ],
                            ),
                          ),
                          if (Category.length > 1) sizeheight(14),
                          if (Category.length > 1)
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0; i < Category.length; i++)
                                      Container(
                                        // width: (90),
                                        height: (35),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),

                                        decoration: BoxDecoration(
                                            color: (cSelect == i)
                                                ? primaryColor()
                                                : Colors.white,
                                            border: (cSelect != i)
                                                ? Border.all(
                                                    color: Color(0XFF6B7280),
                                                    width: 1)
                                                : null,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(44))),
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shadowColor: Colors.transparent,
                                                backgroundColor:
                                                    Colors.transparent),
                                            onPressed: () {
                                              setState(() {
                                                cSelect = i;
                                                Product = [];
                                                catLoading = true;
                                                if (i < Slist.length) ;
                                                loadProduct(Slist[i]);
                                              });
                                            },
                                            child: Text(
                                              Category[i],
                                              style: TextStyle(
                                                  color: (cSelect != i)
                                                      ? Color(0XFF171717)
                                                      : Colors.white,
                                                  fontSize: (12),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Montserrat'),
                                            )),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          // if (Category.length > 1) sizeheight(14),
                          if (Product.isEmpty && catLoading == true)
                            Container(
                              padding: EdgeInsets.only(top: 220),
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: primaryColor(), size: 40),
                            ),
                          if (Product.isEmpty && catLoading == false)
                            noData("Sorry, No Product Found :("),
                          Expanded(
                              child: ListView(
                            children: [
                              for (int i = 0; i < Product.length; i++)
                                Product[i],
                              if (count > 0) sizeheight(105)
                            ],
                          )),
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
                    child: Lottie.asset(
                      "assets/animation/networkError.json",
                    )));
  }
}
