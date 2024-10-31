import 'dart:io';
import 'dart:typed_data';
import 'package:chatgo/Controlller_logic/controller.dart';
import 'package:chatgo/Services/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Services/firebase/chat_Service.dart';
import '../../Services/firebase/firebaseFirestore.dart';
import'../../Services/firebase/firebase_storage.dart';
enum MediaShowState{
  preview,
  view
}

class ShowPicture extends StatefulWidget {
  String? imageUrl;
  MediaShowState mediaShowState;
  String? otherUserID;
  List<dynamic>? contactList;
  Uint8List? imageByte;
  String? localPath;



  ShowPicture({super.key, this.imageUrl, this.mediaShowState=MediaShowState.view, this.otherUserID, this.contactList,
     this.imageByte, this.localPath,
   });

  @override
  State<ShowPicture> createState() => _ShowPictureState();
}

class _ShowPictureState extends State<ShowPicture> {
   // final MyContact pic ;
  final ChatController chatController = Get.put(ChatController());
  final _firebaseAuth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  final chatServices = ChatService();
  final _firebaseStorage = FirebaseStorageService();
  final _fireStoreServices = FireStoreService();
  final _pathProvider = PathProvider();


  @override
  Widget build(BuildContext context) {
    return widget.mediaShowState==MediaShowState.preview
    // Widget for media preview state
        ?Scaffold(
        backgroundColor: Colors.black87,
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: FloatingActionButton( backgroundColor: Colors.transparent,
                onPressed:()=>Get.back(),
                child:const Icon(Icons.close,color: Colors.white,)),
            body:Stack(
                children: [
                  Center(child: Image.memory(widget.imageByte!,fit: BoxFit.cover,)),
                  Positioned(top: 730.h,right: 1.w,
                    child: MaterialButton(elevation: 20.dm,
                      onPressed:_mediaPreviewSend,
                      shape: const CircleBorder(), color: Colors.deepPurple,child:const Icon(Icons.send_outlined, color: Colors.white,),),
                  )
                ],
            ),

    )

    //Widget for normal view state
        :Scaffold(backgroundColor: Colors.black87,
         floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: FloatingActionButton( backgroundColor: Colors.transparent,
           onPressed:()=>Get.back(),
            child:const Icon( Icons.arrow_back_sharp,color: Colors.white,)),
         body:Stack(children: [
          const Center(child: CircularProgressIndicator(),),
          widget.imageUrl!.isNotEmpty&&File(widget.localPath!).existsSync()?Center(child: Image.file(File(widget.localPath!),fit: BoxFit.cover,)):Center(child: Image.network(widget.imageUrl!,fit: BoxFit.cover,)),
        ],)
    );

  }

  void _mediaPreviewSend () async {
    // loading
    showDialog(context: context,
        builder: (context) =>const Center(child: CircularProgressIndicator()),);
    final User currentUser = _firebaseAuth.currentUser!;
    String? imageURL = await _firebaseStorage.uploadToStorage(
        '${currentUser.email!}.message.${widget.otherUserID}_${DateTime.now().toString()}',
        widget.imageByte,
        currentUser,
        context);
    //final fileLocalPath = await _pathProvider.fileLocalStorage('chat.${widget.otherUserID}${DateTime.now()}.jpg',  widget.imageByte!);
    await chatServices.sendMessage(
        widget.otherUserID!, null, null, imageURL, null, null,null,null,null,null).then((value) async {
      await _pathProvider.fileLocalStorage('${value.id}_chat${widget.otherUserID!}.img',  widget.imageByte!);
    });



    if (!widget.contactList!.contains(widget.otherUserID)) {
  await _fireStoreServices.addToContact(
  currentUser: _firebaseAuth.currentUser!.email!,
  contact: widget.otherUserID!,
  );
  await _fireStoreServices.addToContact(
  currentUser: widget.otherUserID!,
  contact: _firebaseAuth.currentUser!.email!);

  //print(widget.contactList);
  print('user added to contact list of current users');
  } else {
  print("User already exists in contact list");
  await _fireStore
      .collection("User's Contacts")
      .doc(_firebaseAuth.currentUser!.email!)
      .collection('contacts')
      .doc(widget.otherUserID)
      .update({'time': DateTime.now()});
  final update = _fireStore
      .collection("User's Contacts")
      .doc(widget.otherUserID)
      .collection('contacts')
      .doc(_firebaseAuth.currentUser!.email!)
      .update({'time': DateTime.now()});

  update.onError((error, stackTrace) =>
      _fireStoreServices.addToContact(
          currentUser: widget.otherUserID!,
          contact: _firebaseAuth.currentUser!.email!)
  );
  }
  Navigator.pop(context);
  Navigator.pop(context);
  }
}
