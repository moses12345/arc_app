import 'package:arc/provider/login_provider.dart';
import 'package:arc/widgets/button.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});


  @override
  State<ChangePasswordScreen> createState() => _ScreenState();
}

class _ScreenState extends State<ChangePasswordScreen> {
  LoginProvider? provider;

  bool _oldPasswordVisible = false;
  bool _passwordVisible = false;
  bool _cPasswordVisible = false;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LoginProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });
  }

  @override
  void dispose() {
    provider?.removeListener(_authListener);
    super.dispose();
  }

  void _authListener() {
    var baseModel = provider?.baseModelChange;
    if (baseModel?.code == 200) {
      Helper.showSnackBar(context: context, message: "Password changed successfully", status: Status.success);
      provider?.clearMessage();
      Navigator.pop(context);
    } else if (baseModel?.code == 400){
      Helper.showSnackBar(context: context, message: baseModel?.message, status: Status.error);
      provider?.clearMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Container(padding: const EdgeInsets.only(right: 10), width: double.infinity, child: Image.asset("assets/logo.png", scale: 1.8,),),
                const Text('Change password', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 22,)),
                const Text('Enter your old & new password to reset', textAlign: TextAlign.start, style: TextStyle(color: greyColor, fontWeight: FontWeight.w400, fontSize: 14,)),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  enabled: true,
                  obscureText: !_oldPasswordVisible,
                  textInputAction: TextInputAction.next,
                  controller: _oldPasswordController,
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
                    suffixIcon: IconButton(icon: Icon(_oldPasswordVisible ? Icons.visibility : Icons.visibility_off), color: labelColor,
                      onPressed: () {
                        setState(() {
                          _oldPasswordVisible = !_oldPasswordVisible;
                        });
                      },),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(6.0)),
                    hintText: "Old Password",
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
                  height: 20,
                ),
                TextField(
                  enabled: true,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.next,
                  controller: _passwordController,
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
                    hintText: "New Password",
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
                  height: 20,
                ),
                TextField(
                  enabled: true,
                  obscureText: !_cPasswordVisible,
                  textInputAction: TextInputAction.done,
                  controller: _cPasswordController,
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
                    suffixIcon: IconButton(icon: Icon(_cPasswordVisible ? Icons.visibility : Icons.visibility_off), color: labelColor,
                      onPressed: () {
                        setState(() {
                          _cPasswordVisible = !_cPasswordVisible;
                        });
                      },),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(6.0)),
                    hintText: "Confirm New Password",
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
                  height: 40,
                ),
                InkWell(child: button(context, 'Save'), onTap: (){
                  var oldPassword = _oldPasswordController.text;
                  var password = _passwordController.text;
                  var cPassword = _cPasswordController.text;
                  if(oldPassword.isEmpty) {
                    Helper.showSnackBar(context: context, message: "Enter you old password", status: Status.error);
                  } else if(password.isEmpty) {
                    Helper.showSnackBar(context: context, message: "Enter new password", status: Status.error);
                  } else if(!Helper.isPasswordValid(password)) {
                    Helper.showSnackBar(context: context, message: "Please enter valid password", status: Status.error);
                  } else if(password.isEmpty) {
                    Helper.showSnackBar(context: context, message: "Enter your confirm new password", status: Status.error);
                  } else if(password != cPassword) {
                    Helper.showSnackBar(context: context, message: "Use same password to reset", status: Status.error);
                  } else {
                    Map<String, String> body = {
                      "oldPassword": oldPassword,
                      "newPassword": password,
                      "confirmPassword": cPassword,
                    };
                    provider?.changePassword(body, context);
                  }
                },)
              ],
            ),
          ),
        ));
  }
}