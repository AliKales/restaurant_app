import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/custom_textfield.dart';

import '../size.dart';
import 'custom_gradient_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    Key? key,
    required this.tECUsername,
    required this.tECPassword,
    required this.context,
    required this.progress1,
    this.function,
  }) : super(key: key);

  final TextEditingController tECUsername;
  final TextEditingController tECPassword;
  final BuildContext context;
  final bool progress1;
  final Function()? function;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 20,
          ),
          //username
          CustomTextField(
              textEditingController: tECUsername,
              text: "Staff Username",
              iconData: Icons.person),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 3,
          ),
          //password
          CustomTextField(
            textEditingController: tECPassword,
            text: "Staff Password",
            iconData: Icons.lock_outline,
          ),
          SizedBox(
            height: SizeConfig.safeBlockVertical! * 6,
          ),
          // Log in
          CustomGradientButton(
            context: context,
            text: "LOG IN",
            loading: progress1,
            func: () {
              function!.call();
            },
          )
        ],
      ),
    );
  }
}
