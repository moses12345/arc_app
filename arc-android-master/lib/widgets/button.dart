import 'package:flutter/material.dart';

import '../utils/colors.dart';

Widget button(BuildContext context, String title) {
  return Container(
    //padding: const EdgeInsets.all(12),
    width: double.infinity,
    height: 45,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 3.0,
          spreadRadius: 0.0,
          offset: Offset(1.0, 1.0),
        )
      ],
      gradient: const LinearGradient(
        colors: [themeColor, themeColor],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    ),
    child: Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18,))),
  );
}