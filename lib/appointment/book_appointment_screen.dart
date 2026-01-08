import 'dart:async';

import 'package:arc/home_screen.dart';
import 'package:arc/model/appointment_model.dart';
import 'package:arc/model/branch_model.dart';
import 'package:arc/model/time_slots_model.dart';
import 'package:arc/model/user_model.dart';
import 'package:arc/provider/appointments_provider.dart';
import 'package:arc/model/active_claims_model.dart';
import 'package:arc/utils/notification_services.dart';
import 'package:arc/utils/preference_helper.dart';
import 'package:arc/widgets/app_bar.dart';
import 'package:arc/widgets/button.dart';
import 'package:arc/utils/colors.dart';
import 'package:arc/utils/enums.dart';
import 'package:arc/utils/helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'appointment_detail_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final bool isEdit;
  final AppointmentData? appointmentData;
  const BookAppointmentScreen({super.key, required this.isEdit, required this.appointmentData});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController _serviceDateController = TextEditingController();

  List<TimeSlotsData>? timeSlotsList;
  List<BranchData>? branchList;
  List<String>? serviceList = ["PT", "ACU", "PT/ACU"];
  AppointmentsProvider? provider;

  DateTime selectTime = DateTime.now();
  BranchData? selectedBranch;
  int? selectedTimeSlotIndex;
  int? utcTimestampInMilliseconds;
  late String selectedDate;
  bool _isDialogOpen = false; // Track if dialog is open
  String? selectedService;

  //Adding default to EST if there is no case of purpose for now
  String visitPurpose = "EST";
  bool cancelClickedDuringOnboarding = false;

  List<Claim> selectedClaims = [];

  @override
  void initState() {
    initializeDateFormatting('en', '').then((value) => null);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider?.addListener(_authListener);
    });

    provider = Provider.of<AppointmentsProvider>(context, listen: false);
    if(provider!.branchDataList.isEmpty) {
      provider?.getBranchList(1, context);
    }
    provider?.fetchActiveClaims(context);

    if(widget.isEdit) {
      if (kDebugMode) {
        print("ABC Date: ${Helper.convertMillisecondsSinceEpoch(widget.appointmentData?.appointmentDate)}");
        print("converted Date: ${Helper.convertDate(Helper.convertMillisecondsSinceEpoch(widget.appointmentData?.appointmentDate))}");
      }

      setState(() {
        if(widget.appointmentData?.branchId?.id != null) {
          var mSelectedBranch = provider?.branchDataList.where((e) => e.id == widget.appointmentData?.branchId?.id).first;
          selectedBranch = mSelectedBranch;
        }

        selectedService = widget.appointmentData?.serviceType;
        _serviceDateController.text = Helper.convertMillisecondsSinceEpoch(widget.appointmentData?.appointmentDate);
        selectedDate = Helper.convertDate(Helper.convertMillisecondsSinceEpoch(widget.appointmentData?.appointmentDate));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getTimeSlots();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    provider?.removeListener(_authListener);
    super.dispose();
  }

  /// Called by parent (e.g. HomeScreen) when this screen becomes visible via tab switch.
  /// Use this to refresh data or perform UI work that should occur each time the tab is selected.
  Future<void> onTabVisible() async {
    if (kDebugMode) {
      print('BookAppointmentScreen: onTabVisible called');
    }
    // Refresh active claims via provider (centralized)
    if (provider?.activeClaimData == null) {
      await provider?.fetchActiveClaims(context);
    } else {
      provider?.fetchActiveClaims(context);
    }

    if (!widget.isEdit && provider?.activeClaimData != null) {
      appointmentBookingOnboarding(true);
    }
  }

  Future<bool> appointmentBookingOnboarding(showCloseBtn) async {
    bool showNewToArc = provider?.activeClaimData?.showNewToARCsPopup ?? false;
    bool showBookCondition = provider?.activeClaimData?.showConditionPopup ?? false;

    if (showNewToArc) {
      final result = await showDialogForOldNewUser(showCloseBtn);
      return result;
    } else if (showBookCondition) {
      final result = await showDialogForBookingConditions(showCloseBtn);
      return result;
    }

    return true;
  }

  Future<bool> showDialogForOldNewUser(showCloseBtn) async {
    final completer = Completer<bool>();
    UserData userData = await PreferenceHelper.getUserProfile();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Hi ${userData.fullName}',
      desc: 'No match record found. Are you new to ARC Acupuncture & Physical Therapy?',
      btnCancelText: 'No',
      btnCancelColor: themeColor,
      btnCancelOnPress: () {},
      btnOkText: 'Yes',
      btnOkColor: themeColor,
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      showCloseIcon: showCloseBtn,
      onDismissCallback: (dismissType) async {
        switch (dismissType) {
        case DismissType.btnOk:
          visitPurpose = "NP";
          completer.complete(true);
          break;
        case DismissType.btnCancel:
          final result = await showDialogForBookingConditions(showCloseBtn);
          completer.complete(result);
          break;
        default: //Remaining all cancel Actions
          cancelClickedDuringOnboarding = true;
          completer.complete(false);
          break;
        }
      }
    ).show();

    return completer.future;
  }

  Future<bool> showDialogForBookingConditions(showCloseBtn) async {
    final completer = Completer<bool>();
    UserData userData = await PreferenceHelper.getUserProfile();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Hi ${userData.fullName}',
      desc: 'Welcome Back! Are you scheduling an appointment for same previous condition or a new condition?',
      btnCancelText: 'Same Condition',
      btnCancelColor: themeColor,
      btnCancelOnPress: () {},
      btnOkText: 'New Condition',
      btnOkColor: themeColor,
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      showCloseIcon: showCloseBtn,
      onDismissCallback: (dismissType) {
        switch (dismissType) {
          case DismissType.btnOk:
            visitPurpose = "OPNC";
            completer.complete(true);
            break;
          case DismissType.btnCancel:
            visitPurpose = "OPSC";
            completer.complete(true);
            break;
          default: //Remaining all cancel Actions
            cancelClickedDuringOnboarding = true;
            completer.complete(false);
            break;
        }
      }
    ).show();

    return completer.future;
  }

  Future<bool> shouldProceedWithWarningAndErrorDialogVisibility() async {

    final List<String> allErrors = selectedClaims.expand((claim) {
      final service = claim.serviceType?.toUpperCase() ?? '';
      final ctId = claim.ctId ?? '';
      return (claim.errors ?? const <String>[]).map((error) => '$service [$ctId] \n\n$error',);
    }).toList();
    if (allErrors.isNotEmpty) {

      for (final error in allErrors) {
        final shouldContinue = await showErrorDialogForSelectedClaims(error);
        if (!shouldContinue) {
          return false;
        }
      }
      return false;
    }

    final List<String> allWarnings = selectedClaims.expand((claim) {
      final service = claim.serviceType?.toUpperCase() ?? '';
      final ctId = claim.ctId ?? '';
      return (claim.warnings ?? const <String>[]).map((error) => '$service [$ctId] \n\n$error',);
    }).toList();
    if (allWarnings.isNotEmpty) {
      for (final warning in allWarnings) {
        final shouldContinue = await showWarningDialogForSelectedClaims(warning);
        if (!shouldContinue) {
          return false;
        }
      }
    }
    return true;
  }

  Future<bool> showWarningDialogForSelectedClaims(message) async {
    final completer = Completer<bool>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Warning',
      desc: message,
      btnCancelText: 'Cancel',
      btnOkText: 'Continue',
      btnCancelOnPress: () {
        if (!completer.isCompleted) { completer.complete(false); }
      },
      btnOkOnPress: () {
        if (!completer.isCompleted) { completer.complete(true); }
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();

    return completer.future;
  }

  Future<bool> showErrorDialogForSelectedClaims(message) async {
    final completer = Completer<bool>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: message,
      btnCancelText: 'Cancel',
      btnOkText: 'OK',
      btnCancelOnPress: () {
        if (!completer.isCompleted) { completer.complete(false); }
      },
      btnOkOnPress: () {
        if (!completer.isCompleted) { completer.complete(true); }
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();

    return completer.future;
  }

  Future<void> _showClaimsMultiSelectDialog() async {

    var claimList = provider?.activeClaimData?.claims ?? [];

    if (selectedService != null && selectedService!.isNotEmpty && selectedService != "PT/ACU") {
      final currService = selectedService!.toLowerCase();
      claimList = claimList.where((c) {
        final s = (c.serviceType ?? '').toLowerCase();
        return s == currService;
      }).toList();
    }

    if (claimList.isEmpty) {
      if (selectedService == null || selectedService!.isEmpty) {
        Helper.showSnackBar(context: context, message: 'No claims available', status: Status.error);
      } else {
        Helper.showSnackBar(context: context, message: 'No claims available for selected service', status: Status.error);
      }
      return;
    }

    // Compare whole Claim objects (== overridden in model to compare ctId/serviceType)
    List<Claim> tempSelected = List<Claim>.from(selectedClaims);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Claims'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: claimList.length,
                  itemBuilder: (context, index) {
                    final c = claimList[index];
                    final ctId = c.ctId ?? '';
                    final service = c.serviceType?.toUpperCase() ?? '';
                    return CheckboxListTile(
                      value: tempSelected.contains(c),
                      title: Text('$service [$ctId]'),
                      subtitle: null,
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            if (!tempSelected.contains(c)) tempSelected.add(c);
                          } else {
                            tempSelected.remove(c);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  setState(() {
                    selectedClaims = tempSelected;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Done')),
          ],
        );
      },
    );
  }

  void _authListener() {
    if(provider?.message != null) {
      Helper.showSnackBar(context: context, message: provider?.message, status: Status.error);
    }

    if(provider!.isBookedAppointment) {
      var appointmentData = AppointmentData(appointmentDate: utcTimestampInMilliseconds, bookedFrom: timeSlotsList?[selectedTimeSlotIndex!].from, bookedTo: timeSlotsList?[selectedTimeSlotIndex!].to);
      NotificationServices.sendScheduledNotification(appointmentData: appointmentData,
        title: "Your appointment scheduled",
        body: "Time Slot: ${Helper.getTimeSlot(appointmentData.bookedFrom!)} - ${Helper.getTimeSlot(appointmentData.bookedTo!)}",
        payload: "Test payload",
      );
      bookingSlotConfirmationDialog();
    }
    if (provider!.isAppointmentAlreadyBooked && !_isDialogOpen) {
      // Avoid showing the dialog twice
      _isDialogOpen = true;

      Map<String, dynamic>? data = provider!.alreadyBookedData;
      final rawData = data?['data'];
      final appointment = rawData is Map<String, dynamic> ? rawData['exsitingAppointmentData'] : null;

      if (rawData is Map<String, dynamic> && appointment is Map<String, dynamic>) {
        AppointmentData appointmentData = AppointmentData.fromJson(appointment);
        alreadyBookedSlotConfirmationDialog(provider!.alreadyBookedMessage!, appointmentData).then((_) {
          _isDialogOpen = false; // Reset flag when dialog is closed
        });
      } else {
        showErrorDialogForSelectedClaims(provider!.alreadyBookedMessage!).then((_) {
          _isDialogOpen = false;
        });
      }
    }
  }

  bookingSlotConfirmationDialog() async {
    UserData userData = await PreferenceHelper.getUserProfile();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Success',
      desc: 'Hi ${userData.fullName}, \n\nYou have schedule appointment on: ${_serviceDateController.text}',
      //btnCancelText: 'No',
      btnOkText: 'Ok',
      //btnCancelOnPress: () {},
      btnOkOnPress: () {
        setState(() {
          provider?.timeSlotDataList = [];
          _serviceDateController.text = '';
          timeSlotsList = [];
          selectedTimeSlotIndex=null;
          selectedClaims = [];
        });
        if(widget.isEdit) {
          Navigator.pop(context);
          Navigator.of(context).pop(true);
        } else {
          BottomNavigationBar navigationBar =  HomeScreen.bottomNavigatorKey.currentWidget as BottomNavigationBar;
          navigationBar.onTap!(0);
        }
      },
    ).show();
  }

  Future<void> alreadyBookedSlotConfirmationDialog(String message, AppointmentData appointmentData) async {
    UserData userData = await PreferenceHelper.getUserProfile();
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Warning',
      desc: 'Hi ${userData.fullName}, \n\n$message',
      btnCancelText: 'Reschedule',
      btnCancelOnPress: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointmentData: appointmentData)));
      },
      btnOkText: 'Cancel',
      btnOkOnPress: () {},
    ).show();
  }

  Color getColor(int index, TimeSlotsData timeSlotData) {
      if(timeSlotData.booked! < timeSlotData.maxBooked!) {
        if(index == selectedTimeSlotIndex) {
          return themeColor;
        } else {
          return Colors.white;
        }
      } else {
        return greyColor;
      }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentsProvider>(context);
    branchList = provider.branchDataList;
    timeSlotsList = provider.timeSlotDataList.where((slot) =>
                      (slot.booked ?? 0) < (slot.maxBooked ?? 0))
                      .toList();

    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: widget.isEdit ? appBar(context: context, title: 'Book Appointment'): PreferredSize(preferredSize: Size.zero, child: Container()),
        body: Container(padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(widget.isEdit ?'Reschedule Appointment' : 'Schedule Appointment', textAlign: TextAlign.center, style:  const TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 14,)),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<BranchData>(
                        isExpanded: true,
                        hint: Row(
                          children: [
                            const Icon(
                              Icons.list,
                              size: 25,
                              color: themeColor,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Select Clinic',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.apply(color: themeColor, fontSizeDelta: 2),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: branchList?.map((BranchData item) => DropdownMenuItem<BranchData>(
                          value: item,
                          child: Text('${item.name}',
                            style: Theme.of(context).textTheme.titleMedium?.apply(color: themeColor, fontSizeDelta: 2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                            .toList(),
                        value: selectedBranch,
                        onChanged: (BranchData? value) {
                          setState(() {
                            selectedBranch = value;
                          });
                          getTimeSlots();
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 55,
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: themeColor),
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              //colors: [violet, violet],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [Colors.white, Colors.white],
                            ),
                          ),
                          //elevation: 2,
                        ),
                        iconStyleData: IconStyleData(
                          icon: Image.asset(
                            color: themeColor,
                            'assets/right_arrow.png',
                            width: 25,
                            height: 25,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.yellow,
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: 350,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                            color: Colors.white,
                          ),
                          offset: const Offset(20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all<double>(6),
                            thumbVisibility:
                            WidgetStateProperty.all<bool>(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40,
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Row(
                      children: [
                        const Icon(
                          Icons.list,
                          size: 25,
                          color: themeColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Select Service Type',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.apply(color: themeColor, fontSizeDelta: 2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: serviceList?.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.apply(color: themeColor, fontSizeDelta: 2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    value: selectedService,
                    onChanged: (String? value) {
                      setState(() {
                        if (selectedService != value) {
                          selectedClaims = [];
                        }
                        selectedService = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 55,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeColor),
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [Colors.white, Colors.white],
                        ),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Image.asset(
                        'assets/right_arrow.png',
                        color: themeColor,
                        width: 25,
                        height: 25,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Colors.yellow,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: 350,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.white,
                      ),
                      offset: const Offset(20, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: WidgetStateProperty.all<double>(6),
                        thumbVisibility: WidgetStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                  ),
                ),
              ),
                  const SizedBox(
                    height: 12,
                  ),

                  // Claims multi-select dropdown (shows ctId values)
                  Center(
                    child: GestureDetector(
                      onTap: () => _showClaimsMultiSelectDialog(),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: themeColor),
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [Colors.white, Colors.white],
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.list, size: 25, color: themeColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedClaims.isEmpty ? 'Select Claims' : selectedClaims.map((c) => c.serviceType?.toUpperCase() ?? '').where((s) => s.isNotEmpty).join(', '),
                                style: Theme.of(context).textTheme.titleMedium?.apply(color: themeColor, fontSizeDelta: 2),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: themeColor),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _serviceDateController,
                    onTap: () {
                      _showDatePicker();
                    },
                    readOnly: true,
                    style: const TextStyle(color: themeColor),
                    decoration: InputDecoration(
                      hintText: 'Service Date',
                      suffixIcon: const Icon(
                        Icons.calendar_month,
                        color: themeColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(width: 1,color: themeColor),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Choose Available Time', textAlign: TextAlign.center, style: TextStyle(color: black, fontWeight: FontWeight.w600, fontSize: 14,)),
                  const SizedBox(
                    height: 10,
                  ),
                  timeSlotsList!.isEmpty? Text('Please choose clinic name and service date to view available time slots.', style: Theme.of(context).textTheme.titleSmall?.apply(color: Colors.grey, fontSizeDelta: 1)): GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 50,
                    ),
                    itemBuilder: (_, index) => InkWell(onTap: () {
                      setState(() {
                        if(timeSlotsList![index].booked! < timeSlotsList![index].maxBooked!) {
                          selectedTimeSlotIndex = index;
                        }
                      });
                    }, child: Container(decoration: BoxDecoration(
                      border: Border.all(color: themeColor, width: 1.5),
                      color: getColor(index, timeSlotsList![index]),
                      borderRadius: BorderRadius.circular(8),
                    ), child: Center(child: Text('${Helper.getTimeSlot(timeSlotsList![index].from!)}-${Helper.getTimeSlot(timeSlotsList![index].to!)}', style: Theme.of(context).textTheme.titleSmall?.apply(color: index == selectedTimeSlotIndex ? Colors.white : themeColor, fontSizeDelta: .5)))),),
                    itemCount: timeSlotsList?.length,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      if (selectedBranch == null) {
                        Helper.showSnackBar(context: context, message: 'Please select clinic', status: Status.error);
                      } else if (selectedService == null) {
                        Helper.showSnackBar(context: context, message: 'Please select service type', status: Status.error);
                      } else if(selectedDate.isEmpty) {
                        Helper.showSnackBar(context: context, message: 'Please select date to get time slots', status: Status.error);
                      } else {
                        if (cancelClickedDuringOnboarding) {
                          await appointmentBookingOnboarding(false);
                        }
                        final canProceed = await shouldProceedWithWarningAndErrorDialogVisibility();
                        if (!canProceed) {
                          Map<String, dynamic> body = {"claims" : selectedClaims.map((c) => c.toJson()).toList() };
                          provider.logUnfinishedAppointment(context, body);
                          return;
                        }

                        if(widget.isEdit) {
                          Map<String, dynamic> body = {
                            "bookedFrom": "${timeSlotsList?[selectedTimeSlotIndex!].from}",
                            "bookedTo": "${timeSlotsList?[selectedTimeSlotIndex!].to}",
                            "branchId": "${selectedBranch?.id!}",
                            "appointmentDate": utcTimestampInMilliseconds,
                            "serviceType": selectedService,
                            "appointmentId": "${widget.appointmentData?.id}",
                          };
                          Provider.of<AppointmentsProvider>(context, listen: false).rescheduleAppointment(context, body);
                        } else {
                          Map<String, dynamic> body = {
                            "bookedFrom": "${timeSlotsList?[selectedTimeSlotIndex!].from}",
                            "bookedTo": "${timeSlotsList?[selectedTimeSlotIndex!].to}",
                            "branchId": "${selectedBranch?.id!}",
                            "serviceType": selectedService,
                            "appointmentDate": utcTimestampInMilliseconds,
                            "purpose" : visitPurpose,
                            "claims" : selectedClaims.map((c) => c.toJson()).toList(),
                          };
                          Provider.of<AppointmentsProvider>(context, listen: false).bookAppointment(context, body);
                        }
                      }
                    },
                    child: button(context, widget.isEdit ? 'Reschedule' : 'Schedule'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                ],
              ),
            )
        ));
  }

  void getTimeSlots() {
    if (selectedBranch == null) {
      Helper.showSnackBar(context: context, message: 'Please select branch to get time slots', status: Status.error);
    } else if(selectedDate.isEmpty) {
      Helper.showSnackBar(context: context, message: 'Please select date to get time slots', status: Status.error);
    } else {
      var date = int.parse(selectedDate.split('-')[0]);
      var month = int.parse(selectedDate.split('-')[1]);
      var year = int.parse(selectedDate.split('-')[2]);
      DateTime utcDate = DateTime.utc(date, month, year);
      utcTimestampInMilliseconds = utcDate.millisecondsSinceEpoch;
      if (kDebugMode) {
        print(utcTimestampInMilliseconds);
      }
      provider?.getBranchesSlot(context, utcTimestampInMilliseconds, selectedBranch?.id);
    }
  }

  Future<void> _showDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context, initialDate: DateTime.now(),
        firstDate: DateTime.now(), //- not to allow to choose before today.
        lastDate: DateTime(2101)
    );
    if(pickedDate != null ){
      if (kDebugMode) {
        //print(pickedDate);
      }  //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      if (kDebugMode) {
        print(formattedDate);
      } //formatted date output using intl package =>  2021-03-16
      //you can implement different kind of Date Format here according to your requirement
      String formattedDateForView = DateFormat('EEEE, MMMM d, yyyy').format(pickedDate);
      setState(() {
        selectedDate = formattedDate;
        _serviceDateController.text = formattedDateForView; //set output date to TextField value.
      });
      getTimeSlots();
    } else {
      if (kDebugMode) {
        print("Date is not selected");
      }
    }
  }
}
