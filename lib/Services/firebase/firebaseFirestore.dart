import 'dart:async';

import 'package:chatgo/Authentication/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../Screens/otherScreens/profile.dart';

class FireStoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final userDocs = FirebaseFirestore.instance.collection('users');

  // CREATE user document
  Future createUserDocument(
    String userName,
    UserCredential? userCredential,
    String password,
      String userNameForQuery
  ) async {
    if (UserCredential != null && UserCredential != null) {
      await fireStore.collection('users').doc(userCredential?.user!.email).set({
        'User Name': userName,
        'userNameForQuery': userNameForQuery,
        'Email': userCredential?.user!.email,
        'Password': password,
        'Bio': '~',
        'Date of Birth': '---',
        'Gender': '---',
        'Occupation': '---',
        'Location': '---',
        'Profile Picture': null,
        'isOnline':false,
        'lastSeen':Timestamp.now(),
        'mobileNo': '---'
      });
    }
  }

  //READ
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUSerDocument(
      User? currentUser)  {
    return  userDocs.doc(currentUser!.email).snapshots();
  }

  Future updateUserDocument(
    Map<String, dynamic> mapUpdate,
    User? currentUser,
    BuildContext context,
  ) async {
    Navigator.pop(context);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(
        child: AlertDialog(
            content: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
              Text('updating...'),
              CircularProgressIndicator(
              strokeWidth: 3,
            )
          ],
        )),
      ),
    );
    Timer.periodic(const Duration(seconds: 1), (timer) {
      Navigator.pop(context);
      timer.cancel();
    });
    await userDocs.doc(currentUser!.email).update(mapUpdate);
  }

  void updateGenderDocs(User? currentUser, String gender) async {
    await userDocs.doc(currentUser!.email).update({'Gender': gender});
  }

  //Update Date of Birth
  void updateDOBDocs(User? currentUser, String dob) async {
    await userDocs.doc(currentUser!.email).update({'Date of Birth': dob});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDocumentAfterEdit(
      User? currentUser) {
    return userDocs.doc(currentUser!.email).snapshots();
  }

  Future signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    _auth.signOut();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

// Send User to contact
  Future addToContact(
      {required String currentUser,
      required String contact}) async {
      await fireStore.collection("User's Contacts").doc(currentUser).collection('contacts')
          .doc(contact).set(
          {
            //'User Name': userName,
            'Email': contact,
            'time': DateTime.now(),
            'profilePhoto':{
              'localPath': '',
              'lastUpdated': ''
            }
          }
      );
  }
  // Future addToActiveContact(
  //     {User? currentUser,
  //       required String userName,
  //       required String email,
  //       required String? profilePic,
  //       required String contact}) async {
  //   await fireStore.collection("User's Contacts").doc(currentUser!.email).collection('active contacts')
  //       .doc(contact).set(
  //       {
  //         'User Name': userName,
  //         'Email': email,
  //         'Profile Picture': profilePic
  //       }
  //   );
  // }

  Widget awaitDataDisplay (AsyncSnapshot snapshot, Widget widget,){
    if (snapshot.connectionState == ConnectionState.waiting){
     return const Center(child: CircularProgressIndicator(),);
    }else if (snapshot.hasError){
      return Center(child: Text(snapshot.error.toString()),);
    }else if (snapshot.hasData){
      return widget;

    }else {return const Center(child: Text('No data'));}
  }
}
