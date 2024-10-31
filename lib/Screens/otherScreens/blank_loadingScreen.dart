import 'dart:io';

import 'package:chatgo/Screens/chat/screen_Video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Services/firebase/chat_Service.dart';
import '../../Services/path_provider.dart';

class BlancLoading extends StatefulWidget {
  final String? videoUrl;
  final String? otherUserID;
  final bool? isCurrentUser;
  final String? docID;
  const BlancLoading({super.key,  this.videoUrl, this.otherUserID, this.isCurrentUser,  this.docID,});

  @override
  State<BlancLoading> createState() => _BlancLoadingState();
}

class _BlancLoadingState extends State<BlancLoading> {
  final _pathProvider = PathProvider();
  final chatServices= ChatService();
  @override
  void initState() {
    super.initState();
    try{
      syncVideoLocally(widget.videoUrl!, widget.isCurrentUser!?'sender':'receiver',
          widget.otherUserID, widget.docID!, 'sharedTo.', 'mp4').then((file) {
        Get.off(VideoPlayScreen(localPath:file.path,videoUrl:widget.videoUrl! ,));
      });
      print(widget.isCurrentUser!);


    } catch (e){
      print("Couldn't upload file: ${e.toString()}");
      Get.off(VideoPlayScreen(videoUrl:widget.videoUrl! ,));
      _pathProvider.errorMessage(context, "Couldn't upload file: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  Future <File> syncVideoLocally(data, field, currentUserID, docID, string, mediaType) async {
    File file =await _pathProvider
        .storeImageInProvider(
        data, '$string$currentUserID${DateTime.now()}.$mediaType', context, 'permanent')
        .then((file) { chatServices.updateMsgData(
        widget.otherUserID,
        {
          'localPath.$field': file!.path,
          'videoUrl.downloaded': true,
        },
        docID);
    return file;});
    return file;
  }
}
