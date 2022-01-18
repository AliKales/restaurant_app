import 'package:flutter/material.dart';

import '../colors.dart';
import '../size.dart';
import 'custom_gradient_button.dart';
import 'custom_textfield.dart';

class NotePageWidget extends StatelessWidget {
  NotePageWidget({Key? key,required this.note, required this.closeButton}) : super(key: key);
  final String note;
  final Function(String) closeButton;

  TextEditingController tECNote = TextEditingController();
  @override
  Widget build(BuildContext context) {
    tECNote.text=note;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: color1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                  maxLine: null,
                  textEditingController: tECNote,
                  text: "Note",
                  iconData: Icons.note_add),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomGradientButton(
                    context: context,
                    text: "Close",
                    func: () {
                      closeButton.call(tECNote.text);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
