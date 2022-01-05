import 'package:flutter/material.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/size.dart';

import 'custom_gradient_button.dart';

class SimpleUIs {
  Widget progressIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: color3,
      ),
    );
  }

  Widget widgetWithProgress(Widget widget, bool progress) {
    if (progress) {
      return progressIndicator();
    } else {
      return widget;
    }
  }

  Future showProgressIndicator(context) async {
    FocusScope.of(context).unfocus();
    await showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (_, __, ___) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: progressIndicator(),
            ),
          );
        });
  }

  static Future showCustomGeneralDialog({
    required context,
    bool? barrierDismissible,
    required Widget widget
  }) async {
    FocusScope.of(context).unfocus();
    await showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: barrierDismissible??false,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (_, __, ___) {
          return WillPopScope(
            onWillPop: () async => barrierDismissible??false,
            child: widget,
          );
        });
  }

  ///* [showCustomDialog] shows picker from list like IOS design
  Future<int> showGeneralDialogFunc(context, List list, int value) async {
    FocusScope.of(context).unfocus();
    int val = 0;
    bool isSelected = false;
    await showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              margin: const EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width,
              height: SizeConfig.safeBlockVertical! * 30,
              decoration: const BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: SizeConfig.safeBlockVertical! * 4,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey))),
                  ),
                  NotificationListener<OverscrollIndicatorNotification>(
                    onNotification:
                        (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListWheelScrollView(
                      itemExtent: SizeConfig.safeBlockVertical! * 5,
                      onSelectedItemChanged: (selectedItem) {
                        val = selectedItem;
                      },
                      perspective: 0.005,
                      children: getChildrenForListWheel(
                        context,
                        list,
                      ),
                      physics: const FixedExtentScrollPhysics(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () {
                          isSelected = true;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.grey, elevation: 0),
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              )),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
    if (isSelected) {
      return val;
    } else {
      return value;
    }
  }

  ///* [getChildrenForListWheel] shouldn't be used from anywhere, it's a specific code for [showGeneralDialogFunc]
  List<Widget> getChildrenForListWheel(context, List list) {
    List<Widget> listForWiget = [];
    for (var i = 0; i < list.length; i++) {
      listForWiget.add(Center(
        child: Text(
          list[i].toString(),
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ));
    }
    return listForWiget;
  }

  static void showCustomDialog(
      {required context,
      String title = "",
      Widget? content,
      bool? barriedDismissible,
      bool? onWillPop,
      List<Widget>? actions,
      bool activeCancelButton = false}) {
    if (activeCancelButton && actions != null) {
      actions.insert(
        0,
        CustomGradientButton(
          context: context,
          color: color1,
          isOutlined: true,
          text: "CANCEL",
          func: () {
            Navigator.pop(context);
          },
        ),
      );
    }
    showDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      context: context,
      barrierDismissible: barriedDismissible ?? true,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => onWillPop ?? true,
          child: AlertDialog(
            backgroundColor: color1,
            title: Text(
              title,
              style: const TextStyle(color: color4),
            ),
            content: content,
            actions: actions ??
                <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: color4),
                    ),
                  ),
                ],
          ),
        );
      },
    );
  }
}
