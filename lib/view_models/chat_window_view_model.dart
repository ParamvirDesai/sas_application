import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sas_application/models/firebase_model.dart';

class ChatWindowViewModel extends FireBaseModel {
  final FireBaseModel _fireBaseModel = new FireBaseModel();

  getEmergencyContactName() async {
    var data = await _fireBaseModel.firebaseDbService.instance
        .collectionGroup("emergencyContacts")
        .where("userId", isEqualTo: _fireBaseModel.auth.currentUser!.uid)
        .get();
    return data.docs.map((e) => e.data()).toList();
  }

  Future<List> getWhoAddedMeList() async {
    var userPhone = await _fireBaseModel.firebaseDbService.instance
        .collection("users")
        .doc(_fireBaseModel.auth.currentUser!.uid)
        .get(GetOptions(source: Source.cache));

    var snapshots = await _fireBaseModel.firebaseDbService.instance
        .collectionGroup("emergencyContacts")
        .where("emergencyContactNumber", isEqualTo: userPhone['phone_number'])
        .get();

    final allData = snapshots.docs.map((doc) => doc.data()).toList();
    List whoAddedMe = [];
    for (Map map in allData) {
      var snapshot = await _fireBaseModel.firebaseDbService.instance
          .collection("users")
          .doc(map['userId'])
          .get();
      var userData = snapshot.data();
      whoAddedMe.add({
        'Name': userData!["full_name"],
        'Phone': userData['phone_number'],
        'userId': userData['userId']
      });
    }
    return whoAddedMe;
  }

  Future<List> getUsers() async {
    List users = [];

    var dataShots = await FirebaseFirestore.instance
        .collection("users")
        .doc(_fireBaseModel.auth.currentUser!.uid)
        .collection("emergencyContacts")
        .get(GetOptions(source: Source.cache));

    var data = dataShots.docs;
    for (var map in data) {
      users.add({
        "emergencyContactName": map['emergencyContactName'],
        "emergencyContactNumber": map['emergencyContactNumber'],
        "userId": map['emergencyContactUserId'],
        "color": map['emergencyContactUserId'] == ""
            ? Colors.redAccent
            : Colors.grey,
        "color2":
            map['emergencyContactUserId'] == "" ? Colors.grey : Colors.green,
        "color3": Colors.grey
      });
    }

    var whoAddedMeList = await getWhoAddedMeList();

    whoAddedMeList.forEach((element) {
      var userDetails = users.where((x) => x['userId'] == element['userId']);
      var userId;
      if (userDetails.isNotEmpty) {
        userDetails.single['color3'] = Colors.orangeAccent;
        userId = userDetails.single["userId"];
      }
      var userIdMatch = userId.toString().contains(element['userId']);
      if (!userIdMatch) {
        users.add({
          "emergencyContactName": element['Name'],
          "emergencyContactNumber": element['Phone'],
          "userId": element['userId'],
          "color": element['emergencyContactUserId'] == ""
              ? Colors.redAccent
              : Colors.grey,
          "color2": element['emergencyContactUserId'] == ""
              ? Colors.grey
              : Colors.green,
          "color3": Colors.orangeAccent
        });
      }
    });

    return users;
  }
}
