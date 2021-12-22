import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:restaurant_app/UIs/appbar_persons.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/firebase/Storage.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/size.dart';

class AddNewPersonal extends StatefulWidget {
  const AddNewPersonal({Key? key, required this.restaurantName})
      : super(key: key);

  final String restaurantName;

  @override
  _AddNewPersonalState createState() => _AddNewPersonalState();
}

class _AddNewPersonalState extends State<AddNewPersonal> {
  TextEditingController tECName = TextEditingController();
  TextEditingController tECLastname = TextEditingController();
  TextEditingController tECUsername = TextEditingController();
  TextEditingController tECPhone = TextEditingController();
  TextEditingController tECPassword = TextEditingController();
  TextEditingController tECRole = TextEditingController();

  List roles = ["Select a role", "Staff", "Chef", "Cashier"];
  int selectedRole = 0;

  File? photo;

  ScrollController scrollController = ScrollController();

  bool progress1 = false;
  bool progress2 = false;

  int uploadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const AppbarForPersons(
        text: "Add New Personnel",
        isPushed: true,
      ),
      body: body(),
    );
  }

  body() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              textField(tECName, "Name*", false),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              textField(tECLastname, "Last name", false),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              textField(tECUsername, "Username*", true),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              textField(tECPassword, "Password*", true),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              textField(tECPhone, "Phone number", false),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              //Role
              CustomTextField(
                text: "Select a role*",
                textEditingController: tECRole,
                readOnly: true,
                function: () {
                  SimpleUIs()
                      .showGeneralDialogFunc(context, roles, selectedRole)
                      .then((value) {
                    setState(() {
                      selectedRole = value;
                      tECRole.text = roles[value];
                    });
                  });
                },
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              //Buttons
              Visibility(
                visible: !progress1,
                //buttons to take photo
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomGradientButton(
                      context: context,
                      text: "From Gallery",
                      isOutlined: true,
                      color: color1,
                      func: () {
                        cropImage(true);
                      },
                    ),
                    CustomGradientButton(
                      context: context,
                      isOutlined: true,
                      color: color1,
                      text: "Take a Photo",
                      func: () {
                        cropImage(false);
                      },
                    )
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              //if a photo picked it shows it here between buttons
              photo == null
                  ? const SizedBox.shrink()
                  // if progress2 is true that means photo is uploading onto database and it shows Text with upload progress
                  : progress2 == true
                      ? Text(
                          "Uploading.. $uploadProgress%",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  color: color4, fontWeight: FontWeight.bold),
                        )
                      //photo
                      : Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width / 1.96,
                                  width:
                                      MediaQuery.of(context).size.width / 1.96,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [color2, color3],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.width / 2,
                                  width: MediaQuery.of(context).size.width / 2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(photo!),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            )
                          ],
                        ),
              //add button
              progress1
                  ? SimpleUIs().progressIndicator()
                  //button add
                  : CustomGradientButton(
                      context: context,
                      text: "Add",
                      icon: const Icon(
                        Icons.person_add,
                        color: color4,
                      ),
                      func: addPersonnel,
                    )
            ],
          ),
        ),
      ),
    );
  }

  CustomTextField textField(
      TextEditingController textEditingController, String text, bool english) {
    return CustomTextField(
      textEditingController: textEditingController,
      isOnlyEnglish: english,
      text: text,
      keyboardType: text == "Phone number" ? TextInputType.number : null,
      inputFormatters: text == "Phone number"
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }

  ///////////////////////////////////////////FUNCTIONS
  Future addPersonnel() async {
    FocusScope.of(context).unfocus();
    SimpleUIs.showCustomDialog(
        context: context,
        title: "SURE?",
        content: Text(
          "Check the informations first",
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: color4),
        ),
        actions: [
          CustomGradientButton(
            context: context,
            text: "Cancel",
            isOutlined: true,
            func: () => Navigator.pop(context),
          ),
          CustomGradientButton(
              context: context, text: "Add", func: addPersonnelToDatabase)
        ]);
  }

  Future addPersonnelToDatabase() async {
    Navigator.pop(context);
    setState(() {
      progress1 = true;
      // progress2 makes the photo visible and show uploading progress
      progress2 = true;
    });
    String error = await checkIfReadyToShare();
    if (error != "") {
      setState(() {
        progress1 = false;
      });
      return;
    }

    // current global time is gotten and maden an uniqe id. With this new added personnel will be shown at top of the database
    DateTime currentGlobalTime = await Funcs().getCurrentGlobalTime(context);
    DateTime day = DateTime(3000, 04, 04, 23, 59, 59);
    String id = day.difference(currentGlobalTime).toString();
    id = id.replaceAll(":", "");
    id = id.replaceAll(".", "");

    if (photo != null) {
      await Storage.addPersonnelPhoto(
          context: context,
          file: photo!,
          id: id,
          uploadedByte: (uploadedByte) {
            setState(() {
              uploadProgress = uploadedByte.toInt();
            });
          },
          onFinish: (downloadURL) async {
            if (downloadURL == "") {
              Funcs().showSnackBar(context, "Error! Please try again");
            } else {
              await addPersonnelToDatabase2(downloadURL, id);
            }
            setState(() {
              progress1 = false;
              // progress2 makes the photo visible and show uploading progress
              progress2 = false;
            });
          });
    } else {
      await addPersonnelToDatabase2("", id);
      setState(() {
        progress1 = false;
        // progress2 makes the photo visible and show uploading progress
        progress2 = false;
      });
    }
  }

  Future addPersonnelToDatabase2(String downloadURL, String id) async {
    final personnel = Personnel(
        name: tECName.text,
        lastName: tECLastname.text,
        username: tECUsername.text,
        phone: tECPassword.text,
        photoURL: downloadURL,
        createdDate: DateTime.now().toIso8601String(),
        role: tECRole.text,
        password: tECPassword.text,
        id: id,
        restaurantName: widget.restaurantName);
    await Firestore.addPersonnel(context: context, personnel: personnel)
        .then((value) {
      if (value) {
        Funcs().showSnackBar(context, "Personnel has been successfully added.");
        Navigator.pop(context,personnel);
      }
    });
  }

  Future<String> checkIfReadyToShare() async {
    List<TextEditingController> tECs = [
      tECName,
      tECLastname,
      tECUsername,
      tECPassword,
      tECPassword,
      tECRole
    ];

    if (tECs[0].text == "" ||
        tECs[2].text == "" ||
        tECs[3].text == "" ||
        selectedRole == 0) {
      Funcs().showSnackBar(
          context, "Name & Username & Password & Role can't be empty!");
      return "error";
    }
    //  else if (photo == null) {
    //   Funcs().showSnackBar(context, "Photo is required");
    //   return "error";
    // }
    else {
      for (var item in tECs) {
        item.text = item.text.trim();
      }
      return "";
    }
  }

  Future cropImage(bool isGallery) async {
    final file =
        await Funcs.pickMedia(isGallery: isGallery, cropImage: cropImageFunc);
    if (file != null) {
      setState(() {
        photo = file;
      });
      await Future.delayed(const Duration(seconds: 1));
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
    }
  }

  Future<File?> cropImageFunc(File imageFile) async {
    return await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressQuality: 70,
    );
  }
  ///////////////////////////////////////////END OF THE FUNCTIONS
}
