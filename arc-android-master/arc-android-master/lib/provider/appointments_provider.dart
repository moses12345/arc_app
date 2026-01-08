import 'package:arc/model/appointment_model.dart';
import 'package:arc/model/branch_model.dart';
import 'package:arc/model/time_slots_model.dart';
import 'package:arc/model/active_claims_model.dart';
import 'package:arc/network/api.dart';
import 'package:flutter/material.dart';

class AppointmentsProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _message;
  String? get message => _message;
  List<AppointmentData> appointmentDataList = [];
  List<BranchData> branchDataList = [];
  List<TimeSlotsData> timeSlotDataList = [];
  int limit = 20;

  bool _isCancelAppointment = false;
  bool get isCancelAppointment => _isCancelAppointment;

  bool _isBookedAppointment = false;
  bool get isBookedAppointment => _isBookedAppointment;

  bool _isAppointmentAlreadyBooked = false;
  bool get isAppointmentAlreadyBooked => _isAppointmentAlreadyBooked;

  bool _isRefreshList = false;
  bool get isRefreshList => _isRefreshList;

  String? _alreadyBookedMessage;
  String? get alreadyBookedMessage => _alreadyBookedMessage;

  Map<String, dynamic>? _alreadyBookedData;
  Map<String, dynamic>? get alreadyBookedData => _alreadyBookedData;

  ActiveClaimsData? activeClaimData;

  Future<void> getAppointmentList(context, page, String appointmentDate) async {

    Api().getAppointmentList(appointmentDate, "$page", "$limit", context).then((value) async => {
      // _queryInProgress = false,
      if(value.code == 200) {
        _isLoading = true,
        if(value.data == null || value.data!.isEmpty) {
        } else {
          if(page == 1) {
            appointmentDataList = value.data!
          } else {
            appointmentDataList.addAll(value.data!),
          },
          notifyListeners(),
          if (value.data!.length >= limit) {
            getAppointmentList(context, page+1, appointmentDate)
          }
        },
        _isLoading = false,
        notifyListeners(),
      } else {
        _isLoading = false,
        notifyListeners(),
      }
    });
  }

  Future<void> getBranchList(page, context) async {
    Api().getBranchList("$page", "$limit", context).then((value) async => {
      if(value.code == 200) {
        if(value.data == null || value.data!.isEmpty) {
        } else {
          if (page == 1) {
            branchDataList = value.data!,
          } else {
            branchDataList += value.data!,
          },
          notifyListeners(),
          if (value.data!.length >= limit) {
            getBranchList(page+1, context)
          }
        },
      } else {
        notifyListeners(),
      }

    });
  }

  Future<void> getBranchesSlot(context, bookingDate, branchId) async {
    Api().getBranchesSlot("$bookingDate", "$branchId", context).then((value) async => {
      if(value.code == 200) {
        if(value.data == null || value.data!.isEmpty) {
          _message = "Slots not available",
          timeSlotDataList.clear(),
        } else {
          _message = null,
          timeSlotDataList.clear(),
          timeSlotDataList = value.data!,
        },
        notifyListeners(),
      } else {
        notifyListeners(),
      }
    });
  }

  Future<void> fetchActiveClaims(context) async {
    Api().getActiveClaims(context).then((value) async => {
      if(value.code == 200) {
        activeClaimData = value.data,
        _isRefreshList = true,
        notifyListeners(),
        _isRefreshList = false,
      } else if(value.code == 400) {
        notifyListeners()
      } else {
        //print("object ${value.message}"),
        notifyListeners(),
      }
    });
  }

  Future<void> logUnfinishedAppointment(context, Map<String, dynamic> body) async {
    Api().logUnfinishedAppointments(body, context).then((value) async => {
      if(value.code == 200) {
      } else if(value.code == 400) {
      } else {
      },
      notifyListeners(),
    });
  }

  Future<void> bookAppointment(context, Map<String, dynamic> body,) async {
    Api().bookAppointment(body, context).then((value) async => {
      if(value.code == 200) {
        _isBookedAppointment = true,
        _isRefreshList = true,
        notifyListeners(),
        _isBookedAppointment = false,
        _isRefreshList = false,
      } else if(value.code == 400) {
        _alreadyBookedMessage = value.message,
        _alreadyBookedData = value.response,
        _isAppointmentAlreadyBooked = true,
        notifyListeners(),
        _isAppointmentAlreadyBooked = false,
        _alreadyBookedMessage = "",
      } else {
        //print("object ${value.message}"),
        _isBookedAppointment = false,
        notifyListeners(),
      }
    });
  }

  Future<void> rescheduleAppointment(context, Map<String, dynamic> body,) async {
    Api().rescheduleAppointment(body, context).then((value) async => {
      if(value.code == 200) {
        _isBookedAppointment = true,
        _isRefreshList = true,
        notifyListeners(),
        _isBookedAppointment = false,
        _isRefreshList = false,
      }  else if(value.code == 400) {
        _alreadyBookedMessage = value.message,
        _alreadyBookedData = value.response,
        _isAppointmentAlreadyBooked = true,
        notifyListeners(),
        _isAppointmentAlreadyBooked = false,
        _alreadyBookedMessage = "",
      } else {
        _isBookedAppointment = false,
        notifyListeners(),
      }
    });
  }

  Future<void> cancelAppointment(context, String appointmentId,) async {
    Api().cancelAppointment(appointmentId, context).then((value) async => {
      if(value.code == 200) {
        _isCancelAppointment = true,
        _isRefreshList = true,
        notifyListeners(),
        _isCancelAppointment = false,
        _isRefreshList = false,
      } else {
        _isCancelAppointment = false,
        notifyListeners(),
      }
    });
  }
}