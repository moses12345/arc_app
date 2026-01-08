import 'dart:core';
import 'package:arc/appointment/appointment_detail_screen.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:arc/provider/appointments_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/widgets/refresh_load_more.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AppointmentsProvider? provider;
  List<AppointmentData>? appointmentDataList;
  String? utcTimestampInMilliseconds;

  @override
  void initState() {
    DateTime baseDate = DateTime.now();
    final newDate = DateTime(baseDate.year, baseDate.month, baseDate.day,);
    utcTimestampInMilliseconds = newDate.millisecondsSinceEpoch.toString();
    if (kDebugMode) {
      print(utcTimestampInMilliseconds);
    }
    provider = Provider.of<AppointmentsProvider>(context, listen: false);
    getData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });
    super.initState();
  }

  void _authListener() {
    if(provider!.isRefreshList) {
      getData();
    }
  }

  Future<void> getData() async {
    provider?.getAppointmentList(context, 1, utcTimestampInMilliseconds!);
  }

  Future<void> navigateToDetailScreen(AppointmentData appointmentData) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointmentData: appointmentData)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentsProvider>(context);
    appointmentDataList = provider.appointmentDataList;
    return Scaffold(
        backgroundColor: Colors.white,
        //resizeToAvoidBottomInset: false,
        body: Container(padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child:  appointmentDataList!.isEmpty ? const Center(child: Text('No appointment scheduled', textAlign: TextAlign.start, style: TextStyle(color: black, fontWeight: FontWeight.w400, fontSize: 14,),)):
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Next upcoming appointments', textAlign: TextAlign.center, style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 14,)),
              const SizedBox(height: 5,),
              Expanded(child: RefreshLoadMore(
                  onRefresh:  () async {
                    await Future.delayed(const Duration(seconds: 2), () {
                      getData();
                    });
                  },
                  onLoadmore: () async {
                    await Future.delayed(const Duration(seconds: 1), () {
                      getData();
                    });
                  },
                  noMoreWidget: Text(
                    '',
                    style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.black87),
                  ),
                  isLastPage: true,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: appointmentDataList?.length,
                    itemBuilder: (ctx, position) {
                      var appointmentData = appointmentDataList?[position];

                      IconData icon; var status = '';

                      switch (appointmentData!.appointmentStatus) {
                        case 'approved':
                          icon = Icons.check_circle;
                          status = 'Appointment Confirmed';
                        case 'pending':
                          icon = Icons.pending;
                          status = 'Appointment is pending for approval';
                        default:
                          icon = Icons.cancel;
                          status = 'Appointment Cancelled';
                      }

                      return InkWell(
                          onTap: () {
                            //if (appointmentData.appointmentStatus != 'cancel') {
                              navigateToDetailScreen(appointmentData);
                            //}
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(Helper.convertMillisecondsSinceEpoch(appointmentData.appointmentDate), textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                                const SizedBox(height: 5),
                                Text('Time Slot: ${Helper.getTimeSlot(appointmentData.bookedFrom!)} - ${Helper.getTimeSlot(appointmentData.bookedTo!)}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: HexColor('112950'), fontSizeDelta: 2),),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(icon, color: themeColor, size: 25,),
                                    const SizedBox(width: 5,),
                                    Text(status, softWrap: true, style: Theme.of(context).textTheme.bodyMedium?.apply(color: Colors.black, fontSizeDelta: 2),),
                                  ],
                                )
                              ],
                            ),
                          )
                      );
                    },
                  )
              ))
            ],
          )
        ));
  }
}
