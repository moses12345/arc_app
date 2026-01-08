import 'package:arc/info_lib_screen.dart';
import 'package:arc/news_letter_screen.dart';
import 'package:arc/onboarding/change_password_screen.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'onboarding/login_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _emailController = TextEditingController();

  String arcID = '';

  @override
  void initState() {
    super.initState();

    PreferenceHelper.getUserProfile().then((userData) {
      setState(() {
        arcID = userData.arcsId ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Settings', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 18,)),
        ),
        body: Container(padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Text('Settings', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.apply(color: themeColor, fontSizeDelta: 8)),
                      Column(
                        children: [
                          /*InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const NewsLetterScreen()));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: HexColor('E4E2F3')),
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight, colors: [HexColor('F2F6FE'), HexColor('F2F6FE')],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset('assets/newspaper.png', width: 35, height: 35, color: themeColor,),
                                    const SizedBox(width: 10,),
                                    Expanded(flex: 9,child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('News Letter', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                                      ],
                                    ),),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 10,),
                          InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const InfoLibScreen()));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: HexColor('E4E2F3')),
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight, colors: [HexColor('F2F6FE'), HexColor('F2F6FE')],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset('assets/info_lib.png', width: 35, height: 35, color: themeColor,),
                                    const SizedBox(width: 10,),
                                    Expanded(flex: 9,child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Information Lib', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                                      ],
                                    ),),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 10,),*/
                          InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) =>  const ChangePasswordScreen()));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: HexColor('E4E2F3')),
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight, colors: [HexColor('F2F6FE'), HexColor('F2F6FE')],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_open, color: themeColor, size: 35,),
                                    const SizedBox(width: 10,),
                                    Expanded(flex: 9,child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Change Password', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                                      ],
                                    ),),
                                  ],
                                ),
                              )
                          ),
                          const SizedBox(height: 10,),
                          InkWell(
                              onTap: () {
                                _showAlertDialog(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 5),
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: HexColor('E4E2F3')),
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight, colors: [HexColor('F2F6FE'), HexColor('F2F6FE')],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout, color: themeColor, size: 35,),
                                    const SizedBox(width: 10,),
                                    Expanded(flex: 9,child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Logout', textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                                      ],
                                    ),),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text('ARC ID: $arcID', style: const TextStyle(color: Colors.grey, fontSize: 14),),
                  ),
                ),
              ],
            ),
        ));
  }

  void _showAlertDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Logout',
      desc: "Are you sure you want to logout?",
      btnCancelText: "Cancel",
      btnCancelOnPress: () {},
      btnOkText: "Logout",
      btnOkOnPress: () {
        PreferenceHelper.clearPreference();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
      },
    ).show();
  }
}