import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_app/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key? key,
      this.textEditingController,
      this.text,
      this.iconData,
      this.function,
      this.keyboardType,
      this.obscureText,
      this.suffixIconFunction,
      this.suffixIcon,
      this.readOnly = false,
      this.inputFormatters,
      this.isOnlyEnglish = false,
      this.colorHint,
      this.isFilled = false,
      this.filledColor,
      this.textStyle, this.prefixText,this.maxLine=1})
      : super(key: key);

  final TextEditingController? textEditingController;
  final String? text;
  final String? prefixText;
  final IconData? iconData;
  final Function()? function;
  final TextInputType? keyboardType;

  final int? maxLine;

  ///* [obscureText] makes the textfield for password input
  ///* default is false
  final bool? obscureText;
  final bool readOnly;
  final bool? isFilled;

  final TextStyle? textStyle;

  final Color? colorHint;
  final Color? filledColor;

  ///* [isOnlyEnglish] default is false
  final bool isOnlyEnglish;

  ///* if [obscureText] is true then you must set [suffixIconFunction]
  final Function()? suffixIconFunction;

  ///* [iconButton] must be null if [obscureText] is active
  final Widget? suffixIcon;

  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      maxLines: maxLine,
      obscureText: obscureText ?? false,
      inputFormatters: isOnlyEnglish
          ? [
              FilteringTextInputFormatter(RegExp(r'^[a-zA-Z0-9_.\-=]+$'),
                  allow: true),
            ]
          : inputFormatters,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: function,
      style: textStyle ??
          Theme.of(context).textTheme.headline6!.copyWith(color: color4),
      cursorColor: colorHint ?? color4,
      controller: textEditingController,
      decoration: InputDecoration(
        prefixText: prefixText,
        filled: isFilled,
        fillColor: filledColor,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: color4),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: color4),
        ),
        prefixIcon: iconData == null
            ? null
            : Icon(
                iconData,
                color: color4,
                size: 30,
              ),
        alignLabelWithHint: true,
        //if obscureText is null then it checks for another iconbutton. If both are null then it returns empty widget
        suffixIcon: obscureText == null
            ? suffixIcon
            : IconButton(
                constraints: const BoxConstraints(),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: suffixIconFunction,
                icon: !obscureText!
                    ? const Icon(
                        Icons.remove_red_eye,
                        color: color4,
                        size: 25,
                      )
                    : const Icon(
                        Icons.remove_red_eye_outlined,
                        color: color4,
                        size: 25,
                      ),
              ),
        hintText: text,
        hintStyle: TextStyle(color: colorHint ?? Colors.white60),
        isDense: true,
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }
}
