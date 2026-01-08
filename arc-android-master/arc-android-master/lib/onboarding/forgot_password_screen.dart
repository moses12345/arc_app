import 'package:arc/onboarding/reset_password_screen.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/login_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  LoginProvider? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<LoginProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });
  }

  void _authListener() {
    var baseModel = provider?.baseModelForgot;
    if (baseModel?.code == 200) {
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResetPasswordScreen(email: _emailController.text,)));
      provider?.clearMessage();
    } else if (baseModel?.code == 400){
      Helper.showSnackBar(context: context, message: baseModel?.message, status: Status.error);
      provider?.clearMessage();
    }
  }

  @override
  void dispose() {
    provider?.removeListener(_authListener);
    super.dispose();
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
        ),
        body: Container(padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Forgot Password', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 22,)),
                const SizedBox(height: 10,),
                const Text('Enter the email address associated with your account to receive an OTP.', textAlign: TextAlign.start, style: TextStyle(color: greyColor, fontWeight: FontWeight.w400, fontSize: 14,)),
                const SizedBox(height: 20,),
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
                const SizedBox(height: 50,),
                InkWell(
                  onTap: () {
                    if(_emailController.text.isEmpty) {
                      Helper.showSnackBar(context: context, message: 'Please enter email id', status: Status.error);
                    } else if(!Helper.isValidEmail(_emailController.text)) {
                      Helper.showSnackBar(context: context, message: 'Please enter a valid email', status: Status.error);
                    } else {
                      Map<String, String> body = {
                        "email": _emailController.text,
                      };
                      provider?.forgotPassword(body, context);
                      //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const ResetPasswordScreen()));
                    }
                  },
                  child: button("Submit"),
                ),
              ],
            )
        ));
  }

  Widget button(String title) {
    return Container(
      //padding: const EdgeInsets.all(12),
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
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
      child: Center(child: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.apply(color: white, fontSizeDelta: 4),)),
    );
  }
}