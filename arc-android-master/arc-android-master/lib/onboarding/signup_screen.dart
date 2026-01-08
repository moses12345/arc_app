import 'dart:io';
import 'package:arc/provider/login_provider.dart';
import 'package:arc/home_screen.dart';
import 'package:arc/widgets/button.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class SignUpScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  LoginProvider? provider;
  bool _passwordVisible = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool isChecked = false;
  List gender=["Male","Female","Other"];
  String? select;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
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
      Navigator.pop(context, false);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()),);
    } else {
      if(provider?.authMessage?.isNotEmpty == true) {
        Helper.showSnackBar(context: context, message: provider?.authMessage, status: Status.error);
      }
    }
  }

  void checkboxCallBack(bool? checkboxState) {
    setState(() {
      isChecked = checkboxState ?? true;
    });
  }

  Row addRadioButton(int btnValue, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Radio(
          activeColor: Theme.of(context).primaryColor,
          value: gender[btnValue],
          groupValue: select,
          onChanged: (value){
            setState(() {
              if (kDebugMode) {
                print(value);
              }
              select=value;
            });
          },
        ),
        Text(title)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
        body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(padding: const EdgeInsets.only(right: 10), width: double.infinity, child: Image.asset("assets/logo.png", scale: 2.5),),
              const Center(child: Text('ARC Patient Registration', textAlign: TextAlign.center, style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 18,))),
              const SizedBox(
                height: 20,
              ),
              TextField(
                enabled: true,
                obscureText: false,
                controller: _fullNameController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: white,
                  prefixIcon: const Icon(
                    Icons.person,
                    size: 25,
                    color: labelColor,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6.0)),
                  hintText: "Full Name",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: labelColor),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //isDense: true,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(color: Colors.black, fontWeightDelta: 2),
              ),
              const Divider(color: greyColor2, height: 2, thickness: 2,),
              const SizedBox(
                height: 10,
              ),
              TextField(
                enabled: true,
                obscureText: false,
                controller: _emailController,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    //Helper.showSnackBar(context: context, message: "Please input your query.", status: Status.success);
                  } else {
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchJobsScreen(searchQuery: value,)));
                  }
                },
                keyboardType: TextInputType.emailAddress,
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
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: labelColor),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //isDense: true,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(color: Colors.black.withOpacity(.6), fontWeightDelta: 2),
              ),
              const Divider(color: greyColor2, height: 2, thickness: 2,),
              const SizedBox(
                height: 10,
              ),
              TextField(
                enabled: true,
                textInputAction: TextInputAction.done,
                controller: _mobileNumberController,
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    //Helper.showSnackBar(context: context, message: "Please input your query.", status: Status.success);
                  } else {
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => SearchJobsScreen(searchQuery: value,)));
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.call,
                    size: 25,
                    color: labelColor,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6.0)),
                  hintText: "Mobile Number",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: labelColor),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //isDense: true,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(color: Colors.black, fontWeightDelta: 2),
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
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: labelColor),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //isDense: true,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(color: Colors.black, fontWeightDelta: 2),
              ),
              const Divider(color: greyColor2, height: 2, thickness: 2,),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _dobController,
                readOnly: true,
                textInputAction: TextInputAction.done,
                onTap: () {
                  _showDatePicker();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: white,
                  prefixIcon: const Icon(
                    Icons.calendar_month,
                    size: 25,
                    color: labelColor,
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(6.0)),
                  hintText: "Select DOB",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.apply(color: labelColor),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  //isDense: true,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.apply(color: Colors.black, fontWeightDelta: 2),
              ),
              const Divider(color: greyColor2, height: 2, thickness: 2,),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  addRadioButton(0, 'Male'),
                  addRadioButton(1, 'Female'),
                  addRadioButton(2, 'Others'),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(padding: const EdgeInsets.only(right: 10), width: double.infinity, child: Row(
                children: [
                  Checkbox(activeColor: themeColor, value: isChecked, onChanged: checkboxCallBack),
                  Text('Agree with platform Terms & conditions', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.black,))
                ],
              )),
              InkWell(
                onTap: () {
                  if(_fullNameController.text.isEmpty) {
                    Helper.showSnackBar(context: context, message: 'Please enter full name', status: Status.error);
                  } else if(_emailController.text.isEmpty) {
                    Helper.showSnackBar(context: context, message: 'Please enter email id', status: Status.error);
                  } else if(!Helper.isValidEmail(_emailController.text)) {
                    Helper.showSnackBar(context: context, message: 'Please enter a valid email', status: Status.error);
                  } else if(_mobileNumberController.text.isEmpty) {
                    Helper.showSnackBar(context: context, message: 'Please enter mobile number', status: Status.error);
                  } else if(_passwordController.text.isEmpty) {
                    Helper.showSnackBar(context: context, message: 'Please enter a valid password', status: Status.error);
                  }  else if(!Helper.isPasswordValid(_passwordController.text)) {
                    Helper.showSnackBar(context: context, message: 'Password must be at least 6 characters and include a letter, number', status: Status.error);
                  } else if(_dobController.text.isEmpty) {
                    Helper.showSnackBar(context: context, message: 'Please select DOB', status: Status.error);
                  } else if(select?.isEmpty == true) {
                    Helper.showSnackBar(context: context, message: 'Please select gender', status: Status.error);
                  } else if(!isChecked) {
                    Helper.showSnackBar(context: context, message: 'Please check term & condition', status: Status.error);
                  } else {
                    String input = _dobController.text;
                    DateTime parsedDate = DateFormat('MM/dd/yyyy').parse(input);
                    String outputDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                    Map<String, String> body = {
                      "firstName": _fullNameController.text,
                      "phone": _mobileNumberController.text,
                      "email": _emailController.text,
                      "password": _passwordController.text,
                      "sex": select!,
                      "dob": outputDate,
                      "fcmToken":"$fcmToken",
                      "deviceType": Platform.isAndroid ? "1" : "2"
                    };
                    provider?.signup(body, context);
                    //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const HomeScreen()));
                  }
                },
                child: button(context, 'Signup'),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Text.rich(TextSpan(
                      text: 'Already have and account ',
                      style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.black,),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Login',
                            style: Theme.of(context).textTheme.bodyLarge?.apply(color: themeColor, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
                              }),
                      ]),)),
              const SizedBox(
                height: 20,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
                  child: Text.rich(TextSpan(
                      text: 'By signing up, you agree to our ',
                      style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black,),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Terms of Service',
                            style: Theme.of(context).textTheme.bodySmall?.apply(color: themeColor, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //Helper.launchURL(context, "https://indianrojgar.com/terms-conditions");
                                //Helper._(context, Api().baseUrl + 'terms-conditions');
                              }),
                        TextSpan(
                            text: ' and ',
                            style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black,),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Privacy Policy',
                                  style: Theme.of(context).textTheme.bodySmall?.apply(color: themeColor, decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      //Helper.launchURL(context, "https://indianrojgar.com/privacy-policy");
                                    })
                            ])
                      ]),))
            ],
          ),
        )));
  }

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime(1950), //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime.now()
    );
    if(pickedDate != null ) {
      if (kDebugMode) {
        print(pickedDate);
      }  //pickedDate output format => 2021-03-10 00:00:00.000
      //String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
      if (kDebugMode) {
        print(formattedDate);
      } //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement

      setState(() {
        _dobController.text = formattedDate; //set output date to TextField value.
      });
    } else {
      if (kDebugMode) {
        print("Date is not selected");
      }
    }
  }
}
