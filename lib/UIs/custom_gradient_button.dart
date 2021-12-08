import 'package:flutter/material.dart';
import 'package:restaurant_app/UIs/simple_uis.dart';
import 'package:restaurant_app/colors.dart';

class CustomGradientButton extends StatelessWidget {
  const CustomGradientButton({
    Key? key,
    required this.context,
    this.func,
    this.text,
    this.loading,
    this.isOutlined,
    this.color,
    this.radius = 6,
    this.icon,
  }) : super(key: key);

  final BuildContext context;
  final Function()? func;
  final String? text;
  final bool? loading;
  final bool? isOutlined;

  /// * [color] must be giving same as background color when isOutlened is true
  final Color? color;
  final double? radius;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    if (loading == null || loading == false) {
      if (isOutlined == null || isOutlined == false) {
        return InkWell(
          onTap: func ?? () {},
          child: Container(
            padding: icon == null
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [color2, color3],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
                borderRadius: BorderRadius.all(Radius.circular(radius!))),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Row(
                children: [
                  icon == null ? const SizedBox.shrink() : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: icon!,
                  ),
                  Text(
                    text ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: color4),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return InkWell(
          onTap: func ?? () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [color2, color3],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Container(
              decoration: BoxDecoration(
                color: color ?? color1,
                borderRadius: BorderRadius.all(Radius.circular(radius!)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 11),
              child: Text(
                text ?? "",
                style:
                    Theme.of(context).textTheme.button!.copyWith(color: color4),
              ),
            ),
          ),
        );
      }
    } else {
      return SimpleUIs().progressIndicator();
    }
  }
}
