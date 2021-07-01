import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:sas_application/models/firebase_model.dart';
import 'package:sas_application/views/screens/home_page.dart';

class LoginViewModel extends FireBaseModel {
  final FireBaseModel _fireBaseModel = new FireBaseModel();

  void printLatest(TextEditingController textEditingController) {}

  Future getFuture() {
    return Future(() async {
      await Future.delayed(Duration(seconds: 5));
      return 'Hello, Future Progress Dialog!';
    });
  }

  //Firebase Authentications
  Future signInWithUserCredentials(
      emailAddress, password, BuildContext context) async {
    try {
      _fireBaseModel.setBusy(true);
      String _email = emailAddress.text;
      String _password = password.text;
      var _authenticatedUser = await _fireBaseModel.auth
          .signInWithEmailAndPassword(_email, _password);
      _fireBaseModel.setBusy(false);
      if (_authenticatedUser!.emailVerified) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (builder) => HomePage()),
            (Route<dynamic> route) => false);
      } else {
        showPlatformDialog(
            context: context,
            builder: (context) {
              return BasicDialogAlert(
                title: Text("Email Verification Issue"),
                content: Text("Email not verified: $_email"),
                actions: [
                  BasicDialogAction(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      title: Text("OK"))
                ],
              );
            });
      }
    } catch (e) {
      showPlatformDialog(
          context: context,
          builder: (context) {
            return BasicDialogAlert(
              title: Text("Login Issue"),
              content: Text(
                  "Login Failure. Please Login Again with correct credentials."),
              actions: [
                BasicDialogAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    title: Text("OK"))
              ],
            );
          });
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      _fireBaseModel.setBusy(true);
      var result = await _fireBaseModel.auth.signInWithGoogle();
      _fireBaseModel.setBusy(false);
      if (result != null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (builder) => HomePage()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Validation Functions of View Model
  String? validateEmail(emailValue) {
    RegExp regex = RegExp(r'\w+@\w+\.\w+');
    if (emailValue.isEmpty) {
      return 'Please Enter Email';
    } else if (!regex.hasMatch(emailValue)) {
      return 'Please Enter a Valid Email';
    } else if (emailValue.length > 30) {
      return 'Email should be less than 30 Characters';
    }
  }

  String? validatePassword(passwordValue) {
    if (passwordValue.isEmpty) {
      return 'Please Enter Password ';
    } else if (passwordValue.length < 6) {
      return 'Password Should be atleast 6 characters long';
    } else if (passwordValue.length > 20) {
      return 'Password Should be less than 20 characters';
    }
  }
}
