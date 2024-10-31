import 'dart:io';
import 'package:chatgo/Controlller_logic/utils.dart';
import 'package:chatgo/Services/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class Story extends StatefulWidget {
    Story({super.key, required this.storyDoc, required this. pageController,
      required this.storyDocs, required this.doc, required this.tempDirectory,
      required this.focusNode});

  final  QueryDocumentSnapshot<Map<String, dynamic>> storyDoc;

  FocusNode focusNode;

  final PageController pageController;

  final QueryDocumentSnapshot doc;

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> storyDocs;

    Directory? tempDirectory;

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {

  final _pathProvider = PathProvider();

  final _utils = Utils();

  final _fireStore = FirebaseFirestore.instance;

  final _firebaseAuth = FirebaseAuth.instance;

  VideoPlayerController? videoController;

  double? videoIndicatorValue = 0;

  var download = true;

  @override
  void initState() {
    super.initState();
    if(widget.storyDoc['file']!=null){

      if(widget.storyDoc['file'][ 'fileType']=='video'){

        final file = File('${widget.tempDirectory?.path}/${widget.doc.id}Story_${widget.storyDoc.id}');

        if ( file.existsSync()){
          videoController = VideoPlayerController.file(File(file.path),)
            ..initialize().then((_) {
              videoController!.play();
              setState(() {});

          });
        }else{
          _pathProvider.storeImageInProvider(widget.storyDoc['file'][ 'fileUrl'],
              '${widget.doc.id}Story_${widget.storyDoc.id}', context, 'temporary');
         try {
            videoController = VideoPlayerController.networkUrl(
              Uri.parse(widget.storyDoc['file']['fileUrl'].toString()),
            )..initialize().then((_) {
                setState(() {
                  videoController!.play();
                });
              });
          } catch (e){
           _utils.scaffoldMessenger(context, "couldn't load, check connection", 40.h, 220.w, 2, null);
         }
        }
      }
    }
    videoController?.addListener(() {
      if(videoController!.value.isInitialized){
        videoController!.value.isPlaying?setState(() {
          videoIndicatorValue = videoController!.value.position.inMicroseconds /
              videoController!.value.duration.inMicroseconds;
        }): null;

        if (videoController!.value.isCompleted){
          if (widget.pageController.page ==widget.storyDocs.length-1){

            widget.focusNode.unfocus();

          }else{
            widget.pageController.nextPage(duration: const Duration(milliseconds: 1), curve: Curves.decelerate);
          }

        }
      }

    });
  }


  @override
  Widget build(BuildContext context) {

    final docRef = _fireStore.collection('stories').doc(_firebaseAuth.currentUser!.email).collection('localPaths').doc(widget.doc.id);

    void updateStoryDocToSeen (bool downloadFile) {

      docRef.get().then((value){

          final docData = value.data();

          Future<File?> storyFileDownloadLogic (context) async {
            final file = await _pathProvider.storeImageInProvider(widget.storyDoc['file'][ 'fileUrl'],
                '${widget.doc.id}Story_${widget.storyDoc.id}', context, 'temporary');
            return file;
          }

          if (!value.exists){
            downloadFile==true ?  storyFileDownloadLogic(context).then((value){
              print('i am ready to print nnnnnnnnnnnnnnnnnnnnnnn');

              docRef.set({
                widget.storyDoc.id:{
                  'seen': true,
                  'path': value?.path
                }});})
                : docRef.set({
              widget.storyDoc.id:{
                'seen': true,
                'path': 'none'
              }

            });
          }else if (!docData!.containsKey(widget.storyDoc.id)){
            print('i am ready to print ooooooooooooooooooooooooo');

            downloadFile==true ? storyFileDownloadLogic(context).then((value){
              docRef.update({
                widget.storyDoc.id:{
                  'seen': true,
                  'path': value?.path

                }});})
                : docRef.update({
              widget.storyDoc.id:{
                'seen': true,
                'path': 'none'
              }
            });
          }else if ( downloadFile==true && docData[widget.storyDoc.id]['path'] == null){
            print(docData[widget.storyDoc.id]['path']);
            print('i am ready to print oooooo....gjgjgjjf..fjjfjfjfjmzmzxjmxsjjjnssssss');
            storyFileDownloadLogic(context).then((value){
              docRef.update({
                widget.storyDoc.id:{
                  'seen': true,
                  'path': value?.path

                }});});
          }else{
            print('kfkfgjgggggggggggggggggggggggggggggggggggggg');
          }
        } );
    }

    if (widget.storyDoc['file']==null){

      double screenWidth = MediaQuery.of(context).size.width;

      updateStoryDocToSeen(false);

      return Stack(
        children: [
          Align(
            alignment:Alignment.center,
            child:Padding(
              padding:  EdgeInsets.symmetric(vertical: 10.h,horizontal: 15.w),
              child: Center(child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(widget.storyDoc['text']['text'],
                    style: TextStyle(color: _utils.convertToColor(widget.storyDoc['text']['textColor']),
                        fontSize: 20.sp
                    ),)
              ),),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              gestureDetect(onTap:()=> widget.pageController.previousPage(
                  duration: const Duration(milliseconds: 1), curve: Curves.ease),
              width:screenWidth*0.2
              ),
              gestureDetect(onTap: ()=>widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 1), curve: Curves.ease,),
                  width: screenWidth*0.2
              )
            ],
          )
        ]
      );

    }else if(widget.storyDoc['file']!=null){

      widget.storyDoc['file'][ 'fileType']=='img'?updateStoryDocToSeen(true)
      :updateStoryDocToSeen(false);


      return storyWithFileWidget(directory: widget.tempDirectory);



    }else{
      return Container();
    }
  }


  Widget storyWithFileWidget ({required Directory? directory}){

    Widget storyMediaWidget (){
      final file = File('${directory?.path}/${widget.doc.id}Story_${widget.storyDoc.id}');
      if (widget.storyDoc['file'][ 'fileType']=='img'){
        return file.existsSync()
            ?Image.file(file,fit: BoxFit.cover,)
            :Image.network(widget.storyDoc['file'][ 'fileUrl'],
             fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Text("Couldn't load"),);
      }else{
        return Center(child: videoPlayer());
      }
    }
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: storyMediaWidget()

    ),

          widget.storyDoc['file'][ 'fileType']=='video'?Align(alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              value:
              videoIndicatorValue!.isInfinite||videoIndicatorValue!.isInfinite?0:videoIndicatorValue,
              backgroundColor: Colors.transparent,
              valueColor:const AlwaysStoppedAnimation(Colors.white),
              minHeight: 2.h,
              borderRadius: BorderRadiusDirectional.circular(2.r),

            ),):const SizedBox(height: 0,width: 0,),

          widget.storyDoc['text']!=null?Align(alignment: Alignment.bottomCenter,
            child: Container(
              padding: REdgeInsetsDirectional.only(bottom: 10.h,top: 10.h,end: 10.w, start: 10.w),
              color: Colors.white10.withOpacity(0.05),
              child: Text(widget.storyDoc['text'], style:  TextStyle(color: Colors.white,fontSize: 15.sp),
                maxLines: 3, overflow: TextOverflow.ellipsis,),
            ),):Container(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              gestureDetect(onTap:()=> widget.pageController.previousPage(
                  duration: const Duration(milliseconds: 1), curve: Curves.ease),
                  width: screenWidth*0.35 ),
              gestureDetect(onTap: ()=>
                    widget.pageController.nextPage( duration: const Duration(milliseconds: 1), curve: Curves.ease),
                    width: screenWidth*0.35
              )
            ],
          )
        ]
    );
  }

  Widget videoPlayer (){

     if(videoController!=null?videoController!.value.isInitialized:videoController!=null){

       widget.focusNode.addListener(() {
         widget.focusNode.hasFocus?videoController!.pause():videoController!.play();
       });



      return GestureDetector(

        onLongPressStart:  (v)=> videoController!.pause(),
        onLongPressEnd: (v)=>  videoController!.play(),
        child: AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          child: VideoPlayer(videoController!,),
        ),
      );}else{
      return const CircularProgressIndicator();}}


  Widget gestureDetect ({required void Function()? onTap, required double width }){
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap:onTap,
      onLongPressStart: (v)=> videoController?.pause(),
      onLongPressEnd: (v)=> videoController?.play(),
      child: Container(height: screenHeight*0.7,width:width,color: Colors.transparent,),);
  }

  @override
  void dispose() {
    super.dispose();
    //widget.focusNode.dispose();
    videoController?.dispose();

  }
}
