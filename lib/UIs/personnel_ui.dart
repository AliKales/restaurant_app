import 'package:flutter/material.dart';
import 'package:restaurant_app/colors.dart';
import 'package:restaurant_app/funcs.dart';
import 'package:restaurant_app/models/personnel.dart';
import 'package:restaurant_app/size.dart';

class PersonnelUI extends StatelessWidget {
  const PersonnelUI(
      {Key? key, required this.personnel, required this.dotsClicked,})
      : super(key: key);
  final Personnel personnel;
  final Function() dotsClicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: personnel.role == "Manager"
            ? color2.withOpacity(0.2)
            : color3.withOpacity(0.2),
        borderRadius: const BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            //textes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //role
                Text(
                  personnel.role,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig().setHight(1),
                ),
                //Name Lastname
                Text(
                  " - ${personnel.name} ${personnel.lastName}",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: color4, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig().setHight(1),
                ),
                //created date
                Text(
                  " - ${Funcs().formatDateTime(DateTime.parse(personnel.createdDate))}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: color4),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            IconButton(
              onPressed: dotsClicked,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: color4,
              ),
            )
          ],
        ),
      ),
    );
  }
}
