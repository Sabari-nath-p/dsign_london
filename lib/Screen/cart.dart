import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:dsign_london/Card/cartProduct.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Constant/locationBottom.dart';
import 'package:dsign_london/Converter/placeOrder.dart';
import 'package:dsign_london/Converter/verify.dart';
import 'package:dsign_london/Screen/coupon.dart';
import 'package:dsign_london/Screen/login.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/link.dart';
import '../Constant/timeFinder.dart';

addressData? ad = null;
List couponData = ["0", 0];

ValueNotifier checknotify = ValueNotifier(0);

class cart extends StatefulWidget {
  ValueNotifier notify;
  bool isHome;
  cart({super.key, required this.notify, this.isHome = false});

  @override
  State<cart> createState() => _cartState();
}

class _cartState extends State<cart> {
  List orderOption = [];
  List paymentMethod = [
    ["Online payment", "RAZOR_PAY"],
    ["Cash On Delivery", "CASH_ON_DELIVERY"]
  ];
  int paymentMethodSelector = 0;
  int orderOptionSelector = 0;
  int itemTotal = 0;
  int total = 0;
  int totalTax = 0;
  int deliveryCharge = 0;
  int walletPoint = 0;
  List<productData> pdata = [];
  bool addWalletAmount = false;
  List<addressData> addressList = [];
  String log = "OUT";
  int selectedAddress = 0;
  int awalletPoint = 0;
  String token = "0";
  int currencyRatio = 1;
  bool checkoutController = false;
  ValueNotifier<int> addressNotify = ValueNotifier<int>(0);
  String language = "en";
  String phone = "0";
  String name = "";
  String email = "";

  bool Loading = false;
  notify() {
    addressNotify.addListener(() {
      loadUser();
      Address();
      // Address();
    });

    checknotify.addListener(() {
      checkout();
    });
  }

  loadSetting() async {
    final Response = await http.get(Uri.parse("$baseUrl/settings"));

    if (Response.statusCode == 200) {
      var setting = json.decode(Response.body);
      if (setting["currencyToWalletRatio"] > 1) {
        setState(() {
          currencyRatio = setting["currencyToWalletRatio"];
          language = setting["language"];
        });
      }
    }
  }

  loadDeliveryTime() async {
    final Response =
        await http.get(Uri.parse("$baseUrl/shippings?language=en"));
    if (Response.statusCode == 200) {
      var js = json.decode(Response.body);
      for (var time in js) {
        bool isActive = false;
        bool visible = true;

        if (time["description"] == "Standard Delivery" ||
            time["description"] == "Standard-Delivery")
          isActive = timeFinder(time["time_slot_to"]);
        else {
          isActive = timeFinder("08:00 PM");
          visible = isActive;
        }

        setState(() {
          orderOption.add([
            time["name"],
            time["amount"],
            time["time_slot_from"],
            time["time_slot_to"],
            time["id"],
            isActive,
            visible
          ]);
        });
      }
      //deliveryCharge = orderOption[0][1];
      checkout();
    }
  }

  updateWallet() async {
    Box box = await Hive.openBox("user");
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString("TOKEN").toString();

    final response = await http.get(Uri.parse("$baseUrl/me"),
        headers: ({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }));
    userData u = box.get(1);
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
      String ppUrl =
          "https://www.oseyo.co.uk/wp-content/uploads/2020/05/empty-profile-picture-png-2.png";

      if (js["profile"]["avatar"] != null)
        ppUrl = js["profile"]["avatar"]["thumbnail"];

      userData udata = new userData(
          name: js["name"],
          email: js["email"],
          id: js['id'],
          phone: u.phone,
          address: adata,
          profileUrl: ppUrl,
          availablePoint: js["wallet"]["available_points"]);

      box.put(1, udata);

      loadUser();
      setState(() {});
    }
  }

  checkout() async {
    late BillingAddress billingAddress;
    if (addressList.isNotEmpty)
      billingAddress = BillingAddress(
          country: addressList[selectedAddress].country,
          city: addressList[selectedAddress].city,
          zip: addressList[selectedAddress].zip,
          state: addressList[selectedAddress].state);

    List<Products> prd = [];
    for (int i = 0; i < pdata.length; i++) {
      Products pd = Products(
          orderQuantity: pdata[i].quantity,
          productId: pdata[i].id.toString(),
          unitPrice: pdata[i].price,
          subtotal: pdata[i].subTotal,
          variationOptionId: (pdata[i].vid != 0) ? pdata[i].vid : 0);
      prd.add(pd);
    }

    checkoutVerify checkoutverify = (addressList.length == 0)
        ? checkoutVerify(
            shippingClassId: orderOption[orderOptionSelector][4],
            amount: itemTotal,
            products: prd,
          )
        : checkoutVerify(
            shippingClassId: orderOption[orderOptionSelector][4],
            amount: itemTotal,
            products: prd,
            billingAddress: billingAddress,
            shippingAddress: billingAddress,
          );

    var headers = {
      'Accept': 'application/json',
      'Content-Type': "application/json"
    };
    var request =
        http.Request('POST', Uri.parse('$baseUrl/orders/checkout/verify/'));
    request.headers.addAll(headers);
    request.body = checkoutverify.toJson().toString();

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      var checkOutdata = json.decode(result);

      setState(() {
        totalTax = checkOutdata["total_tax"];
        deliveryCharge = checkOutdata["shipping_charge"];
      });
      if (checkOutdata["unavailable_products"].length > 0) {
        Box product = await Hive.openBox("cart");

        Fluttertoast.showToast(
            msg:
                "${checkOutdata["unavailable_products"].length} product is unavailable due to out of stock");
        setState(() {
          for (var unproduct in checkOutdata["unavailable_products"]) {
            productData pd = product.get(int.parse(unproduct));
            pd.quantity = 0;
            product.put(pd.id, pd);
            for (int i = 0; i < pdata.length; i++) {
              if (pdata[i].id.toString() == unproduct) {
                pdata[i].quantity = 0;
                widget.notify.value++;
              }
            }
          }
        });
      }
    }
  }

  loadUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    token = pref.get("TOKEN").toString();
    log = pref.get("LOGIN").toString();
    Box db = await Hive.openBox("user");
    addressList.clear();
    if (db.isNotEmpty) {
      userData udata = db.get(1);
      walletPoint = udata.availablePoint;
      awalletPoint = walletPoint;
      phone = udata.phone;
      email = udata.email;
      name = udata.name;

      for (var ad in udata.address) {
        setState(() {
          addressList.add(ad);
        });
      }
    }
  }

  loadCart() async {
    Box box = await Hive.openBox("cart");

    itemTotal = 0;

    setState(() {
      for (var p in box.keys) {
        productData pd = box.get(p);
        if (pd.quantity > 0) {
          pdata.add(pd);
          itemTotal = itemTotal + pd.subTotal;
        }
      }
    });
  }

  UpdateCart() {
    widget.notify.addListener(() async {
      updateAmount();
    });
  }

  updateAmount() async {
    Box box = await Hive.openBox("cart");

    itemTotal = 0;

    setState(() {
      for (var p in box.keys) {
        productData pd = box.get(p);
        if (pd.quantity > 0) {
          // pdata.add(pd);
          itemTotal = itemTotal + pd.subTotal;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    couponData = [];
    loadCart();
    UpdateCart();
    loadDeliveryTime();
    loadUser();
    notify();
    updateWallet();
  }

  int subtotal = 0;
  @override
  Widget build(BuildContext context) {
    walletPoint = awalletPoint;

    int walletCurrency = (walletPoint / currencyRatio).toInt();
    subtotal = itemTotal + deliveryCharge + totalTax;
    if (couponData.length > 0) {
      if (subtotal > int.parse(couponData[1]))
        subtotal = subtotal - int.parse(couponData[1]);
      else {
        subtotal = 0;
      }
    }

    if (addWalletAmount) {
      total = subtotal - walletCurrency;
      if (walletCurrency > subtotal) {
        total = 0;
        walletCurrency = walletCurrency - subtotal;
        walletPoint = walletCurrency * currencyRatio;
      } else {
        walletPoint = 0;
        walletCurrency = 0;
      }
    } else
      total = subtotal;

    if (itemTotal == 0) {
      deliveryCharge = 0;
      total = 0;
      subtotal = 0;
      totalTax = 0;
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: (itemTotal != 0) ? Colors.white24 : Colors.white,
          child: Column(
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
                    if (Navigator.canPop(context))
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                            radius: density(20),
                            backgroundColor: Color.fromARGB(223, 240, 240, 235)
                                .withOpacity(0.2),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            )),
                      ),
                    sizewidth(density(28)),
                    Text(
                      "My Cart",
                      style: TextStyle(
                          fontSize: density(20),
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
                      if (itemTotal != 0)
                        for (int i = 0; i < pdata.length; i++)
                          cartProduct(
                            pdata: pdata[i],
                            notify: widget.notify,
                          ),
                      if (itemTotal == 0)
                        Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                if (itemTotal == 0)
                                  SizedBox(
                                    height: density(250),
                                  ),
                                Container(
                                    color: null,
                                    alignment: Alignment.center,
                                    height: 100,
                                    child: Image.asset(
                                        "assets/image/cartEmpty.png")),
                                Text("Cart is Empty",
                                    style: TextStyle(
                                        fontFamily: "Monsterrat",
                                        fontWeight: FontWeight.w600)),
                                sizeheight(10)
                              ],
                            )),
                      sizeheight(density(6)),
                      /*coupon  */ if (!widget.isHome)
                        Container(
                          width: density(390),
                          height: density(66),
                          color: Colors.white,
                          child: Row(
                            children: [
                              sizewidth(density(16)),
                              Container(
                                  width: density(30),
                                  height: density(30),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/image/discountbadge.png"))),
                                  child: Text(
                                    "%",
                                    style: TextStyle(
                                        fontSize: density(16),
                                        fontFamily: "Montserrat",
                                        color: Colors.white),
                                  )),
                              sizewidth(density(19)),
                              if (couponData.isEmpty)
                                Expanded(
                                  child: Text(
                                    "Apply Offers / Coupon",
                                    style: TextStyle(
                                      fontSize: density(16),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Montserrat",
                                    ),
                                  ),
                                ),
                              if (!couponData.isEmpty)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        couponData[0],
                                        style: TextStyle(
                                          fontSize: density(16),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat",
                                        ),
                                      ),
                                      sizeheight(5),
                                      Row(
                                        children: [
                                          Text(
                                            "₹${couponData[1]}",
                                            style: TextStyle(
                                              fontSize: density(12),
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                          sizewidth(2),
                                          Text(
                                            "Coupon saving",
                                            style: TextStyle(
                                              fontSize: density(12),
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              if (!couponData.isEmpty)
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        couponData.clear();
                                      });
                                    },
                                    child: Icon(Icons.close)),
                              if (couponData.isEmpty)
                                InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (ctx) => coupon(
                                                    notify: widget.notify,
                                                  )));
                                    },
                                    child: Icon(Icons.arrow_forward_ios)),
                              sizewidth(density(20))
                            ],
                          ),
                        ),
                      sizeheight(density(5)),
                      /*payment details */ if (itemTotal != 0)
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
                                  "Item Total", "₹$itemTotal", Colors.black),
                              paymentBox("Partner Delivery charge",
                                  "₹$deliveryCharge", Colors.greenAccent),
                              paymentBox(
                                  "Coupon Discount",
                                  (couponData.length > 0)
                                      ? "₹${couponData[1]}"
                                      : "₹0",
                                  Colors.redAccent),
                              paymentBox(
                                  "Subtotal", "₹${subtotal}", Colors.black),
                              SizedBox()
                            ],
                          ),
                        ),
                      sizeheight(density(4)),
                      /*wallet */ if (!widget.isHome)
                        Container(
                          color: Colors.white,
                          width: density(390),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sizeheight(density(12)),
                              Text(
                                "    Wallet",
                                style: TextStyle(
                                  fontSize: density(18),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat",
                                ),
                              ),
                              sizeheight(density(10)),
                              Container(
                                width: density(390),
                                height: density(45),
                                padding: EdgeInsets.only(
                                    left: density(19), right: density(16)),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.withOpacity(.35),
                                            width: 0.4))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "Wallet Points ",
                                      style: TextStyle(
                                        fontSize: density(16),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                      ),
                                    )),
                                    SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Image.asset(
                                            "assets/icons/coin.png")),
                                    sizewidth(3),
                                    Text(
                                      "$walletPoint",
                                      style: TextStyle(
                                        fontSize: density(16),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: density(390),
                                height: density(45),
                                padding: EdgeInsets.only(
                                    left: density(19), right: density(16)),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.withOpacity(.35),
                                            width: 0.4))),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "Wallet Currency  ",
                                      style: TextStyle(
                                        fontSize: density(16),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                      ),
                                    )),
                                    Text(
                                      "₹$walletCurrency",
                                      style: TextStyle(
                                        fontSize: density(16),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: density(390),
                                height: density(45),
                                padding: EdgeInsets.only(
                                    left: density(5), right: density(16)),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.withOpacity(.35),
                                            width: 0.4))),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      activeColor: primaryColor(),
                                      value: addWalletAmount,
                                      onChanged: ((value) {
                                        setState(() {
                                          if (addWalletAmount)
                                            addWalletAmount = false;
                                          else if (walletPoint != 0) {
                                            addWalletAmount = true;
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "no Wallet Point available ");
                                          }
                                        });
                                      }),
                                    ),
                                    Text(
                                      "Do you want use wallet",
                                      style: TextStyle(
                                        fontSize: density(14),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Montserrat",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: density(390),
                                  height: density(45),
                                  padding: EdgeInsets.only(
                                      left: density(19), right: density(16)),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color:
                                                  Colors.grey.withOpacity(.35),
                                              width: 0.4))),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        "Total",
                                        style: TextStyle(
                                          fontSize: density(18),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat",
                                        ),
                                      )),
                                      Text(
                                        "₹${total}",
                                        style: TextStyle(
                                          fontSize: density(18),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Montserrat",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      sizeheight(density(6)),
                      /*address details */ if (addressList.length == 0 &&
                          !widget.isHome)
                        Container(
                          width: density(390),
                          color: Colors.white,
                          constraints: BoxConstraints(minHeight: 60),
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              sizewidth(density(21)),
                              Icon(
                                Icons.location_on_outlined,
                                color: primaryColor(),
                              ),
                              sizewidth(density(10)),
                              Expanded(
                                child: Text(
                                  "Enter your Address",
                                  style: TextStyle(
                                    fontSize: density(16),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Montserrat",
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (log == "IN")
                                    Address();
                                  else {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: ((context) => login())));
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 2),
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                      color: Color(0XFFEAFFF5),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Text("Add"),
                                ),
                              ),
                              sizewidth(16),
                            ],
                          ),
                        ),
                      if (addressList.length > 0 && !widget.isHome)
                        /*address details */ Container(
                          width: density(390),
                          color: Colors.white,
                          constraints: BoxConstraints(minHeight: density(60)),
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  sizewidth(density(21)),
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: primaryColor(),
                                  ),
                                  sizewidth(density(10)),
                                  Expanded(
                                    child: Text(
                                      addressList[selectedAddress].title,
                                      style: TextStyle(
                                        fontSize: density(16),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat",
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Address();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 2),
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Color(0XFFEAFFF5),
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Text("Edit"),
                                    ),
                                  ),
                                  sizewidth(16),
                                ],
                              ),
                              Text(
                                "         ${addressList[selectedAddress].address}",
                                style: TextStyle(
                                  fontSize: density(13),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat",
                                ),
                              )
                            ],
                          ),
                        ),
                      /*delivery option */ if (!widget.isHome)
                        Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                sizewidth(density(20)),
                                for (int i = 0; i < orderOption.length; i++)
                                  if (orderOption[i][6])
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          checkout();

                                          orderOptionSelector = i;
                                          //  deliveryCharge = orderOption[i][1];
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: density(66),
                                        margin: EdgeInsets.only(
                                            right: density(10),
                                            bottom: density(10)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: density(6)),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color:
                                                    (orderOptionSelector == i)
                                                        ? primaryColor()
                                                        : Colors.grey),
                                            borderRadius: BorderRadius.circular(
                                                density(7))),
                                        child: Stack(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  orderOption[i][0],
                                                  style: TextStyle(
                                                    fontSize: density(15),
                                                    color:
                                                        (orderOptionSelector ==
                                                                i)
                                                            ? primaryColor()
                                                            : Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: "Montserrat",
                                                  ),
                                                ),
                                                sizeheight(density(5)),
                                                Text(
                                                  (orderOption[i][2] != null)
                                                      ? "${orderOption[i][2]}-${orderOption[i][3]}"
                                                      : "90min Delivery",
                                                  style: TextStyle(
                                                    fontSize: density(13),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Montserrat",
                                                  ),
                                                )
                                              ],
                                            ),
                                            if (!orderOption[i][5] &&
                                                orderOption[i][2] != null)
                                              Positioned(
                                                top: 5,
                                                right: density(2),
                                                child: Text(
                                                  "Next Day",
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    )
                              ],
                            ),
                          ),
                        ),
                      sizeheight(6),
                      if (total != 0) /*payment details */
                        if (!widget.isHome)
                          Container(
                            color: Colors.white,
                            width: density(390),
                            padding: EdgeInsets.only(
                                left: density(20), top: density(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Payment Methode",
                                  style: TextStyle(
                                    fontSize: density(16),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Montserrat",
                                  ),
                                ),
                                sizeheight(density(19)),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(children: [
                                    for (int i = 0;
                                        i < paymentMethod.length;
                                        i++)
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            paymentMethodSelector = i;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: density(20),
                                              bottom: density(10)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: density(18),
                                              vertical: density(16)),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(density(5)),
                                              border: Border.all(
                                                  color:
                                                      (paymentMethodSelector ==
                                                              i)
                                                          ? primaryColor()
                                                          : Colors
                                                              .grey
                                                              .withOpacity(
                                                                  0.4))),
                                          child: Text(
                                            paymentMethod[i][0],
                                            style: TextStyle(
                                              fontSize: density(14),
                                              color:
                                                  (paymentMethodSelector == i)
                                                      ? primaryColor()
                                                      : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: "Montserrat",
                                            ),
                                          ),
                                        ),
                                      )
                                  ]),
                                )
                              ],
                            ),
                          ),
                      sizeheight(density(6)),

                      //loadCart
                      if (widget.isHome && itemTotal != 0)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) => cart(
                                      notify: widget.notify,
                                    ))));
                          },
                          child: Container(
                              color: Colors.white,
                              child: Container(
                                width: double.infinity,
                                height: density(52),
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(density(20)),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(density(77)),
                                    color: primaryColor()),
                                child: Text(
                                  "Purchase",
                                  style: TextStyle(
                                    fontSize: density(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                  ),
                                ),
                              )),
                        ),
                      //payment button
                      if (!widget.isHome)
                        if (!Loading)
                          InkWell(
                            onTap: () async {
                              if (log == "IN") {
                                if (addressList.isNotEmpty && itemTotal != 0) {
                                  setState(() {
                                    Loading = true;
                                  });
                                  ({});
                                  place();
                                } else if (itemTotal == 0) {
                                  Fluttertoast.showToast(msg: "Cart is Empty");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please add address to continue");
                                  Address();
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please login to place order");
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: ((context) => login())));
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              child: Container(
                                width: double.infinity,
                                height: density(52),
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(density(20)),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(density(77)),
                                    color: primaryColor()),
                                child: Text(
                                  (total > 0 && paymentMethodSelector == 0)
                                      ? "Pay ₹${total}"
                                      : "Place Order",
                                  style: TextStyle(
                                    fontSize: density(16),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                  ),
                                ),
                              ),
                            ),
                          ),
                      if (Loading)
                        Container(
                          color: Colors.white,
                          child: Container(
                              width: double.infinity,
                              height: density(52),
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(density(20)),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(density(77)),
                                  color: primaryColor()),
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.white,
                                size: 30,
                              )),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  paymentBox(String data1, String data2, Color color) {
    return Container(
      width: density(390),
      height: density(45),
      padding: EdgeInsets.only(left: density(19), right: density(16)),
      decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(color: Colors.grey.withOpacity(.35), width: 0.4))),
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

  Address() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (buiilder) {
          return Container(
            //padding: EdgeInsets.all(10),
            constraints: BoxConstraints(
                minHeight: density(205), maxHeight: density(400)),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(density(20)),
                    topRight: Radius.circular(density(20)))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  sizeheight(density(15)),
                  Row(
                    children: [
                      sizewidth(density(10)),
                      SizedBox(
                          height: density(50),
                          width: density(40),
                          child: Image.asset("assets/image/mapIcon.JPG")),
                      sizewidth(density(15)),
                      Expanded(
                        child: Text("Select Address",
                            style: TextStyle(
                                fontSize: density(18),
                                fontWeight: FontWeight.bold)),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close)),
                      sizewidth(20)
                    ],
                  ),
                  sizeheight(25),
                  for (int i = 0; i < addressList.length; i++)
                    Row(
                      children: [
                        Radio(
                          value: i,
                          toggleable: true,
                          groupValue: selectedAddress,
                          activeColor: primaryColor(),
                          onChanged: (value) async {
                            setState(() {
                              selectedAddress = int.parse(value.toString());
                            });
                            Navigator.of(context).pop();
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            pref.setInt("selectedAddress", selectedAddress);
                          },
                        ),
                        Text(
                          addressList[i].address,
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black38.withOpacity(0.4),
                  ),
                  sizeheight(25),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      setAdress(buiilder, addressNotify);

                      //Navigator.of(context).push(MaterialPageRoute(
                      // builder: (context) => locationPicker()));
                    },
                    child: Row(
                      children: [
                        sizewidth(density(13)),
                        Icon(
                          Icons.add,
                          color: primaryColor(),
                        ),
                        sizewidth(density(8)),
                        Text("Add Address",
                            style: TextStyle(
                                color: primaryColor(),
                                fontSize: density(18),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  sizeheight(density(20))
                ],
              ),
            ),
          );
        });
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }

  placeOrder porder = placeOrder();
  void place() async {
    placingAddress billingAddress = placingAddress(
      city: addressList[selectedAddress].city,
      country: addressList[selectedAddress].country,
      state: addressList[selectedAddress].state,
      zip: addressList[selectedAddress].zip,
      streetAddress: addressList[selectedAddress].address,
    );
    List<placingproduct> prd = [];
    for (int i = 0; i < pdata.length; i++) {
      if (pdata[i].quantity > 0) {
        placingproduct pd = placingproduct(
            orderQuantity: pdata[i].quantity,
            productId: pdata[i].id,
            unitPrice: pdata[i].price,
            subtotal: pdata[i].subTotal,
            variationOptionId: (pdata[i].vid != 0) ? pdata[i].vid : 0);

        prd.add(pd);
      }
    }

    porder.status = 1;
    porder.discount = 0;
    if (couponData.length > 0) {
      porder.couponId = couponData[0];
      porder.discount = int.parse(couponData[1]);
    }
    porder.amount = itemTotal;
    porder.total = itemTotal + deliveryCharge + totalTax - porder.discount!;
    porder.paidTotal = total; // total - wallet point

    porder.salesTax = totalTax;
    porder.deliveryFee = deliveryCharge;
    porder.billingAddress = billingAddress;
    porder.shippingAddress = billingAddress;
    porder.products = prd;
    if (orderOption[orderOptionSelector][2] != null)
      porder.deliveryTime = orderOption[orderOptionSelector][2];
    else
      porder.deliveryTime = "Express delivery";
    porder.useWalletPoints = addWalletAmount;

    porder.paymentGateway = paymentMethod[paymentMethodSelector][1];
    porder.language = language;
    porder.customerContact = phone;

    if (paymentMethodSelector == 0 && total != 0) {
      final Response =
          await http.post(Uri.parse('$baseUrl/api/orders/razor-pay/generate'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'content-type': 'application/json; charset=utf-8',
                "content-type": "application/json"
              },
              body: json.encode(porder.toJson()));

      if (Response.statusCode == 200 || Response.statusCode == 201) {
        var generatedId = json.decode(Response.body);

        if (generatedId["status"] == "SUCCESS") {
          porder.orderId = generatedId["payment_gateway_order_id"].toString();
          loadOnlinePayment(porder);
        }
      } else {
        setState(() {
          Loading = false;
        });
        var temp = json.decode(Response.body);
        if (temp["coupon_id"] != null) {
          porder.couponId = null;
          porder.discount = 0;
          Fluttertoast.showToast(msg: "coupon code is not applicable");
          setState(() {
            couponData.clear();
          });
        } else {
          setState(() {
            Loading = false;
          });
          Fluttertoast.showToast(msg: "Something went wrong please try again ");
        }
      }
    } else {
      loadCashOndelivery();
    }
  }

  loadCashOndelivery() async {
    final Response = await http.post(Uri.parse("$baseUrl/orders/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': "application/json"
        },
        body: json.encode(porder.toJson()));

    if (Response.statusCode == 200 || Response.statusCode == 201) {
      var temp = json.decode(Response.body);
      if (temp["tracking_number"] != null) {
        Box box = await Hive.openBox("cart");
        for (var p in box.keys) {
          productData pd = box.get(p);
          pd.quantity = 0;
          box.put(p, pd);
          widget.notify.value++;
        }
        box.deleteFromDisk();
        widget.notify.value++;
        Navigator.pop(context);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnText: "Done",
          confirmBtnColor: Colors.green,
          text:
              'Your items has been placed and is on it’s way to being processed',
        );
      } else if (temp["coupon_id"] != null) {
        porder.couponId = null;
        setState(() {
          Loading = false;
        });
        porder.discount = 0;
        Fluttertoast.showToast(msg: "coupon code is not applicable");
        setState(() {
          couponData.clear();
        });
      } else {
        setState(() {
          Loading = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong please try aganin ");
      }
    } else {
      var temp = json.decode(Response.body);
      setState(() {
        Loading = false;
      });
      if (temp["coupon_id"] != null) {
        porder.couponId = null;
        porder.discount = 0;
        Fluttertoast.showToast(msg: "coupon code is not applicable");
        setState(() {
          couponData.clear();
        });
      } else {
        setState(() {
          Loading = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong please try aganin ");
      }
    }
  }

  loadOnlinePayment(placeOrder porder) {
    Razorpay onlinePay = Razorpay();
    onlinePay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    onlinePay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    onlinePay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': 'rzp_live_INUhPIEH4RpCRx',
      'name': name.toString(),
      'order_id': porder.orderId.toString(),
      'amount': porder.amount! * 100,
      'prefill': {'contact': phone.toString(), 'email': email.toString()}
    };
    onlinePay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds

    porder.paymentId = response.paymentId;
    porder.signature = response.signature.toString();
    verifyRazorpay();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      Loading = false;
    });
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  verifyRazorpay() async {
    final response =
        await http.post(Uri.parse("$baseUrl/api/orders/razor-pay/verify"),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
              'content-type': 'application/json; charset=utf-8',
              "content-type": "application/json"
            },
            body: json.encode(porder.toJson()));

    if (response.statusCode == 200 || response.statusCode == 201) {
      var temp = json.decode(response.body);
      if (temp["tracking_number"] != null) {
        Box box = await Hive.openBox("cart");
        for (var p in box.keys) {
          productData pd = box.get(p);
          pd.quantity = 0;
          box.put(p, pd);
          widget.notify.value++;
        }
        box.deleteFromDisk();
        widget.notify.value++;
        Navigator.pop(context);
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          confirmBtnText: "Done",
          confirmBtnColor: Colors.green,
          text:
              'Your items has been placed and is on it’s way to being processed',
        );
      } else if (temp["coupon_id"] != null) {
        porder.couponId = null;
        porder.discount = 0;
        setState(() {
          Loading = false;
        });
        Fluttertoast.showToast(msg: "coupon code is not applicable");
        setState(() {
          couponData.clear();
        });
      } else {
        setState(() {
          Loading = false;
        });
        Fluttertoast.showToast(msg: "please try again ");
      }
    } else {
      setState(() {
        Loading = false;
      });
      var temp = json.decode(response.body);
      if (temp["coupon_id"] != null) {
        porder.couponId = null;
        porder.discount = 0;
        Fluttertoast.showToast(msg: "invalid coupon is not applicable");
        setState(() {
          couponData.clear();
        });
      } else {
        setState(() {
          Loading = false;
        });
        Fluttertoast.showToast(msg: "Something went wrong please try again ");
      }
    }
  }
}
