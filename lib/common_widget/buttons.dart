import 'package:flutter/material.dart';

///
/// COMMON BUTTON WIDGETS USE IN MAIN SCREEN
///

Widget wChoiceButton(String title, Function()? onPressed, {bool isDisabled=false, bool isAlert=false, double reduceSizeFactor=0, double width=200}){
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: GestureDetector(
        onTap: isDisabled ? null : onPressed,
        child: Container(
            width: width,
            alignment: Alignment.center,
            margin: const EdgeInsets.all(3.0),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white54,
                  width: 1.0,
                )
            ),
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(title, style: TextStyle(color: isDisabled ? Colors.grey : Colors.white),)
        )
    ),
  );
}