import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Screen/product_details.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_flutter/hive_flutter.dart';

class similarBox extends StatefulWidget {
  var pdata;
  ValueNotifier notify;
  similarBox({super.key, required this.pdata, required this.notify});

  @override
  State<similarBox> createState() =>
      _similarBoxState(pdata: pdata, notify: notify);
}

class _similarBoxState extends State<similarBox> {
  var pdata;
  ValueNotifier notify;
  _similarBoxState({required this.pdata, required this.notify});

  double saveAmount = 0;
  int savepercentage = 0;
  String name = "";
  double salePrice = 0;
  String priceVaritation = "";
  double price = 0;
  String imageLink =
      "https://chim-chimneyinc.com/wp-content/uploads/2019/12/GettyImages-1128826884.jpg";
  String unit = "";

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
    UpdateCart();
    checkInCart();
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
        height: density(210),
        width: density(166),
        margin: EdgeInsets.only(
            right: density(20),
            top: density(2),
            bottom: density(2),
            left: density(2)),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              spreadRadius: .03,
              offset: Offset(0, 2))
        ]),
        child: Stack(children: [
          Container(
            height: density(115),
            width: density(150),
            margin: EdgeInsets.all(density(8)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
            ),
            child: Image.network(pdata["image"]["thumbnail"]),
          ),
          Positioned(
            bottom: density(10),
            left: density(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: density(17),
                  width: density(155),
                  child: Text(
                    pdata["name"],
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: "Montserrat"),
                  ),
                ),
                SizedBox(
                  height: density(7),
                ),
                SizedBox(
                    height: density(17),
                    child: Text(
                      pdata["unit"],
                      style: TextStyle(
                          fontFamily: "Montserrat", fontSize: density(14)),
                    ))
              ],
            ),
          ),
          Positioned(
              right: density(9),
              top: density(113),
              left: density(120),
              child: Column(
                children: [
                  SizedBox(
                      height: density(37),
                      width: density(37),
                      child: InkWell(
                        onTap: () {
                          if (price != 0) {
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
                                      fontSize: density(12),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontFamily: "Montserrat"),
                                )
                              : Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                        ),
                      )),
                ],
              )),
          Positioned(
              right: density(8),
              bottom: density(9),
              child: Column(
                children: [
                  Text(
                    (salePrice != 0) ? '₹$salePrice' : '₹$priceVaritation',
                    softWrap: true,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontFamily: "Montserrat"),
                  )
                ],
              ))
        ]),
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
        vid: optid,
        image: imageLink,
        unit: pdata["unit"],
        subTotal: (salePrice.toInt() * qty),
        save: (saveAmount.toInt() * qty));
    box.put(pdata["id"], pd);
    widget.notify.value++;
  }
}
