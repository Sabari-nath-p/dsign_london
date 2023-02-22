import 'dart:convert';
import 'package:dsign_london/Card/categoryCard.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Constant/link.dart';

class catBox extends StatefulWidget {
  ValueNotifier notify;
  catBox({super.key, required this.notify});

  @override
  State<catBox> createState() => _catBoxState();
}

class _catBoxState extends State<catBox> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategory();
  }

  List data = [];
  loadCategory() async {
    final response = await http.get(
        Uri.parse("$baseUrl/categories?limit=1000&language=en&parent=null"));

    final js = json.decode(response.body);
    for (var v in js["data"]) {
      if (v['name'] != null && v['image'] != null)
        data.add(categoryCard(
          id: v['id'].toString(),
          name: v['name'].toString(),
          image: v['image']['thumbnail'],
          slug: v["slug"],
          notify: widget.notify,
        ));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    int length = 0;
    int plength = 0;
    int count = 0;
    ;
    if (data.length != null) {
      double tlength = data.length / 2;

      if (tlength % 1 != 0) {
        length = data.length + 1;
        plength = data.length;
      } else {
        length = data.length;
        plength = data.length;
      }
    }

    return Container(
      width: density(390),

      //  color: Color.fromARGB(175, 255, 255, 255),
      padding: EdgeInsets.only(
          left: density(16),
          right: density(10),
          top: density(8),
          bottom: density(21)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            " Category",
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: density(21),
                fontWeight: FontWeight.w600),
          ),
          sizeheight(density(10)),
          sizeheight(density(14)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                sizewidth(10),
                for (count; count < plength; count++) data[count]
              ],
            ),
          )
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
}
