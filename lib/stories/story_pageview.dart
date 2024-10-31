import 'dart:io';
import 'package:chatgo/Controlller_logic/utils.dart';
import 'package:chatgo/Services/firebase/chat_Service.dart';
import 'package:chatgo/stories/story_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class StoryPageView extends StatefulWidget {
   StoryPageView({super.key, required this.doc, required this.currentUser,
     required this.contactDoc, required this.username, required this.storyDocs});

   List<QueryDocumentSnapshot<Map<String, dynamic>>> storyDocs;
   final  QueryDocumentSnapshot doc;
   Map<String, dynamic> currentUser;
   Map<String, dynamic> contactDoc;
   String username;

  @override
  State<StoryPageView> createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
   final _pageController = PageController();

   final _fireStore = FirebaseFirestore.instance;
   final _firebaseAuth = FirebaseAuth.instance;

   final _utils = Utils();
   FocusNode focusNode = FocusNode();



   @override
   void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black87,
      body:PageView.builder(

                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.storyDocs.length,
                  itemBuilder:(context, index) {

                    final storyDoc = widget.storyDocs[index];

                    ImageProvider profilePic (){
                      if (File(widget.contactDoc['profilePhoto']['localPath']).existsSync()){
           return Image.file(File(widget.contactDoc['profilePhoto']['localPath']),).image;
                      }else{
                        return  NetworkImage(widget.currentUser['Profile Picture']['imageUrl'].toString());
                      }
                    }
                    if(storyDoc['file']!=null){
                      if(storyDoc['file'][ 'fileUrl']=='video'){

                      }
                    }

            return Scaffold(
                        backgroundColor: storyDoc['file']==null?_utils.convertToColor(storyDoc['text']['backgroundColor'])
                        :Colors.black,
                 body: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                      child: Column(children: [
                            Padding(
                              padding:  EdgeInsets.only(
                                  top: screenHeight*0.05,
                                  left: 10.w,
                                  right: 10.w,
                                  bottom: screenHeight*0.01),
                              child: Row(children:

                              widget.storyDocs.map((doc) {
                                var currentDocIndex = widget.storyDocs.indexWhere((doc2) =>doc2.id==doc.id);
                                print(index);
                                print(currentDocIndex);
                                return  Expanded(child: Padding(
                                  padding:  EdgeInsets.only(left: 5.w),
                                  child:  LinearProgressIndicator(
                                      value:1,
                                       valueColor:index>=currentDocIndex? AlwaysStoppedAnimation(Colors.deepPurple[200])
                                          :const AlwaysStoppedAnimation(Colors.white),
                                      minHeight: 2.5.h,
                                      borderRadius: BorderRadiusDirectional.circular(5.r),
                                    ),
                                ));
                              }).toList()
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               Row(
                                 children: [
                                   SizedBox(width: 10.w,),
                                 GestureDetector(
                                     onTap: ()=> focusNode.hasFocus?focusNode.unfocus():Get.back(),
                                     child: const Icon(Icons.arrow_back_rounded, color: Colors.white,)),
                                 SizedBox(width: 8.w,),
                                 CircleAvatar(
                                     radius: 20.r,
                                     backgroundImage:widget.currentUser['Profile Picture']!=null?profilePic()
                                         :const AssetImage('assets/0ca6ecf671331f3ca3bbee9966359e32.jpg')),
                                 SizedBox(width: 10.w,),
                                 Text(widget.username, overflow: TextOverflow.ellipsis,maxLines: 1,
                                   style:const TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
                                 SizedBox(width: 5.w,),
                                 Text(_utils.timeConverter(storyDoc['timeStamp']), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300),),
                                 //SizedBox(width: 95.w,),
                               ],),

                              widget.username=='My Story'
                             ?PopupMenuButton(
                                iconColor: Colors.white,
                                itemBuilder:(context) {
                                return [PopupMenuItem(
                                  height: 20.h,
                                    onTap: () async {
                                    _utils.loadingCircle(context);
                                    if(widget.storyDocs.length==1){
                                       Future.wait( [
                                         storyDoc.reference.delete(),
                                         //doc.reference.delete(),
                                       ] );
                                    }else{
                                      await storyDoc.reference.delete();
                                    }
                                    Navigator.of(context).pop();
                                    Get.back();
                                    _utils.scaffoldMessenger(context, 'story deleted', 40.h, 120.w, 1, null);
                                    },
                                      child:const Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                           Text('Delete'),
                                          Icon(Icons.delete_forever_outlined)
                                        ],
                                      ))
                                ];
                              },): SizedBox(height: 1.h, width: 1.w,)
                            ],),
                            SizedBox(height: screenHeight*0.015,),
                            Stack(
                              children: [

                             SizedBox(
                                  height: screenHeight*0.85,
                                child: Column(
                                      children: [
                                   Expanded(child: FutureBuilder(
                                    future: getTemporaryDirectory(),
                                     builder:(context, snapshot) {
                                      if (snapshot.hasData){
                                     final directory = snapshot.data;
                                     return Story(doc:widget.doc,
                                    storyDoc: storyDoc,pageController:_pageController,
                                    storyDocs: widget.storyDocs, tempDirectory: directory,
                                         focusNode: focusNode
                                    );
                                   }else{
                                     return const Text('fetching directory');
                                    }
                                  },
                                 )

                                        ),
                                         SizedBox(height: 15.h,),
                                        replyTextField( context,storyDoc, focusNode)
                                      ],
                                    )),

                              ],
                            ),



                          ],),
                        ),
                      );
                  },)

    );
  }

   Widget replyTextField (context, storyDoc,FocusNode focusNode){

     final replyController = TextEditingController();
     final chatServices = ChatService();
     return Row(
       children: [
         SizedBox(width: 10.w,),
         Expanded(
           child: TextFormField(
             cursorColor: Colors.white,
             maxLines: null,
             focusNode: focusNode,
             scrollPadding: EdgeInsets.symmetric(horizontal: 5.w),
             style:  TextStyle(fontSize: 15.sp, color: Colors.white,),
             controller: replyController ,
             decoration: InputDecoration(
               enabledBorder: OutlineInputBorder(
                 borderSide:const BorderSide(color:Colors.white, ),
                 borderRadius: BorderRadius.circular(25),
               ),
               focusedBorder: const OutlineInputBorder(
                 borderRadius: BorderRadius.all(Radius.circular(15),),
                 borderSide: BorderSide(color: Colors.white,),),
               contentPadding:
                EdgeInsetsDirectional.only(start: 10.w, end: 5.w),
               hintText: 'reply',
               hintStyle:  TextStyle(
                 fontSize: 12.sp,
                 color: Colors.white,
                 fontWeight: FontWeight.w500,
               ),
             ),
           ),
         ),
         MaterialButton(onPressed:() async {
           bool textExists = storyDoc['text']!=null;
           bool fileExists = storyDoc['file']!=null;
           if(replyController.text.toString().trim().isNotEmpty){
             await chatServices.sendMessage(
                 widget.doc.id,
                 replyController.text.trim(),
                   {
                     'text': textExists && !fileExists ? storyDoc['text']['text']:
                     textExists && fileExists? storyDoc['text']: '',
                   'thumbnailUrl': storyDoc['file']!=null?storyDoc['file']['thumbnailUrl'].toString():null
                   },
                 null,
                 null,
                 null,
                 null,
                 null,
                 null,
                 null);
             replyController.clear();
              _fireStore
                 .collection("User's Contacts")
                 .doc(_firebaseAuth.currentUser!.email!)
                 .collection('contacts')
                 .doc(widget.doc['Email'])
                 .update({'time': DateTime.now()});
               _fireStore
                 .collection("User's Contacts")
                 .doc(widget.doc['Email'])
                 .collection('contacts')
                 .doc(_firebaseAuth.currentUser!.email!)
                 .update({'time': DateTime.now()});
             _utils.scaffoldMessenger(context, 'Reply sent', 40.h, 130.w, 1, null);
           }

         },
           shape:const CircleBorder(side: BorderSide.none),
           child: const Icon(Icons.send, color: Colors.white,),),
       ],
     );
   }
}

// StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
// stream: doc.reference.collection('userStory')
//     .where('timeStamp', isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)))
//     .orderBy('timeStamp', descending: true).snapshots(),
//
// builder: (context, snapshot) {
//
// if (snapshot.hasData){
// final storyDocs = snapshot.data!.docs;
// ImageProvider profilePic (){
// if (File(contactDoc['profilePhoto']['localPath']).existsSync()){
// return Image.file(File(contactDoc['profilePhoto']['localPath']),).image;
// }else{
// return  NetworkImage(currentUser['Profile Picture']['imageUrl'].toString());
// }
// }
//
// return PageView.builder(
//
// //scrollBehavior: ScrollBehavior(),
// controller: _pageController,
// scrollDirection: Axis.horizontal,
// physics: const NeverScrollableScrollPhysics(),
// itemCount: storyDocs.length,
// itemBuilder:(context, index) {
//
// final storyDoc = snapshot.data!.docs[index];
//
// if(storyDoc['file']!=null){
// if(storyDoc['file'][ 'fileUrl']=='video'){
//
// }
// }
//
// return Scaffold(
// backgroundColor: storyDoc['file']==null?_utils.convertToColor(storyDoc['text']['backgroundColor'])
//     :Colors.black,
// body: SingleChildScrollView(
// scrollDirection: Axis.vertical,
// child: Column(children: [
// Padding(
// padding:  EdgeInsets.only(top: 35.h, left: 10.w,right: 10.w,bottom: 10.w),
// child: Row(children:
//
// storyDocs.map((doc) {
// var currentDocIndex = storyDocs.indexWhere((doc2) =>doc2.id==doc.id);
// print(index);
// print(currentDocIndex);
// return  Expanded(child: Padding(
// padding:  EdgeInsets.only(left: 5.w),
// child:  LinearProgressIndicator(
// value:1,
// valueColor:index>=currentDocIndex? AlwaysStoppedAnimation(Colors.deepPurple[200])
//     :const AlwaysStoppedAnimation(Colors.white),
// minHeight: 4.h,
// borderRadius: BorderRadiusDirectional.circular(5.dm),
// //color: currentDocIndex.value==index?Colors.deepPurple[200]:Colors.white,
//
// // valueColor: Colors.white,
// ),
// ));
// }).toList()
// ),
// ),
//
// Row(children: [
// SizedBox(width: 5.w,),
// GestureDetector(
// onTap: ()=> Get.back(),
// child: const Icon(Icons.arrow_back_rounded, color: Colors.white,)),
// SizedBox(width: 8.w,),
// CircleAvatar(
// radius: 20.dm,
// backgroundImage:currentUser['Profile Picture']!=null?profilePic()
//     :const AssetImage('assets/0ca6ecf671331f3ca3bbee9966359e32.jpg')),
// SizedBox(width: 10.w,),
// Text(username, overflow: TextOverflow.ellipsis,maxLines: 1,
// style:const TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
// SizedBox(width: 5.w,),
// Text(_utils.timeConverter(storyDoc['timeStamp']), style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w300),),
// SizedBox(width: 95.w,),
// username=='My Story'
// ?PopupMenuButton(
// iconColor: Colors.white,
// itemBuilder:(context) {
// return [PopupMenuItem(
// height: 20.h,
// onTap: () async {
// _utils.loadingCircle(context);
// if(storyDocs.length==1){
// Future.wait( [storyDoc.reference.delete(),doc.reference.delete(),] );
// }else{
// await storyDoc.reference.delete();
// }
// Navigator.of(context).pop();
// Get.back();
// _utils.storyMessenger(context, 'story deleted');
// },
// child:const Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Text('Delete'),
// Icon(Icons.delete_forever_outlined)
// ],
// ))
// ];
// },):const SizedBox(height: 0, width: 0,)
// ],),
// SizedBox(height: 5.h,),
// Stack(
// children: [
//
// SizedBox(
// height: screenHeight*0.87,
// child: Column(
// children: [
// Expanded(child: Story(
// storyDoc: storyDoc,pageController:_pageController,
// storyDocs: storyDocs,
// )),
// SizedBox(height: 15.h,),
// replyTextField(() { }, context)
// ],
// )),
//
// ],
// ),
//
//
//
// ],),
// ),
// );
// },);
// }else if (snapshot.hasError){
// print(snapshot.error.toString());
// return const Center(child:  Text('error'));
// }else if (snapshot.connectionState==ConnectionState.waiting){
// return const Center(child: Text('loading...'));
// }else{
// return const Text('No data');
// }
//
// }
// ),