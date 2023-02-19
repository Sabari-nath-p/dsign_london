import 'dart:convert';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dsign_london/Card/similarProduct.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import '../Constant/link.dart';

class productScreen extends StatefulWidget {
  ValueNotifier
      notify; // used to update cart when new product is added to the cart
  String slug;
  productScreen({super.key, required this.slug, required this.notify});

  @override
  State<productScreen> createState() => _productScreenState(slug: slug);
}

class _productScreenState extends State<productScreen> {
  String slug;
  _productScreenState({required this.slug});

  int qty = 0; //varible to controll quantity to be added  to card

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
    BackButtonInterceptor.add(myInterceptor, zIndex: 2, name: "SomeName");
  }

  double saveAmount = 0;
  int savepercentage = 0;
  int inStock = 1;
  String name = "";
  double salePrice = 0;
  double price = 0;
  List imageLink = [];
  String unit = "";
  String description = "";
  String priceVaritation = "";
  String id = "0";
  var pdata = null;
  int optionSelector = -1;

  loadData() async {
    final Response = await http.get(Uri.parse(
        "$baseUrl/products/$slug?language=en&searchJoin=and&with=categories%3Bshop%3Btype%3Bvariations%3Bvariations.attribute.values%3Bmanufacturer%3Bvariation_options%3Btags%3Bauthor"));
    pdata = json.decode(Response.body);

    setState(() {
      name = pdata["name"];
      id = pdata["id"].toString();
      if (pdata["description"] != null) description = pdata["description"];
      price = (pdata["price"] != null)
          ? double.parse(pdata["price"].toString())
          : 0;

      salePrice = (pdata["sale_price"] != null)
          ? double.parse(pdata["sale_price"].toString())
          : price;
      inStock = pdata["quantity"];

      unit = pdata["unit"];
      //imageLink = pdata["image"]["thumbnail"];
      if (pdata["gallery"].isNotEmpty)
        for (var img in pdata["gallery"]) {
          imageLink.add(
            img["original"],
          );
        }
      else if (pdata["image"]["thumbnail"] != null)
        imageLink.add(
          pdata["image"]["original"],
        );
      else
        imageLink.add(
            "https://blog.rahulbhutani.com/wp-content/uploads/2020/05/Screenshot-2018-12-16-at-21.06.29.png");
      if (price != 0) {
        saveAmount = price - salePrice;
        double temp = ((salePrice * 100) / price);
        temp = temp - temp % 1;
        savepercentage = 100 - temp.toInt();
      }

      if (price == 0) {
        priceVaritation = "${pdata["max_price"]} - Rs ${pdata["min_price"]}";
      }

      checkInCart();
      loadCart();
      UpdateCart();
    });
  }

  UpdateCart() {
    widget.notify.addListener(() {
      loadCart();
      checkInCart();
    });
  }

  checkInCart() async {
    Box box = await Hive.openBox("cart");

    if (box.get(pdata["id"]) != null) {
      productData pd = box.get(pdata["id"]);

      setState(() {
        qty = pd.quantity;

        if (pd.vid != 0 && pdata["variation_options"].isNotEmpty && qty > 0) {
          for (int i = 0; i < pdata["variation_options"].length; i++) {
            if (pd.vid == pdata["variation_options"][i]["id"]) {
              optionSelector = i;

              price = double.parse(pdata["variation_options"][i]["price"])
                  .toDouble();

              salePrice = (pdata["variation_options"][i]["sale_price"] != null)
                  ? double.parse(pdata["variation_options"][i]["sale_price"])
                      .toDouble()
                  : price;

              if (pdata["variation_options"][i]["image"] != null)
                imageLink.clear();
              if (pdata["variation_options"][i]["image"] != null)
                imageLink
                    .add(pdata["variation_options"][i]["image"]["thumbnail"]);
            }
          }
        }
      });
    } else {
      setState(() {
        qty = 0;
      });
    }
  }

  int count = 0;
  int total = 0;
  int save = 0;
  @override
  void dispose() {
    BackButtonInterceptor.removeByName("SomeName");
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (isZoom) {
      setState(() {
        isZoom = false;
      });
    } else {
      Navigator.pop(context);
    }

    // Do some stuff.
    return true;
  }

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
        if (pd.quantity > 0) {
          setState(() {
            count++;
            total = total + pd.subTotal;
            save = save + pd.save;
          });
        }
      }
    }
    setState(() {
      loading = 1;
    });
  }

  int loading = 0;
  bool isZoom = false;
  String zoomLink = "";

  @override
  Widget build(BuildContext context) {
    String sqty; // convert quantity count to fromatted String model
    String cqty; // formate string to cart model
    if (qty < 10)
      sqty = "0$qty";
    else
      sqty = qty.toString();
    if (count < 10)
      cqty = "0$count";
    else
      cqty = count.toString();

    return Scaffold(
        body: (loading == 1 && pdata != null)
            ? SafeArea(
                child: Container(
                  width: 390,
                  color: Colors.white24,
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    fit: StackFit.loose,
                    children: [
                      Positioned(
                        width: 390,
                        height: MediaQuery.of(context).size.height,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height: density(370),
                                  ),
                                  Positioned(
                                    left: density(16),
                                    top: density(260),
                                    bottom: density(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: density(320),
                                            child: Text(
                                              '$name',
                                              style: TextStyle(
                                                  fontSize: density(18),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Montserrat",
                                                  fontStyle: FontStyle.normal),
                                            ),
                                          ),
                                        ),
                                        sizeheight(density(7)),
                                        Row(
                                          children: [
                                            Text(
                                              '$unit',
                                              style: TextStyle(
                                                  color: primaryColor(),
                                                  fontSize: density(16),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Montserrat"),
                                            ),
                                            sizewidth(10),
                                            SizedBox(
                                              child: RatingBar.builder(
                                                itemSize: 20,
                                                initialRating: double.parse(
                                                        pdata["ratings"]
                                                            .toString())
                                                    .toDouble(),
                                                minRating: 1,
                                                tapOnlyMode: false,
                                                ignoreGestures: true,
                                                glow: false,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 1.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: primaryColor(),
                                                ),
                                                onRatingUpdate: (rating) {},
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              (salePrice != 0)
                                                  ? 'Rs $salePrice'
                                                  : 'Rs $priceVaritation',
                                              style: TextStyle(
                                                  fontSize: density(20),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: "Montserrat"),
                                            ),
                                            sizewidth(density(8)),
                                            if (price != salePrice)
                                              Text(
                                                'Rs $price',
                                                style: TextStyle(
                                                    fontSize: density(16),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Montserrat",
                                                    decoration: TextDecoration
                                                        .lineThrough),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (inStock < 1 && qty == 0)
                                    Positioned(
                                        right: density(20),
                                        bottom: density(10),
                                        child: Container(
                                          height: density(37),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: density(10)),
                                          decoration: BoxDecoration(
                                              color: primaryColor(),
                                              borderRadius:
                                                  BorderRadius.circular(70)),
                                          child: Text(
                                            "Out of Stock",
                                            style: TextStyle(
                                                fontSize: density(16),
                                                fontFamily: "Montserrat",
                                                color: Colors.white),
                                          ),
                                        )),
                                  if (qty == 0 && inStock > 0)
                                    Positioned(
                                        bottom: density(10),
                                        right: density(20),
                                        child: Container(
                                          width: density(95.26),
                                          height: density(37),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              if (price != 0) {
                                                setState(() {
                                                  qty++;
                                                  addtoCart();
                                                  //loadCart();
                                                });
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "please select option");
                                              }
                                            },
                                            icon: Icon(Icons.add),
                                            label: Text('ADD'),
                                            style: ElevatedButton.styleFrom(
                                                shape: StadiumBorder(),
                                                backgroundColor:
                                                    primaryColor()),
                                          ),
                                        )),
                                  if (imageLink.length > 0)
                                    Positioned(
                                        top: density(28),
                                        left: density(29),
                                        right: density(29),
                                        height: density(225),
                                        child: ImageSlideshow(
                                          indicatorColor: primaryColor(),
                                          isLoop: (imageLink.length > 1),
                                          autoPlayInterval:
                                              (imageLink.length > 1) ? 6000 : 0,
                                          children: [
                                            for (int i = 0;
                                                i < imageLink.length;
                                                i++)
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    zoomLink = imageLink[i];
                                                    isZoom = true;
                                                  });
                                                },
                                                child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    child: Image.network(
                                                        imageLink[i])),
                                              )
                                          ],
                                        )),
                                  if (qty > 0)
                                    Positioned(
                                        right: density(16),
                                        bottom: density(15),
                                        child: Container(
                                          height: density(37),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: density(21)),
                                          decoration: BoxDecoration(
                                              color: primaryColor(),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      density(70))),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    qty--;
                                                    addtoCart();
                                                    //  loadCart();
                                                  });
                                                },
                                                child: Text(
                                                  "-",
                                                  style: TextStyle(
                                                      fontSize: density(30),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              sizewidth(density(21)),
                                              Text(
                                                "$sqty",
                                                style: TextStyle(
                                                    fontSize: density(20),
                                                    fontFamily: "Montserrat",
                                                    color: Colors.white),
                                              ),
                                              sizewidth(density(21)),
                                              InkWell(
                                                onTap: () {
                                                  if (price != 0) {
                                                    setState(() {
                                                      qty++;
                                                      addtoCart();
                                                      //  loadCart();
                                                    });
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "please select size");
                                                  }
                                                },
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                  Positioned(
                                      top: density(40),
                                      left: density(20),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Colors.grey.withOpacity(.2),
                                          child: Icon(
                                            Icons.arrow_back_ios_new,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ))
                                ],
                              ),
                              SizedBox(
                                height: density(10),
                              ),
                              if (pdata["variation_options"].isNotEmpty)
                                Container(
                                  width: density(390),
                                  color: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: density(16),
                                      vertical: density(17)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: density(20),
                                        child: Text(
                                          pdata["variation_options"][0]
                                              ["options"][0]["name"],
                                          style: TextStyle(
                                              fontSize: density(16),
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        height: density(15),
                                      ),
                                      SizedBox(
                                        width: density(350),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              for (int i = 0;
                                                  i <
                                                      pdata["variation_options"]
                                                          .length;
                                                  i++)
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      optionSelector = i;
                                                      optid = pdata[
                                                              "variation_options"]
                                                          [i]["id"];
                                                      price = double.parse(pdata[
                                                                  "variation_options"]
                                                              [i]["price"])
                                                          .toDouble();

                                                      salePrice = (pdata["variation_options"]
                                                                      [i][
                                                                  "sale_price"] !=
                                                              null)
                                                          ? double.parse(pdata[
                                                                      "variation_options"][i]
                                                                  [
                                                                  "sale_price"])
                                                              .toDouble()
                                                          : price;
                                                      if (pdata["variation_options"]
                                                              [i]["image"] !=
                                                          null)
                                                        imageLink.clear();
                                                      if (pdata["variation_options"]
                                                              [i]["image"] !=
                                                          null)
                                                        imageLink.add(
                                                            pdata["variation_options"]
                                                                    [i]["image"]
                                                                ["thumbnail"]);
                                                    });

                                                    addtoCart();
                                                  },
                                                  child: Container(
                                                    height: 30,
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.all(6),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          (i == optionSelector)
                                                              ? primaryColor()
                                                              : null,
                                                      border: Border.all(
                                                          color:
                                                              primaryColor()),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      //shape: BoxShape.circle
                                                    ),
                                                    child: Text(
                                                      pdata["variation_options"]
                                                          [i]["title"],
                                                      style: TextStyle(
                                                          color: (i !=
                                                                  optionSelector)
                                                              ? primaryColor()
                                                              : Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (description != "")
                                SizedBox(
                                  height: density(10),
                                ),
                              if (description != "")
                                Container(
                                  width: density(390),
                                  color: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: density(16),
                                      vertical: density(17)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: density(20),
                                        child: Text(
                                          'Product Details',
                                          style: TextStyle(
                                              fontSize: density(16),
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      SizedBox(
                                        height: density(15),
                                      ),
                                      SizedBox(
                                        width: density(350),
                                        child: Text(
                                          description,
                                          style: TextStyle(
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.w400,
                                              fontSize: density(14),
                                              fontStyle: FontStyle.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              sizeheight(density(10)),
                              if (pdata != null)
                                Container(
                                  color: Colors.white,
                                  height: density(274),
                                  width: density(390),
                                  padding: EdgeInsets.only(
                                      left: density(16), top: density(10)),
                                  child: similarProduct(
                                    data: pdata["related_products"],
                                    notify: widget.notify,
                                    id: id,
                                  ),
                                ),
                              sizeheight(density(20)),
                              if (count != 0) sizeheight(density(130))
                            ],
                          ),
                        ),
                      ),
                      if (count != 0)
                        Positioned(
                            bottom: 0,
                            height: density(100),
                            child: Stack(
                              children: [
                                Container(
                                  width: density(390),
                                  height: density(100),
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
                                    top: density(25),
                                    left: density(28),
                                    bottom: density(40),
                                    child: Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 40,
                                      color: primaryColor(),
                                    )),
                                Positioned(
                                    top: density(26),
                                    left: density(76),
                                    child: Text(
                                      "$cqty items",
                                      style: TextStyle(
                                          fontSize: density(14),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat"),
                                    )),
                                Positioned(
                                    top: density(26),
                                    left: density(151),
                                    child: Text("$total",
                                        style: TextStyle(
                                            fontSize: density(16),
                                            color: primaryColor(),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Montserrat"))),
                                Positioned(
                                    right: density(22),
                                    bottom: density(35),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) => cart(
                                                    notify: widget.notify)));
                                      },
                                      child: Container(
                                        width: density(128),
                                        height: density(42),
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
                                    top: density(50),
                                    left: density(78),
                                    child: Text(
                                      "90 mins",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w200,
                                          fontFamily: "Montserrat"),
                                    )),
                                Positioned(
                                    right: density(173),
                                    bottom: density(28),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: density(74),
                                      height: density(21),
                                      color: Color.fromARGB(100, 243, 210, 102),
                                      child: Text(
                                        "Save $save",
                                        style: TextStyle(color: primaryColor()),
                                      ),
                                    ))
                              ],
                            )),
                      if (isZoom)
                        Positioned(
                            top: 10,
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Container(
                              child: PhotoView(
                                minScale: PhotoViewComputedScale.contained * 1,
                                maxScale: PhotoViewComputedScale.contained * 3,
                                backgroundDecoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.7)),
                                imageProvider: NetworkImage(zoomLink),
                              ),
                            )),
                      if (isZoom)
                        Positioned(
                            top: 10,
                            right: 10,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  isZoom = false;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                            ))
                    ],
                  ),
                ),
              )
            : Container(
                alignment: Alignment.center,
                child: LoadingAnimationWidget.staggeredDotsWave(
                    color: primaryColor(), size: 40),
              ));
  }

  double density(
    double d,
  ) {
    double height = MediaQuery.of(context).size.width;
    double value = d * (height / 390);
    return value;
  }

  int optid = 0;
  addtoCart() async {
    saveAmount = price - salePrice;
    Box box = await Hive.openBox("cart");
    productData pd = productData(
        id: pdata["id"],
        name: name,
        unit: pdata["unit"],
        price: salePrice.toInt(),
        quantity: qty,
        image: imageLink[0],
        slug: pdata["slug"],
        vid: optid,
        subTotal: (salePrice.toInt() * qty),
        save: (saveAmount.toInt() * qty));
    box.put(pdata["id"], pd);
    widget.notify.value++;
  }
}
