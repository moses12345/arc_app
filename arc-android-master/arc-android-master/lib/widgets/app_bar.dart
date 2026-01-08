import 'package:arc/utils/colors.dart';
import 'package:flutter/material.dart';

AppBar appBar({required BuildContext context, String? title}){
  return AppBar(
    centerTitle: false,
    elevation: 0,
    title: Text("$title", style: Theme.of(context).textTheme.titleMedium?.apply(color: themeColor, fontSizeDelta: 6)),
    leading: IconButton(
      icon: RotationTransition(
        turns: const AlwaysStoppedAnimation(180 / 360),
        child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
      ),
      onPressed: () => {
        Navigator.pop(context, false)
      },
    ),
    automaticallyImplyLeading: false,
    backgroundColor: Colors.white,
  );
}