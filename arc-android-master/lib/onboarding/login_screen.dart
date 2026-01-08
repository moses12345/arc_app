import 'dart:async';
import 'dart:io';

import 'package:arc/onboarding/forgot_password_screen.dart';
import 'package:arc/home_screen.dart';
import 'package:arc/provider/login_provider.dart';
import 'package:arc/onboarding/signup_screen.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/widgets/button.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool statusOfPasswordWarning = true;
  LoginProvider? provider;
  String? fcmToken= '';

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LoginProvider>(context, listen: false);
    _emailController.addListener(() {
      final text = _emailController.text;
      if (text != text.toLowerCase()) {
        final cursorPos = _emailController.selection;
        _emailController.value = TextEditingValue(
          text: text.toLowerCase(),
          selection: cursorPos,
        );
      }
    });

    // _emailController.text = "sandiacupt@hotmail.com";
    // _passwordController.text = "acupt921";
    // _emailController.text = "vansh@gmailc.com";
    // _passwordController.text = "Arc@2025";
    // _emailController.text = "anupam@yopmail.com";
    // _passwordController.text = "Anupam1!";
    // _emailController.text = "coolstack@gmail.com";
    // _passwordController.text = "123456a";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PreferenceHelper.getPasswordWarning().then((value) => {
      if(value) {
          Timer(const Duration(seconds: 1), () {
          showPasswordWarningDialog();
      })}
      });
    });

    Future<String?> getDeviceToken() async => await FirebaseMessaging.instance.getToken();
    getDeviceToken().then((value) => {
      fcmToken = value!,
      if (kDebugMode) {
        print('FCM Token: $value')
      }
    });
  }

  void _authListener() {
    if (provider?.isAuthenticated == true) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()),);
    } else {
      if(provider?.authMessage?.isNotEmpty == true) {
        Helper.showSnackBar(context: context, message: provider?.authMessage, status: Status.error);
      }
    }
  }


  showPasswordWarningDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Info',
      desc: 'Are you existing patient?\n\nPress the forgot password button to setup your password',
      //btnCancelText: 'No',
      btnOkText: 'Ok',
      //btnCancelOnPress: () {},
      btnOkOnPress: () {
        PreferenceHelper.setPasswordWarning(false);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar:  BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
              child: Text.rich(TextSpan(
                  text: 'By login up, you agree to our ',
                  style: const TextStyle(color: black, fontWeight: FontWeight.w400, fontSize: 12),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(color: themeColor, fontWeight: FontWeight.w400, fontSize: 12, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            //Helper.launchURL(context, "https://indianrojgar.com/terms-conditions");
                            //Helper._(context, Api().baseUrl + 'terms-conditions');
                          }),
                    TextSpan(
                        text: ' and ',
                        style: const TextStyle(color: black, fontWeight: FontWeight.w400, fontSize: 12),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(color: themeColor, fontWeight: FontWeight.w400, fontSize: 12, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  //Helper.launchURL(context, "https://indianrojgar.com/privacy-policy");
                                })
                        ])
                  ]),)),
        ),
        body: SingleChildScrollView(padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
          child: Stack(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(padding: const EdgeInsets.only(right: 10), width: double.infinity, child: Image.asset("assets/logo.png", scale: 2.5),),
                  const Center(child: Text('ARC Patient Login', textAlign: TextAlign.center, style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 18,)),),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    enabled: true,
                    obscureText: false,
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        //Helper.showSnackBar(context: context, message: "Please input your query.", status: Status.success);
                      } else {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchJobsScreen(searchQuery: value,)));
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: white,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 25,
                        color: labelColor,
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(6.0)),
                      hintText: "Email Id",
                      hintStyle: const TextStyle(color: labelColor, fontWeight: FontWeight.w500, fontSize: 14,),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      //isDense: true,
                    ),
                    style: const TextStyle(color: black, fontWeight: FontWeight.w500, fontSize: 14,),
                  ),
                  const Divider(color: greyColor2, height: 2, thickness: 2,),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    enabled: true,
                    obscureText: !_passwordVisible,
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        //Helper.showSnackBar(context: context, message: "Please input your query.", status: Status.success);
                      } else {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchJobsScreen(searchQuery: value,)));
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: white,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 25,
                        color: labelColor,
                      ),
                      suffixIcon: IconButton(icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off), color: labelColor,
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(6.0)),
                      hintText: "Enter Your Password",
                      hintStyle: const TextStyle(color: labelColor, fontWeight: FontWeight.w500, fontSize: 14,),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      //isDense: true,
                    ),
                    style: const TextStyle(color: black, fontWeight: FontWeight.w500, fontSize: 14,),
                  ),
                  const Divider(color: greyColor2, height: 2, thickness: 2,),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(alignment: Alignment.centerRight,  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const ForgotPasswordScreen()));
                    },
                    child: const Text('Forgot Password?', textAlign: TextAlign.start, style: TextStyle(color: themeColor, fontWeight: FontWeight.w500, fontSize: 14,)),
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                     if(_emailController.text.isEmpty) {
                       Helper.showSnackBar(context: context, message: 'Please enter email id', status: Status.error);
                     } else if(!Helper.isValidEmail(_emailController.text)) {
                       Helper.showSnackBar(context: context, message: 'Please enter a valid email', status: Status.error);
                     } else if(_passwordController.text.isEmpty) {
                       Helper.showSnackBar(context: context, message: 'Please enter a valid password', status: Status.error);
                     }  else {
                       Map<String, String> body = {
                         "email": _emailController.text,
                         "password": _passwordController.text,
                         "fcmToken": "$fcmToken",
                         "deviceType": Platform.isAndroid ? "1" : "2"
                       };
                       Provider.of<LoginProvider>(context, listen: false).login(body, context);
                       //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
                     }
                    },
                    child: button(context, 'Login'),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 5, right: 20, top: 20),
                      child: Text.rich(TextSpan(
                          text: 'Don\'t have an account ',
                          style: const TextStyle(color: black, fontWeight: FontWeight.w400, fontSize: 14,),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Signup',
                                style: const TextStyle(color: themeColor, fontWeight: FontWeight.w400, fontSize: 16, decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const SignUpScreen()));
                                  }),
                          ]),)),
                ],
              ),
            ],
          ),
    ));
  }
}
