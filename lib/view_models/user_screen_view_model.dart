import 'dart:async';
import 'package:sas_application/models/firebase_model.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_otp/flutter_otp.dart';
import 'package:sas_application/views/screens/log_in.dart';

class UserScreenViewModel extends FireBaseModel {
  final FireBaseModel _fireBaseModel = new FireBaseModel();

  Future<void> signOutAnonymously(BuildContext context) async {
    try {
      await _fireBaseModel.auth.signOut();
    } catch (e) {
      print(e.toString());
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (builder) => LoginPage()),
        (Route<dynamic> route) => false);
  }

  String? validateName(nameValue) {
    if (nameValue.isEmpty) {
      return 'Please Enter Your Name';
    } else if (nameValue.length >= 20) {
      return 'Name should be less than 20 Characters';
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

  String? validateEContact(phoneValue) {
    const pattern = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(phoneValue)) {
      return 'Please Enter Valid Phone Number';
    }
  }

  String? validateGender(gender) {
    if (gender.isEmpty) {
      return 'Please Enter Your Gender';
    }
  }

  String? validateAge(age) {
    if (age.isEmpty) {
      return 'Please Enter Your Age';
    } else if (int.parse(age) < 12 || int.parse(age) > 80) {
      return 'Enter valid age';
    }
  }
}
