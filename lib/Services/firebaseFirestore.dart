import 'dart:async';

import 'package:chatgo/Authentication/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../Screens/otherScreens/profile.dart';

class FireStoreService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final  userDocs = FirebaseFirestore.instance.collection('users');

  // CREATE
  Future createUserDocument (String userName,UserCredential? userCredential,String password,) async {
    if(UserCredential!=null && UserCredential!=null){
      await fireStore.collection('users').doc(userCredential?.user!.email).set({
        'User Name':userName,
        'Email':userCredential?.user!.email,
        'Password':password,
        'Bio':'~',
        'Date of Birth':'Pick your date of birth',
        'Gender':'---',
        'Occupation': '---',
        'Location': '---'
      }
      );
    }
  }
  //READ
  Future <DocumentSnapshot<Map<String, dynamic>>> getUSerDocument (User? currentUser) async {

    return await userDocs.doc(currentUser!.email).get();
  }

  Future  updateUserDocument (String userNameController,String bio,String occupation,String location, User? currentUser,BuildContext context,)async{
    Navigator.pop(context);
    showDialog(barrierDismissible: false,
       context: context,
       builder: (context) => const Center(
         child: AlertDialog(
             content:
             Row(
               mainAxisAlignment:MainAxisAlignment.spaceBetween,
               children: [
                 Text('updating...'),
                 CircularProgressIndicator(strokeWidth: 3,)
               ],)
         ),
       ),);
     Timer.periodic(const Duration(seconds:1), (timer) {
       Navigator.pop(context);
       timer.cancel();
     });
     if(userNameController.isNotEmpty){
       await userDocs.doc(currentUser!.email).update({
         'User Name': userNameController,
       });
     }else if (bio.isNotEmpty) {
       await userDocs.doc(currentUser!.email).update({
         'Bio': '~ $bio',
       });
     }else if (occupation.trim().isNotEmpty){
       await userDocs.doc(currentUser!.email).update({
         'Occupation':occupation
       });
     }else if (location.trim().isNotEmpty){
       await userDocs.doc(currentUser!.email).update({
         'Location':location
       });
     }

  }
  void updateGenderDocs (User? currentUser,String gender)async{
    await userDocs.doc(currentUser!.email).update({
      'Gender': gender
    });
  }
  //Update Date of Birth
  void updateDOBDocs (User? currentUser,String dob)async{
    await userDocs.doc(currentUser!.email).update({
      'Date of Birth': dob
    });
  }
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDocumentAfterEdit(User? currentUser){
    return userDocs.doc(currentUser!.email).snapshots();
  }

  void signOut (){
    _auth.signOut();
  }



 }