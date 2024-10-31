import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chatgo/Controlller_logic/model/story_painter.dart';
import 'package:chatgo/Screens/otherScreens/all_users.dart';
import 'package:chatgo/Services/firebase/chat_Service.dart';
import 'package:chatgo/Services/path_provider.dart';
import 'package:chatgo/stories/story_pageview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import '../../Controlller_logic/controller.dart';
import '../../Controlller_logic/utils.dart';
import '../../stories/story_edit.dart';
import '../top_tabs.dart';
import 'private_chatRoom.dart';
import 'profile_pic.dart';


class ActiveContacts extends StatefulWidget {
  const ActiveContacts({super.key});

  @override
  State<ActiveContacts> createState() => _ActiveContactsState();
}

class _ActiveContactsState extends State<ActiveContacts> {
  final ChatController chatController = Get.put(ChatController());

  final _chatService = ChatService();

  final _firebaseAuth = FirebaseAuth.instance;

  final _fireStore = FirebaseFirestore.instance;

  final _pathProvider = PathProvider();

  final _imagePicker = ImagePicker();

  final _utils = Utils();

  final now = DateTime.now();



  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Padding(
          padding:  EdgeInsets.only(left: 15.w, top: 40.h),
          child: Row(children: [Text('ChatGo', style:TextStyle(color: Theme.of(context).primaryColor,
          fontSize: 20.sp, fontWeight: FontWeight.w500,))],),
        ),
        SingleChildScrollView(scrollDirection: Axis.vertical,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getUsersContactData(_firebaseAuth.currentUser!),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                    child: Text("Loading..."),
                  );

                } else if (snapshot.hasError) {
              return Center(
                    child: Text(snapshot.error.toString()),
                  );

                } else if (snapshot.hasData) {
                  List? allContactID = snapshot.data!.docs.map((docs) => docs['Email']).toList();
                  List? savedContactIDs = snapshot.data!.docs.where((element) =>element.data().containsKey('BothUsersSavedByEachOther'))
                      .map((e) => e.id).toList();
                  print(allContactID);
                  final contactsSnapshot = snapshot;
                  // check if currentUser has contacts
                  if (allContactID.isNotEmpty) {
                    Map<String, dynamic> userDataMap = {};

                    for (var doc in snapshot.data!.docs) {
                      String email = doc['Email'];
                      userDataMap[email] = null;}
                    return StreamBuilder(
                      stream:  _fireStore.collection('users').where('Email', whereIn: userDataMap.keys.toList(), ).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData){
                          final usersSnapshot = snapshot;
                          for (var contact in snapshot.data!.docs) {
                            String email = contact['Email'];
                            userDataMap[email] = contact.data();
                          }
                   Widget emptyStoryWidget (){
                     _fireStore.collection("User's Contacts").doc(_firebaseAuth.currentUser!.email).
                     collection('contacts').doc(_firebaseAuth.currentUser!.email).set({
                     'Email': _firebaseAuth.currentUser!.email,
                     'time': DateTime.now(),
                     'profilePhoto':{
                     'localPath': '',
                     'lastUpdated': '',},
                       'BothUsersSavedByEachOther': true,
                       'saved': true
                     });
                     return const Text('Save contacts to view their story updates');
                   }
                return Column(
                            children: [
                    savedContactIDs.isNotEmpty?StreamBuilder(
                                  stream: _chatService.streamContactStories( savedContactIDs ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData){
                                      final docs = snapshot.data!.docs;

                         return Padding(
                                        padding:  EdgeInsets.fromLTRB(10.w, 15.h, 10.w, 0),
                             child: Column(children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Stories',
                                                  style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                                MaterialButton(
                                                  onPressed:() => storyTypePicker(context),
                                                  color: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(20.w)),
                                                  child:docs.any((doc) => doc['Email']==_firebaseAuth.currentUser!.email)
                                                      ?const Row(mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.add),
                                                      Text('Add',style: TextStyle(color: Colors.black,),),
                                                    ],)
                                                      :const Row(mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.create_outlined),
                                                      Text('Create',style: TextStyle(color: Colors.black,),),
                                                    ],),
                                                )
                                              ],
                                            )
                                            ,
                                SizedBox(height: 10.h,),
                               docs.map((doc) => doc.id).toList().isNotEmpty?SizedBox(height: 144.h,width: 350.w,
                                 child: ListView.builder(
                                    itemCount: docs.length,
                                     itemBuilder: (BuildContext context, int index) {

                                     int? currentUserDocIndex = docs.indexWhere((doc) => doc['Email'] == _firebaseAuth.currentUser!.email);
                                                    //print(currentUserDocIndex);

                                    if (currentUserDocIndex!=-1){

                                     docs.insert(0, docs.removeAt(currentUserDocIndex));

                                     final doc = docs[index];
                                     final contactDoc = contactsSnapshot.data!.docs.firstWhere((contact) => contact.id==doc.id).data();
                                     final userDoc = usersSnapshot.data!.docs.firstWhere((contact) => contact.id==doc.id).data();

                                     final storyDocs = docs[index].reference.collection('userStory').orderBy('timeStamp', descending: true).snapshots();

                                                                 if (index==0){
                                  return storyWidget('My Story', userDoc, contactDoc, doc, storyDocs);
                                  }else {
                                    return storyWidget(userDoc['User Name'], userDoc, contactDoc,  doc, storyDocs);
                                       }

                                  }else {
                                  final doc = docs[index];
                                  final contactDoc = contactsSnapshot.data!.docs.firstWhere((contact) => contact.id==doc.id).data();
                                  final userDoc = usersSnapshot.data!.docs.firstWhere((contact) => contact.id==doc.id).data();
                                  final storyDocs = docs[index].reference.collection('userStory').orderBy('timeStamp', descending: true).snapshots();

                                   return storyWidget(userDoc['User Name'], userDoc, contactDoc,  doc, storyDocs,);
                                     }

                                     },
                                     scrollDirection: Axis.horizontal,
                                                ),
                                   ):const Text('No Story updates yet. Create one',style: TextStyle(fontStyle: FontStyle.italic)),

                                          ],
                                        ),
                                      );
                         } else {return const Text('loading...');}

                                  }
                              )
                              : emptyStoryWidget(),

                   ListView.builder(
                     itemCount: userDataMap.length,
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                           itemBuilder: (
                               BuildContext context,
                               int index,
                               ) {
                       String email = userDataMap.keys.elementAt(index);
                       dynamic userData = userDataMap[email];
                       final contactDoc = contactsSnapshot.data!.docs.firstWhere((doc) => doc.id==userData['Email']);
                       final contact = contactDoc.data();
                       bool isMe = userData['Email']==_firebaseAuth.currentUser!.email;
                         return ListTile(
                           onLongPress: contact.containsKey('saved')?null:(){
                             showModalBottomSheet(context: context,
                               backgroundColor: Colors.transparent,
                               builder: (context) => Column(
                                 children: [
                                   IconButton(onPressed: ()=> Navigator.of(context).pop(),
                                       icon: Icon(Icons.close_rounded, color:Colors.white,size: 30.w,)),
                               SizedBox(height: 100.h,),
                                   IconButton(
                                         onPressed: (){
                                           Get.offUntil(MaterialPageRoute(builder: (context) => const ContactList(),), (route) => route.settings.name=='/');
                                           contactDoc.reference.delete().then((value) {
                                           });
                                         },
                                         icon:  Icon(Icons.delete, color:  Colors.white,size: 30.w,)),
                                 ],
                               ),);
                           },
                           titleTextStyle:  TextStyle(
                               fontWeight: FontWeight.w500,
                               fontSize: 16.sp,
                               color: Colors.black87),
                             onTap: () => Get.to(() => ChatPage(
                               contactDoc : contactDoc,
                               dpLocalPath: contact['profilePhoto']['localPath'],
                               contactName: userData['User Name'],
                               imageUrl: userData['Profile Picture']!=null?userData['Profile Picture']['imageUrl']:null,
                               userData: userData,
                               contactList: allContactID,
                                                )),
                           leading: GestureDetector(
                             onTap: () {
                               userData['Profile Picture']!=null?Get.to(ShowPicture(imageUrl:userData['Profile Picture']['imageUrl'].toString() ,
                                 localPath:contact['profilePhoto']['localPath'] ,)):null;
                               },
                             child: Padding(
                               padding: const EdgeInsets.only(
                                   left: 0, right: 0),
                               child: Stack(children: [
                                 CircleAvatar(
                                   radius: 30.r,
                                   backgroundImage:
                                   userData['Profile Picture']!=null
                                       ? profilePicDisplay(userData['Email'].toString(), contact, userData['Profile Picture']['dpLastUpdateTime'],
                                       userData['Profile Picture']['imageUrl'].toString(), true) : null,
                                   child: userData['Profile Picture'] == null
                                       ? Icon(Icons.person,
                                       color: Theme.of(context)
                                           .splashColor,
                                       size: 40.w)
                                       : null,
                                 ),
                               ],
                               ),
                             ),
                           ),
                           title:contactDoc.data().containsKey('saved')? Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Expanded(
                                 child: Text(
                                   isMe? '${userData['User Name']}(Me)' :contact['savedNameAs'].toString(),
                                   overflow: TextOverflow.ellipsis,
                                   style: TextStyle(
                                       color: Theme.of(context).primaryColor),
                                 ),
                               ),
                               Icon(Icons.person, color: Colors.deepPurple[300],size: 17.w,)
                             ],
                           ):Text(
                             isMe?'${userData['User Name']}(Me)': userData['User Name'],
                             overflow: TextOverflow.ellipsis,
                             maxLines: 1,
                             style: TextStyle(
                                 color: Theme.of(context).primaryColor),
                           ),
                           subtitle: StreamBuilder(
                               stream: _chatService.getMessages(
                                   _firebaseAuth.currentUser!.email!,
                                   userData['Email'].toString()),
                               builder: (context, snapshot) {
                                 if (snapshot.hasError) {
                                   return const Text(" ");
                                 } else if (snapshot.hasData) {
                                   final lastMessage = snapshot.data?.docs;
                                   if (lastMessage!.isNotEmpty) {
                                     return lastMessage
                                         .map(
                                           (doc) => _buildLastMessage(
                                               doc, context, userData),
                                     ).last;
                                   } else {
                                     return const Text(
                                       'say hello',
                                       style: TextStyle(
                                           color: Colors.grey,
                                           fontStyle: FontStyle.italic),
                                     );
                                   }
                                 } else {
                                   return const Text("No data");
                                 }
                               }),
                           trailing: StreamBuilder(
                               stream: _chatService.getMessages(
                                   _firebaseAuth.currentUser!.email!,
                                   userData['Email'].toString()),
                               builder: (context, snapshot) {
                                 if (snapshot.hasError) {
                                   return const Text(
                                       " ");
                                 } else if (snapshot.hasData) {
                                   final messageList = snapshot.data!.docs;
                                   if (messageList.isNotEmpty) {
                                     return Text(
                                       DateFormat().add_jm().format(
                                           messageList.last["timeStamp"]
                                               .toDate()
                                               .toLocal()),
                                       style: TextStyle(
                                           color: Theme.of(context)
                                                                    .primaryColor),
                                     );
                                   } else {
                                     return const Text('');
                                   }
                                 } else {
                                   return const Text("No data");
                                 }
                               }),
                         );
                         },
                   )
                            ],
                );
                        }else if (snapshot.hasError){
                         return const Center(child:  Text('Something went wrong'));
                        }else{
                          return const Text('');}
                      }

                    );

                    } else {
                    return SizedBox(height: MediaQuery.of(context).size.height*0.7,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(bottom: 30.h),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal:20),
                                child: Text(
                                  'No Contacts yet. Search and Save contacts to view their story',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () => Get.to(const AllUsers()),
                                child:  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'find contacts',
                                      style: TextStyle(color: Colors.deepPurple),
                                    ),
                                    SizedBox(
                                      width: 10.h,
                                    ),
                                    const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: Colors.deepPurple,
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  }
                } else {
                  return const Center(child: Text("No data"));
                }
              }
                      ),
        ),
      ],
    );
  }

  Widget _buildLastMessage(
      DocumentSnapshot? doc, BuildContext context, userData) {
    Map<String, dynamic>? data = doc?.data() as Map<String, dynamic>;
    if (data['receiverID'] == _firebaseAuth.currentUser!.email) {
      _chatService.getAndUpdateUnreadStatus(_firebaseAuth.currentUser!.email!,
          userData['Email'], 'received', false, {'received': true});
    }
    bool isCurrentUser = data['senderID'] == _firebaseAuth.currentUser!.email!;
    return Row(
      children: [
         SizedBox(
          width: 3.w,
        ),
        data['received'] == false && isCurrentUser && data['unread'] == true
            ?  Icon(
                Icons.check_circle_outline,
                size: 12.w,
              )
            : data['received'] == true &&
                    isCurrentUser &&
                    data['unread'] == true
                ?  Icon(
                    Icons.check_circle,
                    size: 12.w,
                  )
                : data['received'] == true &&
                        isCurrentUser &&
                        data['unread'] == false
                    ?  Icon(
                        Icons.check_circle,
                        color: Colors.deepPurple,
                        size: 12.w,
                      )
                    :  Text(
                        '',
                        style: TextStyle(fontSize: 5.sp),
                      ),
        data['unread'] == true &&
                data['receiverID'] == _firebaseAuth.currentUser!.email
            ? Padding(
                padding:  EdgeInsets.only(right: 10.w),
                child: Container(
                  height: 10.h,
                  width: 10.w,
                  decoration: const BoxDecoration(
                      color: Colors.deepPurple, shape: BoxShape.circle),
                ),
              )
            : Container(),
        data['message'] != null
            ? data['storyReply']!=null?Expanded(
              child: Row(
                children: [
                   Icon(Icons.reply_all, color: Colors.deepPurple[300],),
                  SizedBox(width:  5.w,),
                  Expanded(
                    child: Text(
                    data['message'],
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                                  ),
                  ),
                ],
              ),
            ): Expanded(
              child: Text(
                data['message'],
                style: TextStyle(color: Theme.of(context).primaryColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
            : Icon(
                Icons.image,
                color: Theme.of(context).indicatorColor,
              )
      ],
    );
  }

  ImageProvider profilePicDisplay (contactID,doc, serverFieldTimeStamp, imageUrl, bool localStoreFunc)  {
    final file = File(doc['profilePhoto']['localPath']);
    if (file.existsSync()&&doc['profilePhoto']['lastUpdated'] ==serverFieldTimeStamp){
     print(file.path);
      return Image.file(File(doc['profilePhoto']['localPath'])).image;
    }else {
      localStoreFunc==true? _pathProvider.storeImageInProvider(imageUrl, '$contactID _profilePhoto.jpg', context, 'permanent').then((file) =>
         file!=null? _fireStore.collection("User's Contacts").doc(_firebaseAuth.currentUser!.email).collection('contacts').doc(contactID).update({
            'profilePhoto':{
              'localPath': file.path,
              'lastUpdated': serverFieldTimeStamp
            }
          }
          ):null
      ):null;

      return  Image.network(imageUrl).image;
    }
  }

  void storyTypePicker (BuildContext context){
    showDialog(context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(20.r)),
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        content: Row(children: [
          icon('camera', Icons.camera_alt_outlined,Colors.grey, () async => storyImgFunction(await _imagePicker.pickImage(source:ImageSource.camera,imageQuality:50))),
          icon('gallery', Icons.photo_library_outlined,Colors.grey,() async =>storyMediaPick() ),
          icon('video', Icons.videocam_outlined,Colors.grey,() async =>storyVidFunction(await _imagePicker.pickVideo(source:ImageSource.camera,maxDuration:const Duration(minutes: 2),)) ),
          icon('Text', Icons.mode_edit_outlined,Colors.purpleAccent,() async => Get.to(EditStory())),

        ],),
      ),);
  }
  Widget icon (info, icon, color, void Function()? function)  {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(onPressed: function, color: color,shape:const CircleBorder(),
            child: Icon(icon, color: Colors.white,),),
          Text(info, style: TextStyle(color: Theme.of(context).primaryColor),)
        ],
      ),
    );
  }

  void storyImgFunction (XFile? pickedFile) async {
    Navigator.of(context).pop();
    if (pickedFile!=null){
      Uint8List? image = await pickedFile.readAsBytes();
      image.isNotEmpty?Get.to(EditStory(pickedImage: image,)):null;
    }

  }

  void storyVidFunction (XFile? pickedVideo) async {
    Navigator.of(context).pop();
    if (pickedVideo!=null){
      _utils.loadingCircle (context);
      Navigator.pop(context);
      Get.to(EditStory(pickedVideo:pickedVideo,));
    }

  }

  void storyMediaPick () async {
    Navigator.of(context).pop();
    final mediaFile = await _imagePicker.pickMedia();

    if (mediaFile != null ) {
      final mimeType = mime(mediaFile.path);

      if (mimeType!.startsWith('image/')){
        Uint8List? image = await mediaFile.readAsBytes();
        Get.to(EditStory(pickedImage: image,));

      }else if (mimeType.startsWith('video/')){
        Get.to(EditStory(pickedVideo:mediaFile, ));

      }else{
        _utils.scaffoldMessenger(context,'file type not supported', 20.h, 80.w, 2, null);
      }
      print(mimeType);
    }
  }

  Widget storyWidget (text, userDoc, contactDoc,QueryDocumentSnapshot doc, Stream<QuerySnapshot<Map<String, dynamic>>> streamStories){

    final stream = streamStories;
    final streamThumbnailLocalPath = _fireStore.collection('stories').doc(_firebaseAuth.currentUser!.email)
        .collection('localPaths').doc('thumbnailTimeStamp').snapshots();


      stream.listen((value) async {
      final mostRecentStoryDoc = value.docs.first;


      if (mostRecentStoryDoc['file']!=null){

    

      if(mostRecentStoryDoc['timeStamp']!=doc['timeStamp']||mostRecentStoryDoc['file']['thumbnailUrl']!=doc['lastStoryThumbnail'].toString()){

      await doc.reference.update({
      'timeStamp':mostRecentStoryDoc['timeStamp'],
      'lastStoryThumbnail':mostRecentStoryDoc['file']['thumbnailUrl'],
      });
     

      }
      }else{
      if(mostRecentStoryDoc['timeStamp']!=doc['timeStamp']){
      await doc.reference.update({
      'timeStamp':mostRecentStoryDoc['timeStamp'],
      'lastStoryThumbnail':null,
      'text':{
      'text':mostRecentStoryDoc['text.text'] ,
      'textColor':mostRecentStoryDoc['text.textColor'],
      'backgroundColor':mostRecentStoryDoc['text.backgroundColor'],
      }
      });
      }
      }
      });




    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: doc.reference.collection('userStory')
          .where('timeStamp', isGreaterThan: DateTime.now().subtract(const Duration(hours: 24)))
          .orderBy('timeStamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData){
          final storyDocs = snapshot.data!.docs;
          final storyDocIds = storyDocs.map((doc) => doc.id).toList();
          return GestureDetector(
            onTap: ()=>Get.to(StoryPageView( storyDocs: storyDocs,doc: doc,currentUser: userDoc,contactDoc:contactDoc, username: text,  )),
            child: Padding(
              padding:  EdgeInsets.only(right: 5.w),
              child: Stack(

                children: [
                  Container(
                      height: 90.h,
                      width: 80.w,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white38),
                          shape: BoxShape.rectangle,
                          color: Colors.white10,
                          borderRadius:
                          BorderRadiusDirectional.circular(15.w,)),
                      child: ClipRRect(borderRadius: BorderRadiusDirectional.circular(15.r,),

                        child: doc['lastStoryThumbnail']==null?Container(
                          padding:  EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
                          color:_utils.convertToColor(doc['text.backgroundColor']),
                          child: Center(
                              child:Text( doc['text.text'],
                                style: TextStyle(color:_utils.convertToColor(doc['text.textColor']),
                                    fontSize: 9.sp),
                                overflow:TextOverflow.ellipsis ,maxLines: 4,
                              )),
                        ):
                        StreamBuilder(
                          stream: streamThumbnailLocalPath,
                          builder: (context, snapshot) {

                            final field = doc.id.substring(0, doc.id.length-4);


                            void cacheStoryThumbnail (snapShot){
                              _pathProvider.storeImageInProvider(doc['lastStoryThumbnail'], '${doc.id}_storyThumbnail', context, 'cache')
                                  .then((value) => value!=null? snapShot.data!.reference.set({
                                field:{
                                  'path': value.path,
                                  'timeStamp': doc['timeStamp'],

                                }
                              }):null);}

                              void cacheUpdatedThumbnail (snapShot){
                                _pathProvider.storeImageInProvider(doc['lastStoryThumbnail'], '${doc.id}_storyThumbnail', context, 'cache')
                                    .then((value) => value!=null? snapShot.data!.reference.update({
                                 field:{
                                    'path': value.path,
                                    'timeStamp': doc['timeStamp'],

                                  }
                                }):null);
                              }


                            if (snapshot.hasData){
                              final localDirectory = snapshot.data!.data();
                              if (localDirectory==null){
                                cacheStoryThumbnail(snapshot);
                                print('localDirectory=null');
                              }else if (localDirectory.keys.contains(field)){
                                localDirectory[field]['timeStamp']!=doc['timeStamp']
                                    ?cacheUpdatedThumbnail(snapshot):null;
                                print('localDirectory=notnull');

                              }else if (!localDirectory.keys.contains(field)){
                                cacheUpdatedThumbnail(snapshot);
                                print('localDirectory doesnt contain key');

                              }
                              final localFile = localDirectory!=null? File(localDirectory.keys.contains(field)
                                  ?localDirectory[field]['path'].toString():'null'):File('null');

                                  return localFile.existsSync()?Image.file(localFile, fit: BoxFit.cover,):const Text('');
                            }
                            else{
                            return const Text('');}
                          },) ,
                      )

                  ),
                  Positioned(top:60.h ,left:12.w,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle,),

                              child: CircleAvatar(
                                radius: 17.r,
                                backgroundImage: userDoc['Profile Picture']!=null
                                    ? profilePicDisplay(userDoc['Email'].toString(), contactDoc, userDoc['Profile Picture']['dpLastUpdateTime'],
                                    userDoc['Profile Picture']['imageUrl'].toString(), false) : null,
                                child: userDoc['Profile Picture'] == null ? Icon(Icons.person,
                                    color: Theme.of(context).splashColor, size: 25.w) : null,)),

                          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(

                            stream: _fireStore.collection('stories').doc(_firebaseAuth.currentUser!.email)
                                .collection('localPaths').doc(doc.id).snapshots(),
                            builder: (context, snapshot) {

                              if(snapshot.hasData){
                                final docMap = snapshot.data!.data();
                                var filteredMap = {};
                                docMap?.forEach((key, value) {
                                  if (!storyDocIds.contains(key)) return;

                                  filteredMap[key] = value;

                                });

                                var sortedMap = filteredMap.entries.toList();
                                print(sortedMap.length);

                                return CustomPaint(
                                  size:  Size(60.w,60.h),
                                  painter: StoryPainter(
                                      thickness: 2.dm,
                                      numberOfSegments: storyDocs.length.toDouble(),
                                    whiteSegment: sortedMap.length
                                  ),
                                );
                              }else{
                               return const SizedBox(height: 0, width: 0,);
                              }
                            }
                          )
                        ],
                      )),

                  Positioned(top: 110.h,
                    child: SizedBox(width: 75.w,
                        child:  Text(text,maxLines: 2,textAlign: TextAlign.center,overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Theme.of(context).primaryColor),)),
                  )
                ],
              ),
            ),
          );

        }else{
          return const Text('loading...');
        }

      }
    );
  }
}
