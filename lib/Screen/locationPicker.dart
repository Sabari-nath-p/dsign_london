import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

class locationPicker extends StatefulWidget {
  const locationPicker({super.key});

  @override
  State<locationPicker> createState() => _locationPickerState();
}

class _locationPickerState extends State<locationPicker> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  TextEditingController address = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController zip = TextEditingController();
  TextEditingController details = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              InkWell(
                  onTap: () {
                    setLocation();
                  },
                  child: Text("click me")),
            ],
          ),
        ),
      ),
    );
  }

  setLocation() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            width: 390,
            height: 170,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "Chakkalayil cheriyanad Po chengannur,kerala 689511,india",
                    style: TextStyle(fontSize: 12, fontFamily: "Montserrat"),
                  ),
                ),
                sizeheight(15),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setAdress();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: primaryColor(),
                        borderRadius: BorderRadius.circular(70)),
                    child: Text("Set Location",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: "Montserrat")),
                  ),
                )
              ],
            ),
          );
        });
  }

  setAdress() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
              width: 390,
              height: 513,
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sizeheight(10),
                    Row(children: [
                      SizedBox(
                          height: 50,
                          width: 40,
                          child: Image.asset("assets/image/mapIcon.JPG")),
                      sizewidth(8),
                      Text(
                        "Shipping Address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      )
                    ]),
                    Text("  Enter your delivery address",
                        style: TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                    sizeheight(12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Home/ Address"),
                      ),
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Country"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "State"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Row(
                      children: [
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "City"),
                          ),
                        ),
                        sizewidth(20),
                        Container(
                          width: 160,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black26.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Zip"),
                          ),
                        ),
                      ],
                    ),
                    sizeheight(12),
                    Container(
                      height: 115,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black26.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: "Details"),
                      ),
                    ),
                    sizeheight(25),
                    InkWell(
                      onTap: () async {
                        if (address.text.trim() != "" &&
                            country.text.trim() != "" &&
                            state.text.trim() != "" &&
                            city.text.trim() != "" &&
                            zip.text.trim() != "" &&
                            details.text.trim() != "") {
                          //
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please fill all data to continue");
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: primaryColor(),
                            borderRadius: BorderRadius.circular(70)),
                        child: Text("Set Location",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontFamily: "Montserrat")),
                      ),
                    ),
                    sizeheight(25)
                  ],
                ),
              ),
            ));
  }
}
