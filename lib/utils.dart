import 'package:feedme/main_screen.dart';
import 'package:flutter/material.dart';

///
/// SIMPLE COMMON FUNCTIONS OR UTILITIES
///

showMyDialog(BuildContext context, var screen, {bool isDismissible=true, bool isDisableAnimation=false})async{
  var result = await showDialog(
    barrierDismissible: isDismissible,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.5),
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap: (){
          if(isDismissible) Navigator.of(context).pop();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 35.0),
          alignment: Alignment.center,
          child: Dialog(
              insetPadding: const EdgeInsets.symmetric(vertical: 35.0),
              backgroundColor: Colors.transparent,
              child: screen
          ),
        ),
      );
    },
  );

  return result;
}