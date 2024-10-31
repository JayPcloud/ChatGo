import 'dart:io';
import 'dart:typed_data';
import 'package:chatgo/Services/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService{
  final fireStorage = FirebaseStorage.instance;
  final _pathProvider = PathProvider();


  Future <String?>uploadToStorage(String imageFileRef,Uint8List? image,User? currentUser,BuildContext context)async{
    try {

      final storageRefURL= fireStorage.ref();
      final imageRef = storageRefURL.child(imageFileRef);
      await imageRef.putData(image!).whenComplete(() {});
       return await imageRef.getDownloadURL();
    } catch(e){
      print('could not upload file');
      _pathProvider.errorMessage(context, 'Could not upload: Check connection');
      return null;


    }
  }

  // Upload Image to Firebase Storage
Future uploadFile(String imageFileRef,Uint8List? image,User? currentUser, String collection,)async{
  try {

    final storageRefURL= fireStorage.ref();
    final imageRef = storageRefURL.child(imageFileRef);
     await imageRef.putData(image!).whenComplete(() {});
     final imageUrl = await imageRef.getDownloadURL();
     await FirebaseFirestore.instance.collection(collection).doc(currentUser!.email).update({
       'Profile Picture': {
         'imageUrl': imageUrl,
         'dpLastUpdateTime':DateTime.now()
       },
     });

  } catch(e){

    print('could not upload file');

  }
}
// Store the URL in firebase
Future<String?> getFileUrl (String
imageFileRef,) async {
  try{
    // final imageRef = storageRef.child(imageName);
    // return imageRef.getData();
    final storageRefURL= fireStorage.ref();
    final imageRefURL = storageRefURL.child(imageFileRef);
    final url = await imageRefURL.getDownloadURL().whenComplete((){});
    return url;

  } catch (e){
    print('could not get file');
    print(e.toString());
  }
}
// upload video to firebase storage
  Future <String?> uploadFileORVideo (
      {required String bucketName, required String refName, required File file})async{
    try{
      final storageRef = fireStorage.ref().child(bucketName).child(refName);
      await storageRef.putFile(
        file,
      );
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    }catch (e){print('error while uploading file');}
  }
  Future <String?> uploadBytes (
      {required String bucketName, required String refName, required Uint8List byte})async{
    try{
      final storageRef = fireStorage.ref().child(bucketName).child(refName);
      await storageRef.putData(byte,);
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print('error while uploading file');
    }
  }

}