import 'dart:async';

import 'package:arc/appointment/book_appointment_screen.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:arc/provider/appointments_provider.dart';
import 'package:arc/utils/HexColor.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:arc/widgets/app_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentData appointmentData;
  const AppointmentDetailScreen({super.key, required this.appointmentData});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  AppointmentsProvider? provider;
  List<AppointmentData>? appointmentDataList;

  @override
  void initState() {
    provider = Provider.of<AppointmentsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });
    super.initState();
  }


  Future<void> getData() async {
    DateTime mDate = DateTime.now();
    DateTime utcDate = DateTime.utc(mDate.year, mDate.month, mDate.day);
    provider?.getAppointmentList(context, 1, utcDate.millisecondsSinceEpoch.toString());
  }

  void _authListener() {
    if (provider!.isCancelAppointment) {
      Helper.showSnackBar(context: context,
          message: 'Appointment canceled successfully',
          status: Status.success);
      Navigator.pop(context);
    } else {
      //Helper.showSnackBar(context: context, message: Provider.of<AppointmentsProvider>(context, listen: false).message, status: Status.error);
    }
  }

  Future<void> navigateToRescheduleScreen (BuildContext mContext, AppointmentData appointmentData) async {
      var result = await Navigator.push(mContext, MaterialPageRoute(builder: (context) => BookAppointmentScreen(isEdit: true, appointmentData: appointmentData)));
      if (result != null && result) {
        if (kDebugMode) {
          print("result: $result");
        }
        //Navigator.of(mContext).pop();
      }
    }

  @override
  Widget build(BuildContext context) {
    IconData icon; var status = '';
    switch (widget.appointmentData.appointmentStatus) {
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
    return Scaffold(
        backgroundColor: Colors.white,
        //resizeToAvoidBottomInset: false,
        appBar: appBar(context: context, title: 'Appointment Details'),
        body: Container(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
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
                    Text(Helper.convertMillisecondsSinceEpoch(widget.appointmentData.appointmentDate), textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleMedium?.apply(color: HexColor('219653'), fontSizeDelta: 4),),
                    const SizedBox(height: 5),
                    Text('Time Slot: ${Helper.getTimeSlot(widget.appointmentData.bookedFrom!)} - ${Helper.getTimeSlot(widget.appointmentData.bookedTo!)}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: HexColor('112950'), fontSizeDelta: 2),),
                    const SizedBox(height: 5),
                    Text('Service Type: ${widget.appointmentData.serviceType}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: HexColor('112950'), fontSizeDelta: 2),),
                    Text('Branch Name: ${widget.appointmentData.branchId?.name}', textAlign: TextAlign.start, style: Theme.of(context).textTheme.bodyMedium?.apply(color: HexColor('112950'), fontSizeDelta: 2),),
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
              ),
              const SizedBox(height: 50,),
              // Hide Reschedule and Cancel buttons when appointment is cancelled
              if (widget.appointmentData.appointmentStatus != 'cancel') ...[
                InkWell(
                  onTap: () {
                    //Helper.showSnackBar(context: context, message: 'Under Development', status: Status.success);
                    navigateToRescheduleScreen(context, widget.appointmentData);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
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
                    child: Center(child: Text(
                      'Reschedule', textAlign: TextAlign.center, style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.apply(color: white, fontSizeDelta: 4),)),
                  ),
                ),
                const SizedBox(height: 20,),
                InkWell(
                  onTap: () async {
                    if (Helper.getHoursDiffFromNow(appointmentDateMillis: widget.appointmentData.appointmentDate!, bookedFromMinutes: widget.appointmentData.bookedFrom!) < 25) {
                      bool canContinue = await cancellationAppointmentDialog();
                      if (!canContinue) { return; }
                    }
                    _showCustomDialog(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
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
                    child: Center(child: Text(
                      'Cancel Appointment', textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.apply(color: white, fontSizeDelta: 4),)),
                  ),
                ),
              ],
              
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 30.0),
                child: Text(
                  "- Disclaimer - \nAll appointments will be cancelled automatically if you have three consecutive cancellations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ),

            ],
          ),
        ));
  }

  Future<bool> cancellationAppointmentDialog() async {
    final completer = Completer<bool>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Cancellation Policy and Fee',
      desc: "ARC respects your personal right on making appointments. However due to our limited schedule, we exercise a 24 hours cancellation policy , otherwise a \$25 fee will be charged to your account automatically unless it's of urgent causes!",
      padding: const EdgeInsets.fromLTRB(20,0,20,0),
      descTextStyle: const TextStyle(leadingDistribution: TextLeadingDistribution.proportional),
      btnCancelText: "Cancel",
      btnCancelOnPress: () {
        if (!completer.isCompleted) { completer.complete(false); }
      },
      btnOkText: 'Agree',
      btnOkOnPress: () {
        if (!completer.isCompleted) { completer.complete(true); }
      },
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false
    ).show();

    return completer.future;
  }

/*  void _showCustomDialog(BuildContext mContext) {
    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Warning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Do you want to cancel this appointment?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Type your reason here...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ), minimumSize: const Size(130, 20)
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 5,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        provider?.cancelAppointment(mContext, widget.appointmentData.id!);// Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ), minimumSize: const Size(130, 20)
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/

  void _showCustomDialog(BuildContext mContext) {
    String? selectedReason; // Variable to hold the selected reason
    List<String> reasons = [
      "Another app too busy",
      "App made in error	",
      "Covid",
      "Family Emergency",
      "Feels Better",
      "Feels Worse",
      "Financial Issue",
      "Going out of town",
      "Health Issue",
      "PCP/ Referring MD  order to stop Treatment",
      "Sick",
      "Sick Child",
      "Transporation",
      "Weather",
    ];

    showDialog(
      context: mContext,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Warning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Do you want to cancel this appointment?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  hint: const Text(
                    "Select a reason",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  onChanged: (String? newValue) {
                    selectedReason = newValue; // Update the selected reason
                  },
                  items: reasons.map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        minimumSize: const Size(130, 20),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedReason != null) {
                          Navigator.of(context).pop();
                          provider?.cancelAppointment(mContext, widget.appointmentData.id!); // Pass the selected reason
                        } else {
                          // Show a message if no reason is selected
                          ScaffoldMessenger.of(mContext).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a reason.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        minimumSize: const Size(130, 20),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
