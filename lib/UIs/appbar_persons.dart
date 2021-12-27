import 'package:flutter/material.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/pages/personal_manager_page.dart';

class AppbarForPersons extends StatelessWidget implements PreferredSizeWidget {
  const AppbarForPersons(
      {Key? key,
      this.text = "",
      this.isPushed = false,
      this.actions,
      this.functionForLeadingIcon})
      : super(key: key);

  final String text;
  final List<Widget>? actions;

  ///* [isPushed] if it's true, it deletes action icon
  ///* default is false.
  final bool isPushed;

  ///* [functionForLeadingIcon] if there is specific code
  final Function()? functionForLeadingIcon;

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(text),
      elevation: 1,
      backgroundColor: color1,
      leading: isPushed
          ? Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: functionForLeadingIcon ??
                      () {
                        Navigator.pop(context);
                      },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            )
          : null,
      actions: isPushed
          ? actions ?? []
          : actions ??
              [
                IconButton(
                  onPressed: () {
                    Funcs.showSupportErrorMessage(
                        context: context,
                        title: "CONTACT US",
                        text:
                            "If you have any problem or something to ask, please contact us via E-Mail or Instagram\nE-mail: suggestionsandhelp@hotmail.com\nInstagram: caroby2");
                  },
                  padding: const EdgeInsets.only(right: 12),
                  constraints: const BoxConstraints(),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: const Icon(
                    Icons.contact_support,
                    color: color4,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Funcs().showSnackBar(context, "'DOUBLE TAP' to exit");
                  },
                  onDoubleTap: () {
                    Funcs().navigatorPushReplacement(
                        context, const PersonelManagerPage());
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.exit_to_app_rounded,
                      color: color4,
                    ),
                  ),
                ),
              ],
    );
  }
}
