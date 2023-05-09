import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/product_details.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math' as math;

class productbox1 extends StatefulWidget {
  var pdata;
  ValueNotifier notify;
  productbox1({super.key, required this.pdata, required this.notify});

  @override
  State<productbox1> createState() => _productbox1State(pdata: pdata);
}

class _productbox1State extends State<productbox1> {
  var pdata;
  _productbox1State({required this.pdata});

  double saveAmount = 0;
  int savepercentage = 0;
  String name = "";
  double salePrice = 0;
  double price = 0;
  var priceVaritation = "";
  String imageLink =
      "https://chim-chimneyinc.com/wp-content/uploads/2019/12/GettyImages-1128826884.jpg";
  String unit = "";

  loadData() {
    setState(() {
      print(pdata);
      name = pdata["name"];
      price = (pdata["price"] != null)
          ? double.parse(pdata["price"].toString())
          : 0;

      salePrice = (pdata["sale_price"] != null)
          ? double.parse(pdata["sale_price"].toString())
          : price;
      unit = pdata["unit"];
      imageLink = pdata["image"]["thumbnail"];
      if (price != 0) {
        saveAmount = price - salePrice;
        double temp = ((salePrice * 100) / price);
        temp = temp - temp % 1;
        savepercentage = 100 - temp.toInt();
      }

      if (price == 0) {
        priceVaritation = "${pdata["max_price"]} - ₹${pdata["min_price"]}";
      }
    });
  }

  UpdateCart() {
    widget.notify.addListener(() {
      checkInCart();
    });
  }

  int qty = 0;
  int optid = 0;
  checkInCart() async {
    Box box = await Hive.openBox("cart");
    setState(() {
      qty = 0;
    });
    if (box.get(pdata["id"]) != null) {
      productData pd = box.get(pdata["id"]);
      setState(() {
        qty = pd.quantity;
        if (qty > 0) {
          optid = pd.vid;
          price = (pd.price + (pd.save / pd.quantity)).toDouble();
          salePrice = pd.price.toDouble();
          saveAmount = (pd.save / pd.quantity).toDouble();
        } else {
          setState(() {
            qty = 0;
          });
        }
      });
    } else {
      setState(() {
        qty = 0;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    UpdateCart();
    checkInCart();
    print(pdata);
  }

  @override
  Widget build(BuildContext context) {
    String sqty;
    if (qty < 10)
      sqty = "0$qty";
    else
      sqty = qty.toString();
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => productScreen(
                  slug: pdata["slug"],
                  notify: widget.notify,
                ))));
      },
      child: Container(
        margin: EdgeInsets.only(top: density(5), bottom: density(5)),
        height: density(240),
        width: density(160),
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black12, //color of shadow
            spreadRadius: .03, //spread radius
            blurRadius: 7, // blur radius
          )
        ], borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: Stack(
          children: [
            Positioned(
                left: 5,
                right: 5,
                top: 5,
                bottom: 5,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network("$imageLink"))),
            if (savepercentage != 0)
              Positioned(
                top: 8,
                right: 8,
                child: Text(
                  "${savepercentage}% off",
                  style: TextStyle(
                      fontSize: density(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontFamily: "Montserrat"),
                ),
              ),
            Positioned(
                height: 60,
                left: 2,
                right: 2,
                bottom: 5,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sizeheight(density(5)),
                      Text(
                        "$name",
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: density(15),
                            fontFamily: "Poppins"),
                      ),
                      sizeheight(density(5)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            (salePrice != 0)
                                ? '₹$salePrice'
                                : '₹$priceVaritation',
                            softWrap: true,
                            style: TextStyle(
                                fontSize: density(14),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Montserrat"),
                          ),
                          sizewidth(5),
                          if (salePrice != price)
                            Text(
                              "₹${price}",
                              style: TextStyle(
                                  fontSize: density(13),
                                  decoration: TextDecoration.lineThrough,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat"),
                            ),
                          sizewidth(30)
                        ],
                      ),
                      sizeheight(density(5)),
                    ],
                  ),
                )),
            if (false)
              Positioned(
                  top: density(167),
                  left: density(8),
                  bottom: density(8),
                  child: Row(
                    children: [
                      Text(
                        (salePrice != 0) ? '₹$salePrice' : '₹$priceVaritation',
                        softWrap: true,
                        style: TextStyle(
                            fontSize: density(14),
                            fontWeight: FontWeight.w600,
                            fontFamily: "Montserrat"),
                      ),
                      sizewidth(5),
                      if (salePrice != price)
                        Text(
                          "₹${price}",
                          style: TextStyle(
                              fontSize: density(12),
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Montserrat"),
                        )
                    ],
                  )),
            /*  Positioned(
                left: density(129.2),
                top: density(81),
                right: density(7.5),
                child: InkWell(
                  onTap: () {
                    if (price != 0 && qty <= pdata["quantity"]) {
                      setState(() {
                        qty++;
                        addtoCart();
                      });
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) => productScreen(
                                slug: pdata["slug"],
                                notify: widget.notify,
                              ))));
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: primaryColor(),
                    child: (qty > 0)
                        ? Text(
                            sqty,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontFamily: "Montserrat"),
                          )
                        : Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                  ),
                ))*/
          ],
        ),
      ),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
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
