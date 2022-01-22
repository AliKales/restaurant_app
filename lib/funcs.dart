import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import 'firebase/Firestore.dart';

class Funcs {
  final String url = "http://worldtimeapi.org/api/timezone/Europe/Istanbul";

  Future<dynamic> navigatorPush(context, page) async {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => page);
    var object = await Navigator.push(context, route);
    return object;
  }

  void navigatorPushReplacement(context, page) {
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => page);
    Navigator.pushReplacement(context, route);
  }

  String formatMoney(money) {
    return NumberFormat.simpleCurrency().format(money);
  }

  final englishCharacters = RegExp(r'^[a-zA-Z0-9_.\-=]+$');
  //username ve password check, if it has no problem it returns "" but if there's a problem it returns the error message
  Future<String> usernameAndPasswordChecker(
      String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return "User Name and Password can not be empty!";
    } else if (!englishCharacters.hasMatch(username) ||
        !englishCharacters.hasMatch(password)) {
      return 'User Name and Password only English characters, (-) (_) (.) and no WhiteSpace';
    } else {
      username.trim();
      password.trim();
      return "";
    }
  }

  void showSnackBar(context, String text) {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<DateTime?> getCurrentGlobalTime(context) async {
    DateTime? now;
    try {
      Response response = await get(
        Uri.parse(
          "http://worldtimeapi.org/api/timezone/Europe/Istanbul",
        ),
      );
      Map worldData = jsonDecode(response.body);
      now = DateTime(
        int.parse(worldData['datetime'].substring(0, 4)),
        int.parse(worldData['datetime'].substring(5, 7)),
        int.parse(worldData['datetime'].substring(8, 10)),
        int.parse(worldData['datetime'].substring(11, 13)),
        int.parse(worldData['datetime'].substring(14, 16)),
        int.parse(worldData['datetime'].substring(17, 19)),
      );
    } catch (e) {
      now = null;
      Funcs().showSnackBar(context, "ERROR!!");
    }

    return now;
  }

  Future<DateTime?> gCGT2(context) async {
    DateTime? now;
    try {
      Response response = await get(
        Uri.parse(
          "https://www.timeapi.io/api/Time/current/coordinate?latitude=41.015137&longitude=28.979530",
        ),
      );
      Map worldData = jsonDecode(response.body);
      now = DateTime.parse(worldData['dateTime']);
    } catch (e) {
      now = null;
      Funcs().showSnackBar(context,
          "Unexpected error, please try again later or check app update!");
    }
    return now;
  }

  Future<DateTime?> getCurrentGlobalTimeForRestaurantCreating(context) async {
    DateTime? now;
    try {
      Response response = await get(
        Uri.parse(
          "http://worldtimeapi.org/api/timezone/Europe/Istanbul",
        ),
      );
      Map worldData = jsonDecode(response.body);
      now = DateTime(
        int.parse(worldData['datetime'].substring(0, 4)),
        int.parse(worldData['datetime'].substring(5, 7)),
        int.parse(worldData['datetime'].substring(8, 10)),
        int.parse(worldData['datetime'].substring(11, 13)),
        int.parse(worldData['datetime'].substring(14, 16)),
        int.parse(worldData['datetime'].substring(17, 19)),
      );
    } catch (e) {
      now = await gCGT2(context);
    }

    return now;
  }

  ///* [pickMedia] this method gets or take photo and crop it
  static Future<File?> pickMedia({
    required bool isGallery,
    Future<File?> Function(File file)? cropImage,
  }) async {
    final source = isGallery ? ImageSource.gallery : ImageSource.camera;
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile == null) return null;

    if (cropImage == null) return null;

    return cropImage(File(pickedFile.path));
  }

  String formatDateTime(DateTime dateTime) {
    List<String> value = dateTime.toString().split(" ");
    List<String> value2 = value[1].split(":");
    return "${value[0]} ${value2[0]}:${value2[1]}";
  }

  List<Personnel> sortList(String sortText, sortWhere, List sortList) {
    List<Map> list = [];
    List<Personnel> returnList = [];
    for (var item in sortList) {
      list.add(item.toMap());
    }
    List<Map> list2 =
        list.where((element) => element[sortWhere] == sortText).toList();
    list.removeWhere((element) => element[sortWhere] == sortText);
    for (var element in list2) {
      returnList.add(Personnel.fromJson(element));
    }
    for (var item in list) {
      returnList.add(Personnel.fromJson(item));
    }
    return returnList;
  }

  static void showSupportErrorMessage(
      {required final context,
      required final String text,
      required final String title}) async {
    SimpleUIs.showCustomDialog(
        context: context,
        title: title,
        actions: [
          CustomGradientButton(
            context: context,
            text: "Copy Mail",
            func: () {
              Clipboard.setData(
                  ClipboardData(text: "suggestionsandhelp@hotmail.com"));
              Navigator.pop(context);
              Funcs().showSnackBar(context, "E-Mail copied");
            },
          ),
          CustomGradientButton(
            context: context,
            text: "Copy Instagram",
            func: () {
              Clipboard.setData(ClipboardData(text: "caroby2"));
              Navigator.pop(context);
              Funcs().showSnackBar(context, "Instagram copied");
            },
          )
        ],
        content: Text(text,
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: color4, fontWeight: FontWeight.bold)));
  }

  static Future<String?> createId({
    required final context,
    final String? personnelUsername,
  }) async {
    DateTime currentGlobalTime = DateTime.now();

    DateTime day = DateTime(3000, 04, 04, 23, 59, 59);

    String id = day.difference(currentGlobalTime).toString();
    id = currentGlobalTime.toString();
    id = id.replaceAll(":", "");
    id = id.replaceAll(".", "");
    id = id.substring(0, id.length - 6);
    id = id.replaceAll("-", "");
    id = id.replaceAll(" ", "");
    if (personnelUsername != null) {
      id = "$id$personnelUsername";
    }
    return id;
  }

  Future<bool?> getPolicies(String value, context) async {
    Map? result = await Firestore().getPolicies(context);

    if (result == null) {
      Funcs().showSnackBar(context, "ERROR PLEASE TRY AGAIN");
      return false;
    }
    String text = result[value].toString().replaceAll("|n", "\n\n");
    List list = result['privacyList'];
    SimpleUIs.showCustomDialog(
      context: context,
      title: value == "privacy" ? "Privacy Policy" : "Terms & Conditions",
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(color: color4),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                int counter = index + 1;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () async {
                      if (!await launch(list[index]['link'])) {
                        Clipboard.setData(
                          ClipboardData(
                            text: list[index]['link'],
                          ),
                        );
                        Funcs().showSnackBar(context, "Link copied!");
                      }
                    },
                    child: Text(
                      "$counter: ${list[index]['text']}",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: color2),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
