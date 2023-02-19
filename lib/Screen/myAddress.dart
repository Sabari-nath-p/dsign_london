import 'dart:convert';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/locationBottom.dart';
import 'package:dsign_london/Screen/cart.dart';
import 'package:dsign_london/dataType/adressData.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/custom.dart';
import '../Constant/link.dart';

List<addressData> newAdata = [];

class myAddress extends StatefulWidget {
  String token;
  myAddress({super.key, required this.token});

  @override
  State<myAddress> createState() => _myAddressState();
}

class _myAddressState extends State<myAddress> {
  List<addressData> adata = [];
  String ppUrl =
      "https://www.oseyo.co.uk/wp-content/uploads/2020/05/empty-profile-picture-png-2.png";
  loadUser() async {
    Box box = await Hive.openBox("user");

    final response = await http.get(Uri.parse("$baseUrl/me"),
        headers: ({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}'
        }));
    userData u = box.get(1);
    if (response.statusCode == 200) {
      var js = json.decode(response.body);

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
      ppUrl =
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

      setState(() {
        loading = 1;
      });
    }
  }

  ValueNotifier<int> addressnotifer = ValueNotifier<int>(0);
  int loading = 0;
  startaddressListen() {
    addressnotifer.addListener(() {
      setState(() {
        adata = newAdata;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUser();
    startaddressListen();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: (loading != 0)
              ? Stack(
                  children: [
                    Positioned(
                      top: 0,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
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
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: CircleAvatar(
                                      radius: density(20),
                                      backgroundColor:
                                          Color.fromARGB(223, 240, 240, 235)
                                              .withOpacity(0.2),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                      )),
                                ),
                                sizewidth(density(28)),
                                Expanded(
                                  child: Text(
                                    "Address",
                                    style: TextStyle(
                                        fontSize: density(20),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Montserrat",
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (loading == 1 && adata.length > 0)
                                  for (int i = 0; i < adata.length; i++)
                                    addressCard(adata[i]),
                                if (adata.length == 0 && loading == 1)
                                  noData("Sorry, you didn't add any address."),
                                sizeheight(78)
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            setAdress(context, addressnotifer);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 22),
                            width: 358,
                            height: 52,
                            alignment: Alignment.center,
                            child: Text(
                              "Add Address",
                              style: TextStyle(
                                  fontSize: density(16),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Montserrat",
                                  color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(26),
                                color: primaryColor()),
                          ),
                        ))
                  ],
                )
              : Container(
                  alignment: Alignment.center,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: primaryColor(), size: 40),
                )),
    );
  }

  double density(double d) {
    double width = MediaQuery.of(context).size.width;
    double value = d * (width / 390);
    return value;
  }

  addressCard(addressData addressData) {
    return Container(
      margin: EdgeInsets.all(8),
      width: density(358),
      height: density(103),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor())),
      child: Stack(
        children: [
          Positioned(
            top: density(16),
            left: density(16),
            child: Text(
              addressData.title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: "Montserrat"),
            ),
          ),
          Positioned(
              top: 10,
              right: 40,
              child: InkWell(
                onTap: () {
                  editAddress(context, addressnotifer, addressData);
                },
                child: Icon(
                  Icons.edit,
                  size: 15,
                ),
              )),
          Positioned(
              top: 10,
              right: 15,
              child: InkWell(
                onTap: () {
                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      text: 'Do you want to delete address',
                      confirmBtnText: 'Yes',
                      cancelBtnText: 'No',
                      confirmBtnColor: Colors.green,
                      onConfirmBtnTap: () {
                        setState(() {
                          adata.remove(addressData);
                        });
                        deleteAddress(context, addressData, addressnotifer);
                        Navigator.pop(context);
                      },
                      onCancelBtnTap: () {
                        Navigator.pop(context);
                      });
                },
                child: Icon(
                  Icons.delete,
                  size: 15,
                ),
              )),
          Positioned(
            top: density(38),
            left: density(16),
            child: Text(
              addressData.address,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: "Montserrat"),
            ),
          ),
          Positioned(
            top: density(54),
            left: density(16),
            child: Text(
              addressData.city +
                  " " +
                  addressData.state +
                  ", " +
                  addressData.zip +
                  "-" +
                  addressData.country,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontFamily: "Montserrat"),
            ),
          ),
        ],
      ),
    );
  }
}
