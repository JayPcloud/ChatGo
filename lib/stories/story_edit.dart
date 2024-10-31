import 'dart:io';
import 'package:chatgo/Services/firebase/chat_Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../../Controlller_logic/utils.dart';
import '../../../Services/firebase/firebase_storage.dart';

class EditStory extends StatefulWidget {
   EditStory({super.key,  this.pickedImage,  this.pickedVideo,  });
   XFile? pickedVideo;
  Uint8List? pickedImage;

  @override
  State<EditStory> createState() => _EditStoryState();
}

class _EditStoryState extends State<EditStory> {
  final chatService = ChatService();
  final firebaseStorage =FirebaseStorageService();
  final currentUserID = FirebaseAuth.instance.currentUser!.email;
  final _textController = TextEditingController();
  final storyTextController = TextEditingController();
  VideoPlayerController? _controller;
  bool videoPlaying = true;
  String duration = '0:00';
  int videoSize = 0;

  String fileSize (int bytes){
    double kB = bytes/(1024);
    if (kB>=1000){
      double mB = kB/1024;
      return '${mB.toStringAsFixed(1)}MB';
    }else{return '${kB.toInt()}kB';}
  }
  @override
  void initState() {
   if (widget.pickedVideo!=null){
     File videoFile = File(widget.pickedVideo!.path);
     int fileSize = videoFile.lengthSync();

     _controller =VideoPlayerController.file(videoFile,)
       ..initialize().then((_) {
         setState(() {
           duration=_formatDuration(_controller!.value.duration);
           videoSize=fileSize;});
       });
     _controller!.addListener(() {
       if (!_controller!.value.isPlaying){
         setState(() {
           videoPlaying = false;
         });
       }else{
         setState(() {
           videoPlaying = true;
         });
       }
     });

   }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textController.dispose();
    super.dispose();
  }
  String _formatDuration(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(1, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return widget.pickedImage!=null ? Scaffold(
         backgroundColor: Colors.black45,
         body: Padding(
           padding:  EdgeInsets.only(top: 20.h, bottom: 15.h),
           child: Stack(
            children: [
            Center(child: Image.memory(widget.pickedImage!,fit: BoxFit.cover,)),
            Align(alignment: AlignmentDirectional.topCenter,
             child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
              icon(context, ()=>focusNode.hasFocus?focusNode.unfocus():Get.back(), Icons.clear_outlined,Colors.white,Colors.black87,BorderSide.none),
              icon(context, () { }, Icons.crop,Colors.white,Colors.white10,BorderSide.none)
            ],),),
              inputText(()=>uploadMediaStory( byte: widget.pickedImage!, context: context))
                   ],
                 ),
         ),
    )
    :widget.pickedVideo!=null? Scaffold(
      backgroundColor: Colors.black,
      body: _controller!.value.isInitialized?GestureDetector(
             onTap: () {
          setState(() {
            _controller!.pause();
          });
        },
        child: Stack(children: [
          Center(
            child:
            //||widget.mediaShowState==MediaState.preview
                 AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                 child: VideoPlayer(_controller!),
            )

          ),
          Padding(
            padding:  EdgeInsets.only(top: 25.h,),
            child: Align(alignment: AlignmentDirectional.topCenter,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon(context, ()=>focusNode.hasFocus?focusNode.unfocus():Get.back(), Icons.clear_outlined,Colors.white,Colors.white10, BorderSide.none),
                  Container(
                    padding: EdgeInsets.all(3.dm),
                    decoration: BoxDecoration(color: Colors.white24,shape:BoxShape.rectangle,
                        borderRadius: BorderRadiusDirectional.circular(10.w)),
                    child: Text('$duration . ${fileSize(videoSize)}', style: const TextStyle(color: Colors.white70),),),

                ],),),
          ),
         videoPlaying==false
              ? Center(
            child: IconButton(
              splashColor: Colors.black87,
              style:const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white24)),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              icon: Icon(
                _controller!.value.isPlaying
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
          ),
          inputText(()=>uploadMediaStory(file:  widget.pickedVideo!, context: context))
        ]),
      ):const Center(child:  CircularProgressIndicator()),
    )
     :Obx(
      () => Scaffold(
                backgroundColor: backgroundColor.value,
        body: Padding(
          padding:  EdgeInsets.only(top: 25.h,left: 8.w, right: 8.w, bottom: 30.h),
          child: Stack( children: [
             Center(child: SingleChildScrollView(
               scrollDirection: Axis.vertical,
               child: Obx(
                 () => TextFormField(
                   onChanged:(value) {
                     colorscheme.value ? colorscheme.value = !colorscheme.value : null;
                     value.trim().isEmpty?disableIcon.value = true:disableIcon.value = false;
                   } ,
                   controller: storyTextController,
                   autofocus: true,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  scrollPhysics:const ScrollPhysics(),
                  style: TextStyle(fontSize: 28.sp,color: textColor.value),
                   cursorColor:textColor.value,
                   decoration: InputDecoration(
                       hintText: 'Text...',
                       hintStyle:TextStyle(color: textColor.value.withOpacity(0.5), fontWeight: FontWeight.w400),
                   border: InputBorder.none),
                           ),
               ),
             ),),
            Align(alignment: AlignmentDirectional.topCenter,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => !colorscheme.value?icon(context, ()=>focusNode.hasFocus?focusNode.unfocus():Get.back(),
                      Icons.clear_outlined,Colors.white,Colors.black, BorderSide.none):const SizedBox(width: 0,),),
                  Obx(() => !colorscheme.value? icon(context, () {
                    colorscheme.value = !colorscheme.value;
                    setState(() {focusNode.unfocus();});
                  },
                      Icons.color_lens_outlined, Colors.white, Colors.black, BorderSide.none )
                      :Column( children: [
                    icon(context, ()=> colorscheme.value=!colorscheme.value,
                        Icons.color_lens_outlined, Colors.white, Colors.black, const BorderSide(color: Colors.white) ),
                    icon(context,() {
                      backgroundColor.value = Colors.brown[300]!;colorscheme.value=!colorscheme.value;
                    }, null, Colors.white, Colors.brown[300]!, const BorderSide(color: Colors.white) ),

                    icon(context,(){
                      backgroundColor.value = Colors.red[300]!;colorscheme.value=!colorscheme.value;
                    }, null, Colors.white, Colors.red, const BorderSide(color: Colors.white)),

                    icon(context,(){
                      backgroundColor.value = Colors.blue[300]!;colorscheme.value=!colorscheme.value;
                    }, null, Colors.white, Colors.blue, const BorderSide(color: Colors.white) ),

                    icon(context,(){
                      backgroundColor.value = Colors.black;colorscheme.value=!colorscheme.value;
                    }, null, Colors.white, Colors.black,const BorderSide(color: Colors.white) ),

                    Obx(
                          () => icon(context,(){
                        textColor.value == Colors.white?textColor.value = Colors.black:textColor.value = Colors.white;
                      }, Icons.border_color_outlined, textColor.value, Colors.transparent,const BorderSide(color: Colors.white) ),
                    ),
                  ],),),


                ],),),
            Align(alignment:AlignmentDirectional.bottomEnd,
            child: Obx(() => disableIcon.value==false
                ?icon(context, uploadTextStory,Icons.arrow_forward_sharp,
                Colors.white, Colors.deepPurpleAccent,BorderSide.none )
                :icon(context,() {},Icons.arrow_forward_sharp,Colors.white38,Colors.deepPurpleAccent[300],BorderSide.none)))
          ],),
                ),
              ),
        );
  }
  var colorscheme = false.obs;
  var backgroundColor = Colors.black12.obs;
  var textColor = Colors.white.obs;
  var disableIcon = true.obs;

  FocusNode focusNode = FocusNode();
  Widget icon (context,void Function()? function,icon, iconColor, buttonColor,BorderSide side){
    return MaterialButton(onPressed:function, color: buttonColor,shape: CircleBorder(side: side),
      child: Icon(icon, color: iconColor,),);
  }

  Widget inputText (void Function()? function){
    return Padding(
      padding:  EdgeInsets.only(bottom: 15.h),
      child: Align(alignment: AlignmentDirectional.bottomCenter,
        child: Row(
          children: [
            SizedBox(width: 15.w,),
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                maxLines: null,
                scrollPadding: EdgeInsets.symmetric(horizontal: 5.w),
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Theme.of(context).primaryColor,
                ),
                controller: _textController,
                decoration: InputDecoration(
                  contentPadding:
                   EdgeInsetsDirectional.only(start: 10.w, end: 5.w),
                  fillColor: Colors.white70,
                  filled: true,
                  hintText: 'Add caption...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontWeight: FontWeight.w500,
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
            ),
            icon(context, function,Icons.arrow_forward_sharp, Colors.white, Colors.deepPurpleAccent,BorderSide.none )
          ],
        ),),
    );
  }

  void uploadMediaStory ({XFile? file, Uint8List? byte, context})async{

    Utils().loadingCircle(context);
    focusNode.hasFocus?focusNode.unfocus(): null;

    if (file!=null) {
      final thumbnail =  await  VideoCompress.getFileThumbnail(
        file.path,
        quality: 30,
      );
      final thumbnailUrl = firebaseStorage.uploadFileORVideo(
          bucketName: 'stories',
          refName: 'thumbnail/$currentUserID.${DateTime.now()}-img',
          file: thumbnail);

      final downloadUrl =  firebaseStorage.uploadFileORVideo(
          bucketName:'stories',
          refName:'$currentUserID.${DateTime.now()}-video' ,
          file: File(file.path));

      final urls = await Future.wait([ downloadUrl,thumbnailUrl]);

      chatService.addStory(
          context: context,
          userID:currentUserID,
          text:_textController.text.trim().isNotEmpty? _textController.text.trim(): null,
          file: {
            'fileUrl':urls[0],
            'fileType':'video',
            'thumbnailUrl': urls[1] ,
          },
      thumbnail: urls[1]);

    }else {

      final downloadUrl = await firebaseStorage.uploadBytes(
          bucketName:'stories',
          refName:'$currentUserID.${DateTime.now()}-img' ,
          byte: byte!);
      await  chatService.addStory(
        context: context,
        userID:currentUserID,
          text:_textController.text.trim().isNotEmpty? _textController.text.trim(): null,
          file: {
            'fileUrl':downloadUrl,
            'fileType':'img',
            'thumbnailUrl': downloadUrl ,
          },
        thumbnail: downloadUrl,
        textInfo: null
      );

    }
    Navigator.pop(context);
    Navigator.pop(context);
  }




  void uploadTextStory ()  async {
    showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context,
      builder: (context) =>const Center(child: CircularProgressIndicator()),);
    focusNode.hasFocus?focusNode.unfocus(): null;
    await chatService.addStory(
      context: context,
        userID:currentUserID,
        text:{
          'text':storyTextController.text.trim(),
          'textColor': textColor.value.toString(),
          'backgroundColor':backgroundColor.value.toString(),
        },
        file: null,
    textInfo: {
      'text':storyTextController.text.trim(),
    'textColor': textColor.value.toString(),
    'backgroundColor':backgroundColor.value.toString(),
    },);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
