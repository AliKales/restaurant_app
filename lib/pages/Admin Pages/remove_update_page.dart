import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/custom_gradient_button.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/firebase/Firestore.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/lists.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/size.dart';

///* [RemoveUpdatePage] on this page you can remove or update your personnel
class RemoveUpdatePage extends StatefulWidget {
  const RemoveUpdatePage({
    Key? key,
    required this.personnel,
  }) : super(key: key);
  final Personnel personnel;

  @override
  RemoveUpdatePageState createState() => RemoveUpdatePageState();
}

class RemoveUpdatePageState extends State<RemoveUpdatePage> {
  bool progress1 = false;
  bool progress2 = false;
  bool progress3 = false;
  bool progress4 = false;
  int counterToDelete = 3;

  Timer? _timer;
  String lastText = "";
  String updateField = "";

  TextEditingController tEC = TextEditingController();

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => progress1 || progress3 ? false : true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              body(),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    if (!progress1 || !progress3) {
                      Navigator.pop(context);
                    }
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: const Icon(
                    Icons.arrow_back_ios_outlined,
                    color: color4,
                  ),
                ),
              ),
              Visibility(
                visible: progress1,
                child: GestureDetector(
                  onTap: () {
                    if (!progress4) {
                      tEC.clear();
                      setState(() {
                        progress1 = false;
                      });
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig().setHight(30),
                          ),
                          CustomTextField(
                            textEditingController: tEC,
                          ),
                          SizedBox(
                            height: SizeConfig().setHight(6),
                          ),
                          SimpleUIs().widgetWithProgress(
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomGradientButton(
                                    context: context,
                                    text: "Cancel",
                                    isOutlined: true,
                                    color: Colors.black.withOpacity(0.9),
                                    func: () {
                                      tEC.clear();
                                      setState(() {
                                        progress1 = false;
                                      });
                                    },
                                  ),
                                  CustomGradientButton(
                                    context: context,
                                    text: "Update",
                                    func: () {
                                      SimpleUIs.showCustomDialog(
                                        title: "UPDATE",
                                        content: Text(
                                          "Are you sure to update the personnel?",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(color: color4),
                                        ),
                                        context: context,
                                        actions: [
                                          CustomGradientButton(
                                            context: context,
                                            text: "Cancel",
                                            isOutlined: true,
                                            color: color1,
                                            func: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CustomGradientButton(
                                            context: context,
                                            text: "Update",
                                            func: () {
                                              setState(() {
                                                progress4 = true;
                                              });
                                              Navigator.pop(context);
                                              if (lastText != tEC.text) {
                                                update(tEC.text);
                                              } else {
                                                setState(() {
                                                  progress1 = false;
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              progress4),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  body() {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          SizedBox(
            height: SizeConfig().setHight(2),
          ),
          //photo
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 1.96,
                width: MediaQuery.of(context).size.width / 1.96,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color2, color3],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight),
                  borderRadius: BorderRadius.all(
                    Radius.circular(6),
                  ),
                ),
                child: widget.personnel.photoURL == ""
                    ? const SizedBox.shrink()
                    : Image.network(
                        widget.personnel.photoURL,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ClipRRect(
                                child: child,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(6),
                                ),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                              color: color4,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            "ERROR",
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(color: Colors.red),
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 12,
              )
            ],
          ),
          //role Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.edit,
                color: Colors.transparent,
              ),
              Text(
                widget.personnel.role,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(color: color4, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () async {
                  List list = Lists().roles;
                  int role = list.indexWhere(
                      (element) => element == widget.personnel.role);
                  setState(() {
                    progress1 = true;
                  });
                  await SimpleUIs()
                      .showGeneralDialogFunc(context, list, role)
                      .then((value) {
                    if (value != 0 && value != role) {
                      updateField="role";
                      tEC.text = list[value];
                    } else {
                      setState(() {
                        progress1 = false;
                      });
                    }
                  });
                },
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: const Icon(
                  Icons.edit,
                  color: color4,
                ),
              ),
            ],
          ),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          //text NAme lastname
          widgetText(widget.personnel.name + " " + widget.personnel.lastName,
              "name", Icons.edit, null),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          widgetText(
              Funcs()
                  .formatDateTime(DateTime.parse(widget.personnel.createdDate)),
              "",
              null,
              null),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          widgetText("${widget.personnel.id}", "ID: ", null, null),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          widgetText("${widget.personnel.username}", "Username: ", Icons.edit,
              "username"),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          widgetText("${widget.personnel.password}", "Password: ", Icons.edit,
              "password"),
          SizedBox(
            height: SizeConfig().setHight(3),
          ),
          widgetText("${widget.personnel.phone}", "Phone: ",
              Icons.more_horiz_outlined, "phone"),
          SizedBox(
            height: SizeConfig().setHight(6),
          ),
          progress2
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "$counterToDelete..",
                      style: Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: color4),
                    ),
                    CustomGradientButton(
                      context: context,
                      text: "Cancel",
                      isOutlined: true,
                      color: color1,
                      func: () {
                        setState(() {
                          _timer!.cancel();
                          counterToDelete = 3;
                          progress2 = false;
                        });
                      },
                    ),
                    SimpleUIs().progressIndicator()
                  ],
                )
              : CustomGradientButton(
                  context: context,
                  loading: progress3,
                  text: "Delete",
                  func: () async {
                    SimpleUIs.showCustomDialog(
                      title: "DELETE",
                      content: Text(
                        "Are you sure to delete the personnel?",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: color4),
                      ),
                      context: context,
                      actions: [
                        CustomGradientButton(
                          context: context,
                          text: "Cancel",
                          isOutlined: true,
                          color: color1,
                          func: () {
                            Navigator.pop(context);
                          },
                        ),
                        CustomGradientButton(
                          context: context,
                          text: "Delete",
                          func: () {
                            setState(() {
                              progress2 = true;
                            });
                            startTimer();
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  },
                )
        ],
      ),
    );
  }

  dynamic widgetText(String text, String? beforeText, IconData? icon,
      String? textUpdateField) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  beforeText == "name"
                      ? "  - " + text
                      : "  - $beforeText" + text,
                  maxLines: 1,
                  softWrap: false,
                  style: text == widget.personnel.name
                      ? Theme.of(context)
                          .textTheme
                          .headline5!
                          .copyWith(color: color4, fontWeight: FontWeight.bold)
                      : Theme.of(context)
                          .textTheme
                          .headline6!
                          .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        beforeText == "name"
            ? PopupMenuButton(
                padding: const EdgeInsets.all(0),
                icon: Icon(
                  icon,
                  color: color4,
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text('Name'),
                    onTap: () {
                      updateField = "name";
                      lastText = widget.personnel.name;
                      tEC.text = widget.personnel.name;
                      progress4 = false;
                      setState(() {
                        progress1 = true;
                      });
                    },
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: Text('Lastname'),
                    onTap: () {
                      updateField = "lastName";
                      lastText = widget.personnel.lastName;
                      tEC.text = widget.personnel.lastName;
                      progress4 = false;
                      setState(() {
                        progress1 = true;
                      });
                    },
                  ),
                ],
              )
            : IconButton(
                onPressed: () {
                  updateField = textUpdateField!;
                  lastText = text;
                  tEC.text = text;
                  progress4 = false;
                  setState(() {
                    progress1 = true;
                  });
                },
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                icon: Icon(
                  icon,
                  color: color4,
                ),
              ),
      ],
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (counterToDelete == 0) {
          setState(() {
            timer.cancel();
            progress2 = false;
            progress3 = true;
          });
          delete();
        } else {
          setState(() {
            counterToDelete--;
          });
        }
      },
    );
  }

  Future delete() async {
    await Firestore.deletePersonnel(context: context, id: widget.personnel.id)
        .then((value) {
      if (value) {
        Navigator.pop(
            context, {'what': 'delete', 'personnelId': widget.personnel.id});
      }
    });
  }

  Future update(String text) async {
    await Firestore.updatePersonnel(
        where: updateField,
        context: context,
        personnel: widget.personnel,
        mapForUpdate: {updateField: text}).then((value) {
      FocusScope.of(context).unfocus();
      if (value) {
        Map map = widget.personnel.toMap();
        map[updateField] = text;
        Navigator.pop(
            context, {'what': 'update', 'personnel': Personnel.fromJson(map)});
      } else {
        setState(() {
          progress4 = false;
        });
      }
    });
  }
}
