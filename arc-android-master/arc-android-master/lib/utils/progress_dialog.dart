import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'colors.dart';

String _dialogMessage = "Loading...";
enum ProgressDialogType { normal, download }

ProgressDialogType _progressDialogType = ProgressDialogType.normal;
double _progress = 0.0;

bool _isShowing = false;

class ProgressDialog {
  late _MyDialog _dialog;
  late BuildContext _buildContext, _context;

  ProgressDialog(BuildContext buildContext, ProgressDialogType progressDialogType) {
    _buildContext = buildContext;
    _progressDialogType = progressDialogType;
  }

  void setMessage(String mess) {
    _dialogMessage = mess;
    debugPrint("ProgressDialog message changed: $mess");
  }

  void update({required double progress, required String message}) {
    debugPrint("ProgressDialog message changed: ");
    if (_progressDialogType == ProgressDialogType.download) {
      debugPrint("Old Progress: $_progress, New Progress: $progress");
      _progress = progress;
    }
    debugPrint("Old message: $_dialogMessage, New Message: $message");
    _dialogMessage = message;
    _dialog.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void hide() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(_context).pop();
      debugPrint('ProgressDialog dismissed');
    }
  }

  void show() {
    if (!_isShowing) {
      _dialog = _MyDialog();
      _isShowing = true;
      debugPrint('ProgressDialog shown');
      showDialog<dynamic>(
        context: _buildContext,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 130),
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: const Duration(milliseconds: 100),
              elevation: 10.0,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: _dialog);
        },
      );
    }
  }
}

// ignore: must_be_immutable
class _MyDialog extends StatefulWidget {
  final _dialog = _MyDialogState();

  update() {
    _dialog.changeState();
  }

  @override
  // ignore: must_be_immutable
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _MyDialogState extends State<_MyDialog> {
  changeState() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _isShowing = false;
    debugPrint('ProgressDialog dismissed by back button');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12.0),),),
      child: Column(
          children: <Widget>[
            Container(
              height: 80,
              alignment: Alignment.center,
              child: LoadingAnimationWidget.discreteCircle(color: themeColor, size: 35,),
            ),
            Text('Please wait...', style: Theme.of(context).textTheme.titleSmall?.apply(color: themeColor,)),
            const SizedBox(height: 5.0),
          ]),
    );
  }
}

class MessageBox {
  BuildContext buildContext;
  String message = " ", title = " ";

  MessageBox(this.buildContext, this.message, this.title);

  void show() {
    _showDialog();
  }

  Future? _showDialog() {
    showDialog(
      context: buildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
          content: SizedBox(
            height: 45.0,
            child: Center(
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
            ),
          ),
        );
      },
    );
    return null;
  }
}