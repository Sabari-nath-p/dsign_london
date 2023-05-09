import 'dart:convert';

import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Card/flashBox.dart';
import 'package:dsign_london/Constant/link.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class flashSale extends StatefulWidget {
  ValueNotifier notify;
  flashSale({super.key, required this.notify});

  @override
  State<flashSale> createState() => _flashSaleState();
}

class _flashSaleState extends State<flashSale> {
  List flashList = [];

  loadProductList() async {
    final response = await http.get(Uri.parse(
        "https://api.designlondon.alpha.logidots.com/popular-products?type_slug=designlondon&limit=10&with=type;author&language=en"));
    var data = json.decode(response.body);
    print(data);
    for (var product in data) {
      setState(() {
        if (product["quantity"] > 0) {
          flashList.add(flashProductCard(
            pdata: product,
            notify: widget.notify,
          ));
          flashList.add(sizewidth(17));
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProductList();
  }

  @override
  Widget build(BuildContext context) {
    return (flashList.length == 0)
        ? Container()
        : Container(
            width: density(390),
            height: density(350),
            padding: EdgeInsets.only(
                left: density(13),
                right: density(13),
                top: density(8),
                bottom: density(18)),
            //  color: Color.fromARGB(175, 255, 255, 255),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  " Popular Product",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: density(21),
                      fontWeight: FontWeight.w600),
                ),
                sizeheight(density(11)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      sizewidth(density(8)),
                      if (flashList.length > 0)
                        for (int i = 0; i < flashList.length; i++) flashList[i],
                    ],
                  ),
                )
              ],
            ),
          );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }
}
