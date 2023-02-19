import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/productData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hive_flutter/hive_flutter.dart';

class cartProduct extends StatefulWidget {
  productData pdata;
  ValueNotifier notify;
  cartProduct({super.key, required this.pdata, required this.notify});

  @override
  State<cartProduct> createState() => _cartProductState(pdata: pdata);
}

class _cartProductState extends State<cartProduct> {
  productData pdata;
  _cartProductState({required this.pdata});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String sqty; // convert quantity count to fromatted String model
    if (pdata.quantity < 10)
      sqty = "0${pdata.quantity}";
    else
      sqty = pdata.quantity.toString();
    return (pdata.quantity == 0)
        ? Container()
        : Container(
            width: density(390),
            height: density(94),
            child: Row(
              children: [
                sizewidth(density(10)),
                SizedBox(
                    width: density(70),
                    height: density(70),
                    child: Image.network(pdata.image)),
                sizewidth(density(8)),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeheight(density(20)),
                    Expanded(
                      child: Text(
                        "${pdata.name}",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: density(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      pdata.unit,
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: density(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    sizeheight(density(20)),
                  ],
                )),
                Container(
                  height: density(37),
                  padding: EdgeInsets.symmetric(horizontal: density(10)),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withOpacity(.35)),
                      borderRadius: BorderRadius.circular(density(70))),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            int save = (pdata.save / pdata.quantity).toInt();
                            pdata.quantity--;
                            pdata.save = save * pdata.quantity;
                            pdata.subTotal = pdata.price * pdata.quantity;
                            addtoCart();
                          });
                        },
                        child: Text(
                          "-",
                          style: TextStyle(
                            fontSize: density(30),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      sizewidth(density(10)),
                      Text(
                        "$sqty",
                        style: TextStyle(
                          fontSize: density(20),
                          fontFamily: "Montserrat",
                        ),
                      ),
                      sizewidth(density(10)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            int save = (pdata.save / pdata.quantity).toInt();
                            pdata.quantity++;
                            pdata.save = save * pdata.quantity;
                            pdata.subTotal = pdata.price * pdata.quantity;
                            addtoCart();
                          });
                        },
                        child: Icon(
                          Icons.add,
                        ),
                      ),
                    ],
                  ),
                ),
                sizewidth(density(5)),
                SizedBox(
                  width: density(60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹${pdata.subTotal.toString()}",
                        style: TextStyle(
                          fontFamily: "Montserrat",
                          fontSize: density(17),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (pdata.save != 0)
                        Text(
                          "₹${(pdata.save + pdata.subTotal).toString()}",
                          style: TextStyle(
                              fontFamily: "Montserrat",
                              fontSize: density(12),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough),
                        )
                    ],
                  ),
                ),
                sizewidth(density(5)),
              ],
            ),
          );
  }

  double density(
    double d,
  ) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }

  addtoCart() async {
    checknotify.value++;
    Box box = await Hive.openBox("cart");

    box.put(pdata.id, pdata);

    widget.notify.value++;
  }
}
