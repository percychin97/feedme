import 'package:flutter/material.dart';

///
/// COMMON SCREEN WIDGETS USE IN MAIN SCREEN LIKE POP UP ETC
///

Widget wPopup({required Widget child, double? height}){
  return Container(
      height: height ?? 150.0,
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: child
  );
}