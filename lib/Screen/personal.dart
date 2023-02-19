import 'dart:convert';
import 'dart:io';

import 'package:dsign_london/Constant/Color.dart';
import 'package:dsign_london/Constant/custom.dart';
import 'package:dsign_london/Converter/updateProfile.dart';
import 'package:dsign_london/dataType/userData.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/link.dart';

class Personal extends StatefulWidget {
  userData udata;
  int pid;
  ValueNotifier profileNotify;

  Personal(
      {super.key,
      required this.udata,
      required this.pid,
      required this.profileNotify});

  @override
  State<Personal> createState() => _PersonalState(udata: udata);
}

class _PersonalState extends State<Personal> {
  userData udata;
  _PersonalState({
    required this.udata,
  });

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadToken();
    nameController.text = udata.name;
    phoneController.text = udata.phone;
    emailController.text = udata.email;
  }

  bool editingMode = false;
  bool focuse = false;
  String token = "";
  var file = null;
  loadToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = pref.getString("TOKEN").toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryColor(),
        body: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                      left: 16,
                      top: 45,
                      right: 334,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: primaryColor(),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      )),
                  if (file == null)
                    Positioned(
                        left: density(100),
                        right: density(100),
                        top: density(30),
                        height: density(100),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white)),
                          child: CircleAvatar(
                            backgroundColor: (udata.profileUrl ==
                                    "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                ? Colors.white24
                                : Colors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: SizedBox(
                                width: density(95),
                                height: density(95),
                                child: Image.network(
                                  udata.profileUrl,
                                  color: (udata.profileUrl ==
                                          "http://api.ecom.alpha.logidots.com/storage/3051/conversions/R-thumbnail.jpg")
                                      ? Colors.white
                                      : null,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        )),
                  if (file != null)
                    Positioned(
                        left: 100,
                        right: 100,
                        top: 30,
                        height: 100,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.file(
                                file,
                              )),
                        )),
                  if (editingMode)
                    Positioned(
                      left: 210,
                      top: 110,
                      child: InkWell(
                        onTap: () async {
                          var status = await Permission.storage.request();
                          if (status.isDenied) {
                            if (await Permission.storage.request().isGranted) {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                            } else {
                              Fluttertoast.showToast(
                                  msg: " Please grant permission to continue ");
                            }
                          }
                          if (await Permission.storage.isRestricted) {
                            Fluttertoast.showToast(
                                msg: "Permission is not granted");
                          }
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null) {
                            setState(() {
                              file = File(result.files.single.path!);
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.withOpacity(.5),
                          radius: 12,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                      left: 100,
                      right: 100,
                      bottom: 15,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (!editingMode) {
                              editingMode = true;
                              focuse = true;
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!editingMode)
                              FaIcon(
                                FontAwesomeIcons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            sizewidth(3),
                            if (!editingMode)
                              Text(
                                "Edit",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Monsterrat",
                                    color: Colors.white),
                              ),
                            if (editingMode)
                              InkWell(
                                onTap: () {
                                  if (file != null) {
                                    uploadAttachment();
                                  } else if (file == null &&
                                      nameController.text != udata.name) {
                                    updateName();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "No changes made");
                                    setState(() {
                                      editingMode = false;
                                    });
                                  }
                                },
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Monsterrat",
                                      color: Colors.white),
                                ),
                              ),
                            if (editingMode) sizewidth(10),
                            if (editingMode)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    nameController.text = udata.name;
                                    file = null;
                                    editingMode = false;
                                  });
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Monsterrat",
                                      color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35))),
                child: Column(
                  children: [
                    sizeheight(30),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0XFF929DB9),
                      ))),
                      child: Row(
                        children: [
                          Text(
                            "Name :",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0XFF929DB9),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Monsterrat",
                            ),
                          ),
                          sizewidth(8),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              enabled: editingMode,
                              onSubmitted: (value) async {},
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0XFF929DB9),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Monsterrat",
                              ),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: nameController,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0XFF929DB9),
                      ))),
                      child: Row(
                        children: [
                          Text(
                            "Phone :",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0XFF929DB9),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Monsterrat",
                            ),
                          ),
                          sizewidth(8),
                          SizedBox(
                            width: 200,
                            child: TextField(
                              enabled: false,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0XFF929DB9),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Monsterrat",
                              ),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: phoneController,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        color: Color(0XFF929DB9),
                      ))),
                      child: Row(
                        children: [
                          Text(
                            "Email :",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0XFF929DB9),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Monsterrat",
                            ),
                          ),
                          sizewidth(8),
                          Expanded(
                            child: TextField(
                              enabled: false,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0XFF929DB9),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Monsterrat",
                              ),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: emailController,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateName() async {
    final Response = await http.put(Uri.parse("$baseUrl/users/${udata.id}"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: ({
          "id": udata.id.toString(),
          "name": "${nameController.text.toString()}",
        }));

    if (Response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Profile Updated");
      setState(() {
        editingMode = false;
        udata.name = nameController.text.toString();
        //   udata.profileUrl = up.profile!.avatar!.thumbnail.toString();
        widget.profileNotify.value++;
      });
    } else {}
  }

  update() async {
    updateProfile up = updateProfile();
    up.id = udata.id;
    up.name = nameController.text.trim();
    Profile profile = Profile();
    profile.bio = "";
    profile.avatar = avatar;
    profile.id = widget.pid;
    up.profile = profile;

    final Response = await http.put(Uri.parse("$baseUrl/users/${udata.id}"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'content-type': 'application/json; charset=utf-8',
          "content-type": "application/json"
        },
        body: json.encode(up.toJson()));

    if (Response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Profile Updated");
      setState(() {
        editingMode = false;
        udata.name = up.name.toString();
        udata.profileUrl = up.profile!.avatar!.thumbnail.toString();
        widget.profileNotify.value++;
      });
    } else {}
  }

  uploadAttachment() async {
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': "application/json"
    };

    var imagerequest = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/attachments/'),
    );

    imagerequest.files.add(await http.MultipartFile.fromPath(
      "attachment[]",
      file!.path,
    ));
    imagerequest.headers.addAll(headers);

    update();
    http.StreamedResponse response = await imagerequest.send();
    String result = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      var data = json.decode(result);

      for (var image in data) {
        Avatar temp = Avatar.fromJson(image);
        avatar = temp;

        update();
      }
    } else {}
  }

  double density(
    double d,
  ) {
    double height = MediaQuery.of(context).size.width;
    double value = d * (height / 390);
    return value;
  }

  late Avatar avatar;
}
