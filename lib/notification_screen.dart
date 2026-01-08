import 'package:arc/model/notification_model.dart';
import 'package:arc/provider/notification_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationData>? notificationDataList;
  NotificationProvider? provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<NotificationProvider>(context, listen: false);
    provider?.page = 1;
    PreferenceHelper.getUserProfile().then((profile) {
      provider?.getNotification(context, profile.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    notificationDataList = provider.notificationDataList;
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon:  RotationTransition(
              turns: const AlwaysStoppedAnimation(180 / 360),
              child: Image.asset('assets/right_arrow.png', fit: BoxFit.cover, color: themeColor,),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Notifications', textAlign: TextAlign.center, style: TextStyle(color: themeColor, fontWeight: FontWeight.w600, fontSize: 18,)),
        ),
        body: Container(padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //Text('Notifications', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.apply(color: themeColor, fontSizeDelta: 8)),
                //const SizedBox(height: 10,),
                Expanded(flex: 1, child: RefreshLoadMore(
                    onRefresh:  null,
                    onLoadmore: () async {
                      await Future.delayed(const Duration(seconds: 1), () {
                        //provider.getJobsByCategory(context, categoriesList[selectedPosition].id);
                      });
                    },
                    noMoreWidget: Text(
                      '',
                      style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.black87),
                    ),
                    isLastPage: true,
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: notificationDataList?.length,
                      itemBuilder: (ctx, position) {
                        var notificationData = notificationDataList?[position];
                        return listItem(notificationData!);
                      },
                    )
                ))
              ],
            )
        ));
  }

  Widget listItem(NotificationData notificationData) {
    DateTime parsedDate = DateTime.parse(notificationData.createdDate!).toLocal(); // convert to local time
    // Format it as per your requirement
    String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    return InkWell(
        onTap: () {

        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
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
              Expanded(flex: 9,child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${notificationData.title}', textAlign: TextAlign.start, style: TextStyle(color: HexColor('219653'), fontWeight: FontWeight.w600, fontSize: 18,),),
                  Text(notificationData.content != null ? '${notificationData.content}' : '', textAlign: TextAlign.start, style: TextStyle(color: HexColor('112950'), fontWeight: FontWeight.w600, fontSize: 14,)),
                  Text("Date: $formattedDate", textAlign: TextAlign.start, style: TextStyle(color: HexColor('112950'), fontWeight: FontWeight.w400, fontSize: 12,)),
                ],
              ),),
            ],
          ),
        )
    );
  }
}