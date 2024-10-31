import 'dart:async';
import 'dart:io';
import 'package:chatgo/Screens/chat/profile_pic.dart';
import 'package:chatgo/Screens/otherScreens/blank_loadingScreen.dart';
import 'package:chatgo/Services/firebase/chat_Service.dart';
import 'package:chatgo/Services/firebase/firebaseFirestore.dart';
import 'package:chatgo/Services/firebase/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../../Services/path_provider.dart';
enum MediaState{
  preview,
  view
}

// Stateful widget to fetch and then display video content.
class VideoPlayScreen extends StatefulWidget {
  final String? videoUrl;
  final MediaState mediaShowState;
  final XFile? videoFile;
  final String? otherUserID;
  final List? contactList;
  final String? localPath;
  //final DocumentSnapshot? doc;

  const VideoPlayScreen({super.key,  this.videoUrl, this.mediaShowState=MediaState.view,
    this.videoFile, this.otherUserID, this.contactList, this.localPath, });

  @override
  _VideoPlayScreenState createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  late VideoPlayerController _controller;

  final _firebaseAuth = FirebaseAuth.instance;

  final _firebaseStorage = FirebaseStorageService();

  final chatServices= ChatService();

  final _fireStore = FirebaseFirestore.instance;

  final _fireStoreServices = FireStoreService();

  final _pathProvider = PathProvider();

  bool _showVideoController = true;
  double? progressIndicator;
  String _currentTimerText = '00:00';
  String _durationTimerText = '00:00';

  @override
  void initState() {
    super.initState();
    if (widget.mediaShowState==MediaState.preview){
      _controller =VideoPlayerController.file(File(widget.videoFile!.path),)
        ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
    });

    }else if (File(widget.localPath!).existsSync()) {
      _controller =VideoPlayerController.file(File(widget.localPath!),)
        ..initialize().then((_) {
          setState(() {});});
    }else{
      _controller =VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl.toString()),)
        ..initialize().then((_) {
          setState(() {});});
    }




    Timer(const Duration(seconds: 10), () {
      if (_showVideoController == true) {
        setState(() {
          _showVideoController = !_showVideoController;
        });
      }
    });

    _controller.addListener(() {
      setState(() {
        progressIndicator = _controller.value.position.inSeconds /
            _controller.value.duration.inSeconds;
        _currentTimerText = _formatDuration(_controller.value.position);
        _durationTimerText =_formatDuration(_controller.value.duration);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: widget.mediaShowState==MediaState.preview?FloatingActionButtonLocation.endContained:null,
      floatingActionButton: widget.mediaShowState==MediaState.preview?FloatingActionButton(
        shape:const CircleBorder(),
        backgroundColor: Colors.deepPurple,
          onPressed:_sendPreview,
      child:const Icon( Icons.send_outlined, color: Colors.white,),):null,
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showVideoController = !_showVideoController;
          });
        },
        child: Stack(children: [
          _showVideoController
              ? AppBar(
                  backgroundColor: Colors.black45,
                  leading: IconButton(
                      onPressed: Get.back,
                      icon: Icon(
                        widget.mediaShowState==MediaState.preview?Icons.close:Icons.arrow_back,
                        color: Colors.white,
                      )),
                  bottom: _controller.value.isInitialized?PreferredSize(
                    preferredSize:const Size.fromHeight(0),
                    child: Padding(
                      padding:
                           EdgeInsets.only(bottom: 50.h, left: 15.w, right: 15.w),
                      child: Row(
                        children: [
                          Text(_currentTimerText,style: const TextStyle(color: Colors.white),),
                           SizedBox(width: 5.w,),
                          Expanded(
                            child: LinearProgressIndicator(
                                borderRadius: BorderRadiusDirectional.circular(10.r),
                                value: progressIndicator),
                          ),
                           SizedBox(width: 5.w,),
                          Text(_durationTimerText,style: const TextStyle(color: Colors.white),)
                        ],
                      ),
                    ),
                  ):null)
              :  SizedBox(
                  height: 1.h,
                  width: 1.w,
                ),
          Center(
            child: _controller.value.isInitialized
                //||widget.mediaShowState==MediaState.preview
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          _showVideoController
              ? Center(
                  child: IconButton(
                     splashColor: Colors.black87,
                    style:const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white24)),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 60.w,
                    ),
                  ),
                )
              :  SizedBox(
                  height: 1.h,
                  width: 1.w,
                )
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  Future<void> _sendPreview() async {
    showDialog(context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),);
    final thumbnail = await VideoCompress.getFileThumbnail(
      widget.videoFile!.path,
      quality: 50,
    );
    final fileLocalPath = await _pathProvider.fileLocalStorage('sharedTo.${widget.otherUserID}${DateTime.now()}.mp4',await widget.videoFile!.readAsBytes());

    final thumbnailUrl = _firebaseStorage.uploadFileORVideo(
        bucketName: 'video/chats',
        refName:
        'thumbnail/${_firebaseAuth.currentUser!.email!}.message.${widget
            .otherUserID}_${DateTime.now().toString()}',
        file: thumbnail);
    final videoUrl =  _firebaseStorage.uploadFileORVideo(
        bucketName: 'video/chats',
        refName:
        '${_firebaseAuth.currentUser!.email!}.message.${widget
            .otherUserID!}_${DateTime.now().toString()}',
        file: File(widget.videoFile!.path));

    final urls = await Future.wait([thumbnailUrl,videoUrl]);
    await chatServices.sendMessage(
        widget.otherUserID!, null, null, null, urls[1], urls[0],fileLocalPath,null,null, null).then((value) async {
      await _pathProvider.fileLocalStorage('${value.id}_chat${widget.otherUserID!}.img',await thumbnail.readAsBytes());

    });



    if (!widget.contactList!.contains(widget.otherUserID)) {
      await _fireStoreServices.addToContact(
        currentUser: _firebaseAuth.currentUser!.email!,
        contact: widget.otherUserID!,
      );
      await _fireStoreServices.addToContact(
          currentUser: widget.otherUserID!,
          contact: _firebaseAuth.currentUser!.email!);

      print(widget.contactList);
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
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

}
