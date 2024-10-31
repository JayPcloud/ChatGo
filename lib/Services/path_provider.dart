import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PathProvider {


  void load (BuildContext context){
    showDialog(context: context,
        builder:  (context) => const Center(child: CircularProgressIndicator()),);
  }
  void errorMessage (BuildContext context, String errorMessage){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
        content:Text(errorMessage)));
  }
  Future<File?>  storeImageInProvider(
    String? fileUrl,
      String subDirectory,
      BuildContext context,
      storageType
  ) async {

    Future <Uint8List> assetToImageFile (String assetName) async {
      final asset = await rootBundle.load(assetName);
      final bytes = asset.buffer.asUint8List();
      return bytes;
    }

    // DownLoad Image data from Firebase e.t.c
    try {

      final directory = storageType== 'cache'?await getApplicationCacheDirectory()
          : storageType== 'temporary'? await getTemporaryDirectory()
          :await getApplicationDocumentsDirectory();

      File testFile =  File('${directory.path}.testFile');
      final test = await testFile.writeAsBytes(await assetToImageFile('assets/0ca6ecf671331f3ca3bbee9966359e32.jpg'));
      print(test);
      await test.delete();

      var imageData = await http.get(Uri.parse(fileUrl!));
      File file = File('${directory.path}/$subDirectory');
      await file.writeAsBytes(imageData.bodyBytes);
      print(fileUrl);
      print("stored successfully");


      return file;

    } catch (e) {
      print("${e.toString()}Error: Couldn't provide storage path");
      //errorMessage(context,e.toString());
    }
  }

  Future<File?> getProfilePhotoFilePath(User? currentUser) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File("${directory.path}/${currentUser!.email} _profilePhoto.jpg");

    } catch (e) {
      print("Error: ${e.toString()}/ No such path available");

    }
  }

  // media file sharing local storage
  Future <String?> getDirectory (String subDirectory)async{
    try{
      final localPath = await getApplicationDocumentsDirectory();
      File file = File('${localPath.path}/ $subDirectory');
      return '$localPath/ $subDirectory';
    } catch(e){
      print(e.toString());
    }
  }
 Future <String?> fileLocalStorage (String subDirectory, Uint8List fileData)async{
    try{
      final localPath = await getApplicationDocumentsDirectory();
      print(localPath.path);
      File file = File('${localPath.path}/$subDirectory');
      final filePath = await file.writeAsBytes(fileData);
      print('done');
      return filePath.path;
    } catch (e){
      print(e.toString());
      print('undone');
    }
 }
}
