import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_sms/flutter_sms.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sas_application/models/firebase_model.dart';
import 'package:sas_application/views/screens/emergency_contact.dart';
import 'package:sms/sms.dart';

class EmergencyContactViewModel extends FireBaseModel {
  final FireBaseModel _fireBaseModel = new FireBaseModel();
  bool? _hasPermission;
  Contact? contact;
  String? emergencyContactName;
  String? emergencyContactDetail;
  List emergencyContactDetails = [];

  Future<void> askPermissions(BuildContext context) async {
    PermissionStatus? permissionStatus;
    while (permissionStatus != PermissionStatus.granted) {
      try {
        permissionStatus = await getContactPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _hasPermission = false;
          handleInvalidPermissions(permissionStatus);
        } else {
          _hasPermission = true;
        }
      } catch (e) {
        if (await showPlatformDialog(
                context: context,
                builder: (context) {
                  return BasicDialogAlert(
                    title: Text('Contact Permissions'),
                    content: Text(
                        'We are having problems retrieving permissions.  Would you like to '
                        'open the app settings to fix?'),
                    actions: [
                      BasicDialogAction(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        title: Text('Close'),
                      ),
                      BasicDialogAction(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        title: Text('Settings'),
                      ),
                    ],
                  );
                }) ==
            true) {
          await openAppSettings();
        }
      }
    }
  }

  Future<PermissionStatus> getContactPermission() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      return result;
    } else {
      return status;
    }
  }

  void handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Access to contacts data denied',
          details: null);
    } else if (permissionStatus == PermissionStatus.restricted) {
      throw PlatformException(
          code: 'PERMISSION_DISABLED',
          message: 'Contacts data is not available on device',
          details: null);
    }
  }

  Future<void> addContactInformation(
      String contactName, String contactNumber) async {
    var uid = _fireBaseModel.auth.currentUser!.uid;
    await _fireBaseModel.firebaseDbService.addEmergencyContact(
        contactName, formatMobileNumber(contactNumber), uid);
  }

  //Function to add +91 if missing or replace 0 with +91.
  String formatMobileNumber(String contactNumber) {
    contactNumber = contactNumber.trim();
    var formattedNumber;
    if (contactNumber.startsWith("+91")) {
      formattedNumber = fomatter(contactNumber);
      return formattedNumber;
    } else if (!contactNumber.startsWith("+91") &&
        !contactNumber.startsWith("+1") &&
        !contactNumber.startsWith("+")) {
      if (contactNumber.startsWith("0")) {
        contactNumber = contactNumber.replaceFirst("0", "+91");
        formattedNumber = fomatter(contactNumber);
        return formattedNumber;
      } else {
        contactNumber = "+91" + contactNumber;
        formattedNumber = fomatter(contactNumber);
        return formattedNumber;
      }
    } else if (contactNumber.startsWith("+1")) {
      formattedNumber = fomatter(contactNumber);
      return formattedNumber;
    } else {
      return contactNumber;
    }
  }

  //Funtion to remove space, - and () from a Phonenumber.
  String fomatter(String number) {
    String newNumber;
    List tokens;
    if (number.contains(" ")) {
      tokens = number.split(" ");
      newNumber = tokens.join();
      if (newNumber.contains("(") && newNumber.contains(")")) {
        tokens = newNumber.split("(");
        newNumber = tokens.join();
        tokens = newNumber.split(")");
        newNumber = tokens.join();
        if (newNumber.contains("-")) {
          tokens = newNumber.split("-");
          newNumber = tokens.join();
        } else {
          return newNumber;
        }
      } else if (newNumber.contains("-")) {
        tokens = newNumber.split("-");
        return tokens.join();
      }
      return newNumber;
    } else if (number.contains("(") &&
        number.contains(")") &&
        !number.contains(" ") &&
        !number.contains("-")) {
      tokens = number.split("(");
      newNumber = tokens.join();
      tokens = newNumber.split(")");
      newNumber = tokens.join();
      return newNumber;
    } else if (number.contains("-") &&
        !number.contains("(") &&
        !number.contains(")") &&
        !number.contains(" ")) {
      tokens = number.split("-");
      newNumber = tokens.join();
      return newNumber;
    } else {
      newNumber = number;
      return newNumber;
    }
  }

  Future<List> getList() async {
    var snapshots = await FirebaseFirestore.instance
        .collection('users')
        .doc(_fireBaseModel.auth.currentUser!.uid)
        .collection("emergency-contacts")
        .get();
    final allData = snapshots.docs.map((doc) => doc.data()).toList();
    print(allData);
    return allData;
  }

  Future<List> getWhoAddedMeList(String myPhoneNumber) async {
    var snapshots = await FirebaseFirestore.instance.collection('users').get();
    final allData = snapshots.docs.map((doc) => doc.data()).toList();
    List whoAddedMe = [];

    for (Map usersMap in allData) {
      var snapShot = await FirebaseFirestore.instance
          .collection("users")
          .doc(usersMap['userId'])
          .collection("emergency-contacts")
          .get();
      final data = snapShot.docs.map((doc) => doc.data()).toList();
      for (Map map in data) {
        if (map["emergency-contact-number"] == myPhoneNumber) {
          whoAddedMe.add({
            'Name': usersMap["full_name"],
            'Phone': usersMap['phone_number'],
            'email': usersMap['e-mail id']
          });
        }
      }
    }
    return whoAddedMe;
  }

  Future<String> getMyNumber() async {
    var snapshots = await FirebaseFirestore.instance
        .collection("users")
        .doc(_fireBaseModel.auth.currentUser!.uid)
        .get();
    var data = snapshots.data();
    if (data!['phone_number'] == null) {
      return data['phone_number'];
    } else {
      var num = fomatter(data['phone_number']);
      return num;
    }
  }

  Future<void> getContactDetails(BuildContext context) async {
    try {
      if (_hasPermission == true) {
        contact = await _fireBaseModel.services.contacts();
      } else {
        if (await showPlatformDialog(
                context: context,
                builder: (context) {
                  return BasicDialogAlert(
                    title: Text('Contact Permissions'),
                    content: Text(
                        'We are having problems retrieving permissions.  Would you like to '
                        'open the app settings to fix?'),
                    actions: [
                      BasicDialogAction(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        title: Text('Close'),
                      ),
                      BasicDialogAction(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        title: Text('Settings'),
                      ),
                    ],
                  );
                }) ==
            true) {
          await openAppSettings();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteData(docId) async {
    await _fireBaseModel.firebaseDbService.instance
        .collection("users")
        .doc(_fireBaseModel.auth.currentUser!.uid)
        .collection("emergency-contacts")
        .doc(docId)
        .delete();
  }

  Future<void> onEmergencyContactAddtion(String phoneNumber) async {
    String address = phoneNumber;
    if (Platform.isAndroid) {
      SmsSender sender = new SmsSender();
      sender.sendSms(new SmsMessage(
          address, "You have been added as an Emergency contact"));
    } else if (Platform.isIOS) {
      try {
        await sendSMS(
            message: "You have been added as an Emergency contact",
            recipients: [phoneNumber]);
      } catch (e) {
        print("Error while sending a message : $e");
      }
    }
  }

  String? validatePhone(phoneValue) {
    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);
    if (phoneValue.isEmpty) {
      return 'Please Enter Phone Number';
    } else if (!regExp.hasMatch(phoneValue)) {
      return 'Please Enter Valid Phone Number';
    }
  }

  String? validateName(nameValue) {
    if (nameValue.isEmpty) {
      return 'Please Enter Your Name';
    } else if (nameValue.length >= 20) {
      return 'Name should be less than 20 Characters';
    }
  }
}
