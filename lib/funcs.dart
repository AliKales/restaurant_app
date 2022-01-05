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
          headers: {
            "Access-Control-Allow-Origin": " *",
            "Access-Control-Allow-Headers":
                "Access-Control-Allow-Origin, Accept"
          });
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

  Future<DateTime?> getCurrentGlobalTimeForRestaurantCreating(context) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    DateTime? now;
    try {
      Response response = await get(
          Uri.parse(
            //"https://www.timeapi.io/api/Time/current/coordinate?latitude=41.015137&longitude=28.979530"
            "http://worldtimeapi.org/api/timezone/Europe/Istanbul",
          ),
          headers: requestHeaders);
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
      Funcs().showSnackBar(context, e.toString());
      // Funcs().showSnackBar(context,
      //     "Unexpected error, please try again later or check app update!");
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
    DateTime? currentGlobalTime;
    if (personnelUsername == null) {
      currentGlobalTime = await Funcs().getCurrentGlobalTime(context);
      if(currentGlobalTime==null){        
        return null;
      }
    } else {
      currentGlobalTime = DateTime.now();
    }

    DateTime day = DateTime(3000, 04, 04, 23, 59, 59);
    String id = day.difference(currentGlobalTime).toString();
    id = id.replaceAll(":", "");
    id = id.replaceAll(".", "");
    id = id.substring(0, id.length - 6);
    if(personnelUsername!=null){
      id="$personnelUsername$id";
    }
    return id;
  }
}
