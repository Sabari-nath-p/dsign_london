import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/product_details.dart';
import 'package:dsign_london/dataType/productData.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class productBox extends StatefulWidget {
  var pdata; // varible to store product data for previous navigator
  ValueNotifier notify;
  productBox({super.key, required this.pdata, required this.notify});

  @override
  State<productBox> createState() => _productBoxState(pdata: pdata);
}

class _productBoxState extends State<productBox> {
  var pdata;
  _productBoxState({required this.pdata});
  int qty = 0; //varible to controll quantity to be added  to card

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    checkInCart();
    UpdateCart();
  }

  loadData() {
    setState(() {
      name = pdata["name"];
      price = (pdata["price"] != null)
          ? double.parse(pdata["price"].toString())
          : 0;

      salePrice = (pdata["sale_price"] != null)
          ? double.parse(pdata["sale_price"].toString())
          : price;
      unit = pdata["unit"];
      imageLink = (pdata["image"] != null)
          ? pdata["image"]["thumbnail"]
          : "https://blog.rahulbhutani.com/wp-content/uploads/2020/05/Screenshot-2018-12-16-at-21.06.29.png";

      if (price == 0) {
        priceVaritation = "${pdata["max_price"]} - Rs${pdata["min_price"]}";
      }
    });
  }

  String priceVaritation = "";
  UpdateCart() {
    widget.notify.addListener(() {
      checkInCart();
    });
  }

  int optid = 0;
  checkInCart() async {
    Box box = await Hive.openBox("cart");
    if (box.get(pdata["id"]) != null) {
      productData pd = box.get(pdata["id"]);
      setState(() {
        qty = pd.quantity;
        if (qty > 0) {
          optid = pd.vid;
          price = (pd.price + (pd.save / pd.quantity)).toDouble();
          salePrice = pd.price.toDouble();
          saveAmount = (pd.save / pd.quantity).toDouble();
        }
      });
    } else {
      setState(() {
        qty = 0;
      });
    }
  }

  double saveAmount = 0;
  int savepercentage = 0;
  String name = "";
  double salePrice = 0;
  double price = 0;
  String imageLink =
      "https://chim-chimneyinc.com/wp-content/uploads/2019/12/GettyImages-1128826884.jpg";
  String unit = "";

  @override
  Widget build(BuildContext context) {
    if (price != 0) {
      saveAmount = price - salePrice;
      double temp = ((salePrice * 100) / price);
      temp = temp - temp % 1;
      savepercentage = 100 - temp.toInt();
    }
    String sqty; // convert quantity count to fromatted String model
    if (qty < 10)
      sqty = "0$qty";
    else
      sqty = qty.toString();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => productScreen(
                  slug: pdata["slug"],
                  notify: widget.notify,
                )));
      },
      child: Container(
        width: 390,
        height: 146,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Color(0XFFCDCDCD9E))),
            color: Colors.white),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Positioned(
                top: density(23),
                left: density(10),
                right: density(245),
                bottom: density(16),
                child: Image.network(
                  "$imageLink",
                  fit: BoxFit.fill,
                )),
            if (salePrice != price)
              Positioned(
                  top: density(8),
                  left: density(16.5),
                  width: density(38),
                  height: density(40),
                  child: Image.asset(
                    "assets/image/discountbadge.png",
                    fit: BoxFit.fill,
                  )),
            if (salePrice != price)
              Positioned(
                top: density(16),
                left: density(18),
                right: density(335),
                child: Text(
                  "${savepercentage}% \noff",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: density(10),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat",
                      color: Colors.white),
                ),
              ),
            Positioned(
                left: density(155),
                right: density(15),
                top: density(16),
                bottom: density(80),
                child: Text(
                  "$name",
                  style: TextStyle(
                      fontSize: density(14),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Montserrat"),
                )),
            Positioned(
                left: density(155),
                right: density(80),
                // top: 96,
                bottom: density(60),
                child: Text(
                  (price != 0) ? "Rs $salePrice" : "Rs $priceVaritation",
                  style: TextStyle(
                      fontSize: density(16),
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Montserrat"),
                )),
            if (salePrice != price)
              Positioned(
                  left: density(232),
                  right: density(70),
                  //top: 96,
                  bottom: density(63),
                  child: Text(
                    (price != 0) ? "Rs $price" : priceVaritation,
                    style: TextStyle(
                        fontSize: density(14),
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w300,
                        fontFamily: "Montserrat"),
                  )),
            if (salePrice != price)
              Positioned(
                  left: density(155),
                  right: density(145),
                  // top: 96,
                  bottom: density(40),
                  child: Text(
                    "Save Rs $saveAmount",
                    style: TextStyle(
                        fontSize: density(12),
                        fontWeight: FontWeight.w500,
                        color: primaryColor(),
                        fontFamily: "Montserrat"),
                  )),
            Positioned(
                left: density(155),
                right: density(145),
                // top: 96,
                bottom: density(8),
                child: Text(
                  "$unit",
                  style: TextStyle(
                      fontSize: density(18),
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat"),
                )),
            if (pdata["quantity"] < 1 && qty == 0)
              Positioned(
                  right: density(16),
                  bottom: density(10),
                  child: Container(
                    height: density(37),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: density(10)),
                    decoration: BoxDecoration(
                        color: primaryColor(),
                        borderRadius: BorderRadius.circular(70)),
                    child: Text(
                      "Out of Stock",
                      style: TextStyle(
                          fontSize: density(16),
                          fontFamily: "Montserrat",
                          color: Colors.white),
                    ),
                  )),
            if (qty == 0 && pdata["quantity"] > 0)
              Positioned(
                  right: density(16),
                  bottom: density(10),
                  child: InkWell(
                    onTap: () {
                      if (price != 0) {
                        setState(() {
                          qty++;
                          addtoCart();
                        });
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => productScreen(
                                  slug: pdata["slug"],
                                  notify: widget.notify,
                                )));
                      }
                    },
                    child: Container(
                      height: density(37),
                      decoration: BoxDecoration(
                          color: primaryColor(),
                          borderRadius: BorderRadius.circular(70)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          sizewidth(density(10)),
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          sizewidth(density(4)),
                          Text(
                            "Add ",
                            style: TextStyle(
                                fontSize: density(16),
                                fontFamily: "Montserrat",
                                color: Colors.white),
                          ),
                          sizewidth(density(15))
                        ],
                      ),
                    ),
                  )),
            if (qty != 0)
              Positioned(
                  right: density(16),
                  bottom: density(15),
                  child: Container(
                    height: density(37),
                    padding: EdgeInsets.symmetric(horizontal: density(21)),
                    decoration: BoxDecoration(
                        color: primaryColor(),
                        borderRadius: BorderRadius.circular(density(70))),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              qty--;
                              addtoCart();
                            });
                          },
                          child: Text(
                            "-",
                            style: TextStyle(
                                fontSize: density(30),
                                fontWeight: FontWeight.w700,
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
                            setState(() {
                              qty++;
                              addtoCart();
                            });
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ))
          ],
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

  addtoCart() async {
    Box box = await Hive.openBox("cart");

    productData pd = productData(
        id: pdata["id"],
        name: name,
        price: salePrice.toInt(),
        quantity: qty,
        slug: pdata["slug"],
        image: imageLink,
        vid: optid,
        unit: pdata["unit"],
        subTotal: (salePrice.toInt() * qty),
        save: (saveAmount.toInt() * qty));
    box.put(pdata["id"], pd);
    widget.notify.value++;
  }
}
