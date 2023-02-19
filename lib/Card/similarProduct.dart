import 'package:dsign_london/Card/similarProductBox.dart';
import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/product_details.dart';
import 'package:flutter/material.dart';

class similarProduct extends StatefulWidget {
  var data;
  String id;
  ValueNotifier notify;
  similarProduct(
      {super.key, required this.data, required this.notify, required this.id});

  @override
  State<similarProduct> createState() =>
      _similarProductState(data: data, id: id);
}

class _similarProductState extends State<similarProduct> {
  var data;
  String id;
  _similarProductState({required this.data, required this.id});
  List smProduct = [];
  loadProduct() {
    for (var pd in data) {
      if (pd["quantity"] > 0 && pd["id"].toString() != id) {
        setState(() {
          smProduct.add(similarBox(pdata: pd, notify: widget.notify));
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: density(270),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: density(22),
            width: density(154),
            child: Text(
              'Similar Products',
              style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  fontSize: density(18)),
            ),
          ),
          sizeheight(density(14)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < smProduct.length; i++) smProduct[i]
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
