import 'dart:async';
import 'dart:convert';
import 'package:arc/ChatScreen.dart';
import 'package:arc/appointment/book_appointment_screen.dart';
import 'package:arc/appointment/dashboard_screen.dart';
import 'package:arc/exercise_screen.dart';
import 'package:arc/faq_screen.dart';
import 'package:arc/info_lib_screen.dart';
import 'package:arc/model/news_letter_model.dart';
import 'package:arc/model/video_call_model.dart';
import 'package:arc/news_letter_screen.dart';
import 'package:arc/notification_screen.dart';
import 'package:arc/provider/appointments_provider.dart';
import 'package:arc/provider/video_call_provider.dart';
import 'package:arc/setting_screen.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/notification_services.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/video_call_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:arc/provider/login_provider.dart';

import 'main.dart';
import 'model/branch_model.dart';
import 'network/FirebaseService.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/main-screen';
  static var bottomNavigatorKey = GlobalKey<State<BottomNavigationBar>>();
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BranchData? selectedBranch;
  VideoCallProvider? provider;
  final String _deviceId = "";
  var cTime;
  int selectedIndex = 0;
  var uuid = const Uuid();
  String? fullName = "";
  String? userID = "";
  String channelName = "";

  // Key to access BookAppointmentScreen state so we can notify it when the tab is selected
  final GlobalKey _bookAppointmentKey = GlobalKey();

  void changePage(int page) {
    setState(() {
      selectedIndex = page;
    });
    if (kDebugMode) {
      print("object $selectedIndex");
    }
  }

  @override
  void initState() {
    super.initState();

    provider = Provider.of<VideoCallProvider>(context, listen: false);

    PreferenceHelper.getUserProfile().then((userData) {
      setState(() {
        fullName = userData.fullName;
        userID = userData.id;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });

    checkCall();

    Future<String?> getDeviceToken() async => await FirebaseMessaging.instance.getToken();
    getDeviceToken().then((value) {
      if (value != null) {
        Map<String, String> body = {
          "fcmToken" : value
        };
        Provider.of<LoginProvider>(context, listen: false).updateFCMToken(body, context);
      }
    });
  }

  Future<void> checkCall() async {
    final persistedModel = await PreferenceHelper.getPendingCallModel();
    if (persistedModel != null && persistedModel.channelName != null && persistedModel.channelName!.isNotEmpty) {
      // Check if same call is already open
      if (FirebaseService.isSameCallAlreadyOpen(persistedModel)) {
        if (kDebugMode) {
          print("HomeScreen: Same call already open, skipping navigation");
        }
        // Clear pending call model since screen is already open with this call
        await PreferenceHelper.clearPendingCallModel();
        return;
      }
      
      if (kDebugMode) {
        print("HomeScreen: Loaded persisted pending call model from SharedPreferences");
        print("HomeScreen: Channel: ${persistedModel.channelName}, Token: ${persistedModel.token}");
      }
      
      // Set current open call model before navigation
      FirebaseService.setCurrentOpenCallModel(persistedModel);
      
      FirebaseService.pendingCallModel = null;
      await PreferenceHelper.clearPendingCallModel();
      if (!mounted) {
        FirebaseService.setCurrentOpenCallModel(null);
        return;
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VideoCallScreen(videoCallModel: persistedModel)));
    }
  }

  void _authListener() {
    if (provider!.isLoading == false && provider?.data != null) {
      VideoCallModel? data = provider?.data;
      //data?.channelName = selectedBranch?.id;
      data?.channelName = channelName;
      data?.branchId = selectedBranch?.id;
      data?.branchName = selectedBranch?.name;
      data?.userId = userID;
      data?.userName = "ARCs Healthcare";
      //data?.token = '007eJxTYPhqaHUh7LdQ/vRAi+dnbGa83Rtoe142UktJv+G5SqhZrr0Cg3GSRZqBkXFycqKRkYmxhWGScVpairGhuaFFWpKFZZLx4v186Q2BjAzvN75hZmSAQBCfnSGxKFm3PDWJgQEAcnAgFA==';
      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => VideoCallScreen(videoCallModel: data!,)));
    }
  }

  Future<bool> _onBackPressed() {
    if(selectedIndex == 0) {
      DateTime now = DateTime.now();
      if (cTime == null || now.difference(cTime) > const Duration(seconds: 2)) {
        cTime = now;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press Back Button Again to Exit')));
        return Future.value(false);
      }

      return Future.value(true);
    } else {
      setState(() {
        selectedIndex = 0;
      });
      //notifier?.changePage(0);
      return Future.value(false);
    }
  }

  void showBottomSheetWithList(BuildContext context, List<BranchData> branchDataList, Function(BranchData) onItemSelected) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Branch',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: branchDataList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.list),
                      title: Text(branchDataList[index].name!),
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(branchDataList[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentsProvider>(context);
    var branchList = appointmentProvider.branchDataList;
    return WillPopScope(onWillPop: _onBackPressed, child: Scaffold(
      appBar: buildAppBar(context, selectedIndex),
      floatingActionButton: Transform.scale(scale: .8, child:
        Column(mainAxisSize: MainAxisSize.min, children:
            [
              FloatingActionButton.extended(
                heroTag: 'chat_button',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
                },
                label: Text('Chat', style: Theme.of(context).textTheme.labelLarge?.apply(color: Colors.white, fontSizeDelta: 1)),
                icon: const Icon(Icons.chat, color: Colors.white,),
                backgroundColor: themeColor,
              ),
              const SizedBox(height: 12),

              FloatingActionButton.extended(
                heroTag: 'call_button',
                onPressed: () {
                  showBottomSheetWithList(context, branchList, (selectedItem) {
                    setState(() {
                      selectedBranch = selectedItem;
                    });
                    final String customId = "call_${DateTime.now().millisecondsSinceEpoch}";
                    channelName = "${selectedItem.id}_${DateTime.now().millisecondsSinceEpoch}";

                    Map<String, String> body = {
                      /*"uid": '$uId',
                      "branch": "${selectedItem.id}",
                      "channelName": "${selectedItem.name}_Anurag",
                      "deviceId": "1234567Aa@",*/
                      "deviceId": "1234567Aa@",
                      'id': customId,
                      'branch': selectedItem.name!,
                      'branchId': selectedItem.id!,
                      'callerName': fullName!,
                      'callId': customId,
                      'outgoing': 'true',
                      'type': 'audio',
                      'timestamp': "${DateTime.now().millisecondsSinceEpoch}",
                      'status': 'pending',
                      //"channelName": "${selectedItem.name}-$userID}",
                      //"channelName": "${selectedItem.id}",
                      "channelName": channelName,
                      "callerId": '$userID',
                      "device_type": "APP",
                    };

                    provider?.initiateVideoCall(context, body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Your selected branch is: ${selectedItem.name}'),
                      ),
                    );
                  });

                },
                label: Text('Call', style: Theme.of(context).textTheme.labelLarge?.apply(color: Colors.white, fontSizeDelta: 1)),
                icon: const Icon(Icons.call, color: Colors.white,),
                backgroundColor: themeColor,
              ),
            ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Offstage(
            offstage: selectedIndex != 0,
            child:  const DashboardScreen(),
          ),
          Offstage(
            offstage: selectedIndex != 1,
            child: BookAppointmentScreen(key: _bookAppointmentKey, isEdit: false, appointmentData: null),
          ),
          Offstage(
            offstage: selectedIndex != 2,
            child: const ExerciseScreen(),
          ),
          Offstage(
            offstage: selectedIndex != 3,
            child: const InfoLibScreen(),
          ),
          Offstage(
            offstage: selectedIndex != 4,
            child: const NewsLetterScreen(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: HomeScreen.bottomNavigatorKey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension_rounded),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: 'Info Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News Letter',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: themeColor,
        selectedIconTheme: const IconThemeData(color: themeColor, size: 25),
        selectedLabelStyle: const TextStyle(color: themeColor, fontWeight: FontWeight.w400, fontSize: 12,),
        unselectedLabelStyle: const TextStyle(color: bottomBarUnselected, fontWeight: FontWeight.w400, fontSize: 12,),
        unselectedIconTheme: const IconThemeData(color: bottomBarUnselected, size: 25),
        unselectedItemColor: bottomBarUnselected,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
            if (selectedIndex == 1) {
              // Notify BookAppointmentScreen that it became visible.
              // Use addPostFrameCallback to ensure the child visibility state is updated.
              notifyBookAppointmentScreen();
            }
          });
        },
      ),
    ));
  }

  void notifyBookAppointmentScreen() {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final state = _bookAppointmentKey.currentState;
        if (state != null) {
          // dynamic call since state class is private
          (state as dynamic).onTabVisible();
        }
      } catch (e) {
        if (kDebugMode) print('Error calling onTabVisible: $e');
      }
    });

  }

  AppBar buildAppBar(BuildContext context, int tabIndex) {
    return AppBar(
      toolbarHeight: 80,
      centerTitle: false,
      elevation: 0,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hi, $fullName",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme.titleMedium
                ?.apply(color: themeColor, fontSizeDelta: 8),
          ),
          Text('Acupunture & Physical Therepy Specialists Inc', style: Theme.of(context).textTheme.titleSmall?.apply(color: themeColor, fontSizeDelta: .2),),
        ],
      ),
      automaticallyImplyLeading: false,
      actions:  [
        // InkWell(
        //   onTap: () {
        //     //Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        //     Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
        //   },
        //   child: const Icon(Icons.chat_bubble_outline, size: 28,),
        // ),
        // const SizedBox(width: 10,),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
          },
          child: const Icon(Icons.notifications_none, size: 30,),
        ),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingScreen()));
          },
          child: const Icon(Icons.more_vert, size: 30,),
        ),
      ],
      //backgroundColor: themeColor,
    );
  }
}
