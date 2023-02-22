import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/categoryList.dart';
import 'package:flutter/material.dart';

class categoryCard extends StatelessWidget {
  String name;
  String image;
  String id;
  String slug;
  ValueNotifier notify;

  categoryCard(
      {super.key,
      required this.name,
      required this.image,
      required this.id,
      required this.slug,
      required this.notify});
  late BuildContext Context;
  @override
  Widget build(BuildContext context) {
    Context = context;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => categoryList(
                  id: id,
                  slug: slug,
                  notify: notify,
                ))));
      },
      child: Container(
        width: density(108),
        height: density(137),
        margin: EdgeInsets.only(right: density(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(density(7)),
        ),
        child: SizedBox(
          width: density(90),
          child: Image.network(
            image,
            fit: BoxFit.fill,
          ),
        ), /*Column(
          children: [
            sizeheight(density(8)),
            Expanded(
              child: 
            ),
          ],
        ),*/
      ),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(Context).size.width;
    double value = d * (width / 390);
    return value;
  }
}
