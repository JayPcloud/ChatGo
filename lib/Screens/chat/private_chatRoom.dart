import 'dart:async';
import 'dart:io';
import 'package:chatgo/Screens/chat/screen_Video_player.dart';
import 'package:chatgo/Screens/otherScreens/blank_loadingScreen.dart';
import 'package:chatgo/Screens/otherScreens/otherUsers_profilePage.dart';
import 'package:chatgo/Screens/otherScreens/profile.dart';
import 'package:chatgo/Screens/top_tabs.dart';
import 'package:chatgo/Services/firebase/chat_Service.dart';
import'package:chatgo/Services/firebase/firebase_storage.dart';
import 'package:chatgo/Services/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../Controlller_logic/utils.dart';
import '../../Services/connectivity_check.dart';
import '../../Services/firebase/firebaseFirestore.dart';
import 'profile_pic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controlller_logic/controller.dart';

class ChatPage extends StatefulWidget {
  String contactName;
  String? imageUrl;
  //either QueryDocSnapshot or Map (userData)
  dynamic userData;
  List? contactList;
  String? dpLocalPath;
  QueryDocumentSnapshot<Map<String, dynamic>>? contactDoc;
  String? navigatingFrom;

  ChatPage(
      {super.key,
      required this.contactName,
      this.imageUrl,
      required this.userData,
        this.contactList,
        this.dpLocalPath,
        this.contactDoc,
        this.navigatingFrom
      });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  AppLifecycleState? state;
  ChatController chatController = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();

  //chat & auth services
  final _firebaseAuth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  final chatServices = ChatService();
  final _firebaseStorage = FirebaseStorageService();
  final _fireStoreServices = FireStoreService();
  final _pathProvider = PathProvider();
  final _networkConnectivity = ConnectivityController();

  // for textField focus
  FocusNode myFocusNode = FocusNode();
  bool showSendIcon = false;

  // show a scroll down floating action button
  var showFloatingButton = false.obs;

  var showActiveStatus = false.obs;

  final getXController = ChatController();

  final _utils = Utils();

  //scroll Controller
  ScrollController scrollController = ScrollController();

  void scrollDown() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.bounceOut
    );
  }

  @override
  void initState() {
    //add Listener to focus Node
    WidgetsBinding.instance.addObserver(this);
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      scrollDown();
    });

      internetCheck();

    Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      internetCheck();
    },);

    scrollController.addListener(() {
      if(scrollController.position.pixels<scrollController.position.maxScrollExtent-500.h){
        showFloatingButton.value=true;
      }else{
        showFloatingButton.value=false;}
    });
   super.initState();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }



  //sendMessage
  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
       await chatServices.sendMessage(
          widget.userData['Email'],
          _messageController.text.trim(),
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null);
      _messageController.clear();
      scrollDown();
      if (!widget.contactList!.contains(widget.userData['Email'])) {
        await _fireStoreServices.addToContact(
          currentUser: _firebaseAuth.currentUser!.email!,
          contact: widget.userData['Email'],
        );
        await _fireStoreServices.addToContact(
            currentUser: widget.userData['Email'],
            contact: _firebaseAuth.currentUser!.email!);

        print(widget.contactList);
        print('user added to contact list of current users');
      } else {
        print("User already exists in contact list");

        await _fireStore
            .collection("User's Contacts")
            .doc(_firebaseAuth.currentUser!.email!)
            .collection('contacts')
            .doc(widget.userData['Email'])
            .update({'time': DateTime.now()});
        final update =  _fireStore
            .collection("User's Contacts")
            .doc(widget.userData['Email'])
            .collection('contacts')
            .doc(_firebaseAuth.currentUser!.email!)
            .update({'time': DateTime.now()});

        update.onError((error, stackTrace) =>
         _fireStoreServices.addToContact(
        currentUser: widget.userData['Email'],
            contact: _firebaseAuth.currentUser!.email!)
        );
      }
      print(widget.contactList);
    }
  }

  Future<void> sendImage(ImageSource imageSource) async {
    final User? currentUser = _firebaseAuth.currentUser;

    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: imageSource);
    Navigator.pop(context);
    final Uint8List? imageByte = await image?.readAsBytes();
    if (image != null) {
      //final localPath = await _pathProvider.getDirectory('images/${_firebaseAuth.currentUser}.chat.${widget.otherUserID}.${DateTime.now()}');
      Get.to(ShowPicture(
        mediaShowState: MediaShowState.preview,
        imageByte: imageByte,
        contactList: widget.contactList!,
        otherUserID: widget.userData['Email'],
        //localPath:  localPath,
      ));
    }
  }

  void sendVideo({
    required ImageSource source,
  }) async {
    final imagePicker = ImagePicker();
    final pickedVideo = await imagePicker.pickVideo(
      source: source,
    );
    if (pickedVideo != null) {
      Get.to(VideoPlayScreen(
        mediaShowState: MediaState.preview,
        videoFile: pickedVideo,
        otherUserID: widget.userData['Email'],
        contactList: widget.contactList,
      ));

    }
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.contactList!);
    final textController = TextEditingController(text: widget.contactName);
    bool isMe = widget.userData['Email']==_firebaseAuth.currentUser!.email;

    final contactDoc = _fireStore.collection("User's Contacts").doc(_firebaseAuth.currentUser!.email).
    collection('contacts').doc(widget.userData['Email']);
    final otherUserContactsDoc = _fireStore.collection("User's Contacts").doc(widget.userData['Email']).
    collection('contacts').doc(_firebaseAuth.currentUser!.email);
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        floatingActionButton: Obx(() =>
        showFloatingButton.value==true?Padding(
          padding:  EdgeInsets.only(bottom: 40.h),
          child: SizedBox(width: 40.w,height: 40.h,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.deepPurple[300],
              shape:const CircleBorder(),
                  onPressed: scrollDown,
                  child:  Icon(Icons.keyboard_double_arrow_down_outlined,color: Colors.white,size: 20.w,),
                ),
          ),
        ):const SizedBox(height: 0,width: 0,)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          actions: [
            isMe?const SizedBox(width: 0,height: 0,):PopupMenuButton(
              color: Theme.of(context).focusColor,
              iconColor: Colors.white,
              itemBuilder: (context) => [
                widget.contactDoc!=null?
                widget.contactDoc!.data().containsKey('saved')?
                PopupMenuItem(
                    onTap: (){

                      _utils.confirmDialog(context, 'Remove contact ?',
                              () async {
                        _utils.loadingCircle(context);
                                await otherUserContactsDoc.get().then((value) async {
                                  if (value.data()!=null){
                                    value.data()!.containsKey('BothUsersSavedByEachOther')?
                                    value.data()!.remove('BothUsersSavedByEachOther'):null;
                                  }else{}});
                                   await contactDoc.delete().then((value) {
                                     Navigator.of(context).pop();
                              _utils.scaffoldMessenger(context, 'deleted', 60.h, 80.w, 2, const Icon(Icons.person_add_disabled_rounded,color: Colors.deepPurple,));
                             Get.offUntil(MaterialPageRoute(builder: (context) => const ContactList(),), (route) => route.settings.name=='/');
                            });
                           // Navigator.of(context).pop();
                          }, false);

                    },
                    child: Row(
                      children: [
                        const Icon(Icons.person_remove_outlined),
                        SizedBox(width: 5.w,),
                        Text(
                          'remove',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ))
                    :popupMenuItem(
                        textController,
                        () async {
                          _utils.loadingCircle(context);
                        textController.text.trim().isNotEmpty?await otherUserContactsDoc.get().then((value) async {
                        if (value.data()!=null){
                          value.data()!.containsKey('saved')?await value.reference.update({
                            'BothUsersSavedByEachOther': true
                          }).then((value) async => await contactDoc.update({
                            'BothUsersSavedByEachOther': true,
                            'saved': true,
                            'savedNameAs': textController.text.trim()
                          })):await contactDoc.update({
                            'saved': true,
                            'savedNameAs': textController.text.trim()
                          });
                        }else{
                          await contactDoc.update({
                            'saved': true,
                            'savedNameAs': textController.text.trim()
                          });
                        }

                      } ).then((value) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                          _utils.scaffoldMessenger(context, 'saved', 40.h, 80.w, 2,
                              const Icon(Icons.person_rounded,
                                color: Colors.deepPurple,));
                        }): null;

                    }
                )

                : widget.navigatingFrom=='otherUsersProfile'
                    ?popupMenuItem(
                    textController,
                        () async {
                          textController.text.trim().isNotEmpty?await _fireStoreServices.addToContact(
                              currentUser: _firebaseAuth.currentUser!.email!,
                              contact: widget.userData['Email'],

                          ).then((value) =>
                          _fireStore.collection("User's Contacts").doc(_firebaseAuth.currentUser!.email!).collection('contacts')
                                  .doc(widget.userData['Email']).update({
                                'saved': true,
                                'savedNameAs': textController.text.trim()
                              }).then((value) {
                            _utils.scaffoldMessenger(context, 'saved', 40.h, 110.w, 2,
                                const Icon(Icons.person_rounded,
                                  color: Colors.deepPurple,));
                            Navigator.of(context).pop();
                          })
                          ):null;
                        })
                    : const PopupMenuItem(child: Icon(Icons.contacts_outlined)),
                PopupMenuItem(
                  onTap: ()=> Get.to(OtherUserProfile(file: File(widget.dpLocalPath??'...'),
                      doc: widget.userData, contactList: widget.contactList!)),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin),
                        SizedBox(width: 5.w,),
                        Text('View',
                          style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    )),
                // PopupMenuItem(
                //   onTap: (){
                //     List<String> ids = [_firebaseAuth.currentUser!.email!, widget.otherUserID];
                //     ids.sort();
                //     String chatRoomID = ids.join('_');
                //     showDialog(context: context,
                //       barrierDismissible: true,
                //       builder:(context) {
                //         return Center(
                //           child: SizedBox( width:230.w, height:100.h,
                //             child: Container(
                //               decoration: BoxDecoration( color: Colors.deepPurple[200],borderRadius: BorderRadiusDirectional.circular(20) ),
                //               child: Column(
                //                 children: [
                //                   SizedBox(height: 10.h,),
                //                    Text('Clear chats for me only ?', style: TextStyle(color: Colors.white, fontSize: 15.sp),),
                //                   SizedBox(height: 20.h,),
                //                   Row(
                //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                     children: [
                //                     MaterialButton(
                //                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                //                       onPressed:(){
                //                         _utils.loadingCircle(context);
                //                         _fireStore.collection('chat_rooms').doc(chatRoomID).collection('messages')
                //                             .get().then((value) async {
                //                           final docs = value.docs;
                //                           Navigator.of(context).pop();
                //                           _utils.scaffoldMessenger(context,
                //                               'deleting chats... ', 20.h, 200.w, 3,CircularProgressIndicator(strokeWidth: 2,));
                //                           for (var element in docs) {
                //                             final doc = element.data();
                //                             bool isCurrentUser = doc['senderID'] == _firebaseAuth.currentUser!.email;
                //                             // isCurrentUser? batch.update(element.reference, {
                //                             //   'removeWidgetForMe': true
                //                             // }): batch.update(element.reference, {
                //                             //   'removeWidgetForOthers': true
                //                             // });
                //                             //  return batch.commit();
                //                             await element.reference.update(isCurrentUser?{
                //                               'removeWidgetForMe': true
                //                             }:{
                //                               'removeWidgetForOthers': true
                //                             }).then((value) => Get.back());
                //                           }
                //
                //
                //                         }  );
                //                       },
                //                       child:const Text('Yes', style: TextStyle(color: Colors.deepPurple),),
                //                     ),
                //                     MaterialButton(
                //                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                //                       onPressed:()=>Navigator.of(context).pop(),
                //                       child: const Text('cancel',style: TextStyle(color: Colors.deepPurple)),
                //                     ),
                //                   ],)
                //                 ],
                //               ),
                //             ),
                //           ),
                //         );
                //       },);
                //
                //   },
                //     child: Text(
                //   'Clear chats',
                //   style: TextStyle(color: Theme.of(context).primaryColor),
                // )),
              ],
            )
          ],
          leadingWidth: 310.w,
          leading: Row(
            children: [
              IconButton(
                color: Colors.white70,
                onPressed: () {
                  myFocusNode.hasFocus?myFocusNode.unfocus():Navigator.pop(context);

                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Padding(
                padding:  EdgeInsets.all(7.0.w),
                child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: widget.imageUrl!=null&&File(widget.dpLocalPath!).existsSync()
                        ? Image.file(File(widget.dpLocalPath!)).image
                        :widget.imageUrl!=null&&!File(widget.dpLocalPath!).existsSync()
                        ?NetworkImage(widget.imageUrl!):null,

                    child:widget.imageUrl==null ? Icon(Icons.person,
                        color: Theme.of(context).splashColor,
                        size: 30.dm):null,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: isMe?()=>Get.to(const ProfilePage()):null,
                  child: Padding(
                    padding:  EdgeInsets.only(left: 8.0.w,right: 8.0.w,top: 8.h,bottom: 3.h ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMe?'${widget.contactName}(Me)':
                          widget.contactDoc!=null?
                          widget.contactDoc!.data().containsKey('saved')
                              ?widget.contactDoc!['savedNameAs']:widget.contactName
                          :widget.contactName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style:  TextStyle(
                            color: Colors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('users').doc(widget.userData['Email']).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData){
                              final status = snapshot.data!.data();
                              return  Obx(() =>
                              showActiveStatus.value == true
                                  ? ConnectivityController().convertLastActiveTime(status!['lastSeen'],status['isOnline'] )
                                  : const Text(''),);
                            }else{ return const Text('');}
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
          elevation: 15.w,
          shadowColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 3.w, right: 3.w, bottom: 5.h),
              child: TextField(
                maxLines: 1,
                onChanged: (value) => chatController.ifOnChanged(value),
                focusNode: myFocusNode,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Theme.of(context).primaryColor,
                ),
                controller: _messageController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.chat_outlined),
                  // prefixIcon: IconButton(
                  //     onPressed: () {},
                  //     icon: Icon(
                  //       Icons.emoji_emotions_outlined,
                  //       color: Theme.of(context).indicatorColor,
                  //     )),
                  contentPadding:
                       EdgeInsetsDirectional.only(start: 5.w, end: 5.w),
                  fillColor: Colors.black12,
                  filled: true,
                  hintText: '  message',
                  hintStyle: TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontWeight: FontWeight.w500,
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  suffixIcon: Obx(() =>
                  chatController.showSendIcon.value == true
                    ? IconButton(
                     onPressed: () => sendMessage(),
                     icon:const Icon(
                        Icons.send,
                        color: Colors.deepPurple,
                    ),
                  ):IconButton(
                    icon:const Icon(
                      Icons.attach_file_outlined,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () => getXController.showBottomSheet(
                      context: context,
                      choseImageFunction: () =>
                          sendImage(ImageSource.gallery),
                      cameraImageFunction: () =>
                          sendImage(ImageSource.camera),
                      videoFunction: () =>
                          sendVideo(source: ImageSource.camera),
                      pickVideoFunction: () =>
                          sendVideo(source: ImageSource.gallery),
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }


  Widget _buildMessageList() {
    String senderID = _firebaseAuth.currentUser!.email!;
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: StreamBuilder(
        stream: chatServices.getMessages(senderID, widget.userData['Email']),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
            //return List View
          } else if (snapshot.hasData) {

           final List<Map<String, dynamic>>messages = snapshot.data!.docs.map((doc) {
             Map<String, dynamic> data = doc.data();
             data['id'] = doc.id;
             data['doc'] = doc;
             return data;
            }
           ).toList();
          Map<String, List<Map<String, dynamic>>> groupedMessages = {};
          for (var message in messages){

            if (!groupedMessages.containsKey(DateFormat('EEE, d/M/yy').format(message['timeStamp'].toDate().toLocal()))){
              groupedMessages[DateFormat('EEE, d/M/yy').format(message['timeStamp'].toDate().toLocal())] = [];
            }
            groupedMessages[DateFormat('EEE, d/M/yy').format(message['timeStamp'].toDate().toLocal())]!.add(message);
          }
            return ListView(
              controller: scrollController,
              children:
              groupedMessages.entries.map((entry){
                return Column(
                  children: [
                    Padding(
                      padding:  EdgeInsets.only(left: 100.w,right: 100.w, top: 20.h),
                      child: Card(
                       color: Colors.transparent,
                        elevation: 10.dm,
                        child: Center(
                          child: Text(
                            entry.key.toString(),
                               style: TextStyle(
                                 fontSize: 11.sp,
                                color: Theme.of(context).primaryColor,),)),),
                    ),
                    ...entry.value.map((message) {
                      return _buildMessageItem(message, senderID, );// snapshot.data!.docs
                    })
                  ],
                );

              }) .toList()
              // snapshot.data!.docs
              //     .map((doc) => _buildMessageItem(
              //           doc,
              //           senderID,
              //         ))
              //     .toList(),
            );
          } else {
            return const Center(child: Text(""));
          }
        },
      ),
    );
  }

//build Message Item
  Widget _buildMessageItem(
    Map<String, dynamic> doc,
    String currentUserID,
  ) {
    Map<String, dynamic> data = doc;
    bool isCurrentUser = data['senderID'] == currentUserID;
    Timestamp timestamp = data['timeStamp'];
    DateTime dateTime = timestamp.toDate().toLocal();

    var videoDownloadInProgress = false.obs;
    var selected = false.obs;

    ImageProvider<Object> imageProvider (File file, fileType){
      if (!file.existsSync()){
        _pathProvider.storeImageInProvider(
            data['imageUrl']??data['videoUrl']['thumbnail'],
            '${doc['id']}_chat${widget.userData['Email']}.img',
            context,
            'permanent');
        return NetworkImage(data['imageUrl']??data['videoUrl']['thumbnail'],);
      }else{
        return FileImage(file);
      }
    }



    if (!isCurrentUser && data['unread'] == true) {
      chatServices.getAndUpdateUnreadStatus(
          _firebaseAuth.currentUser!.email!,
          widget.userData['Email'],
          'unread',
          true,
          {'unread': false, 'showUnreadMsgIndicator': true, 'received': true});
    }
    return PopScope(
      onPopInvoked: (didPop) {
        if (!isCurrentUser && data['showUnreadMsgIndicator'] == true) {
          chatServices.getAndUpdateUnreadStatus(
              _firebaseAuth.currentUser!.email!,
              widget.userData['Email'],
              'showUnreadMsgIndicator',
              true,
              {'showUnreadMsgIndicator': false});
        }
      },
      child: GestureDetector(
        onLongPressStart: (details) {

          void removeWidget (void Function()? function){
            showModalBottomSheet(context: context,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return IconButton(onPressed: function,
                    icon: Icon(Icons.delete, color: Colors.white,size: 30.w,) );
              },
            );
          }

          if (data.containsKey('deletedForMe')&&isCurrentUser){
            removeWidget(() {
              data['doc'].reference.update({'removeWidgetForMe': true});
              Navigator.of(context).pop();
            });

          }else if (data.containsKey('deletedForOthers')&&!isCurrentUser){
            removeWidget(() {
                  data['doc'].reference.update({'removeWidgetForOthers': true});
                  Navigator.of(context).pop();
                });

          }else{

            selected.value = true;
            showModalBottomSheet(context: context,
                showDragHandle: isCurrentUser?false:true,
                constraints: BoxConstraints(maxHeight: 150.h, maxWidth: 270.w, minHeight: 100.h ),
                backgroundColor: Colors.white70 ,
                builder: (context) {
                  Widget row(child1, child2) {
                    return Row(children: [child1, child2],);
                  }
                  var textStyle =   TextStyle(color: Colors.deepPurple[400] );
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      isCurrentUser
                       ?Column(mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
                        children: [
                          row( const Icon(Icons.delete,color: Colors.black,), Text('Delete message?', style: textStyle,),),
                          InkWell(  onTap: (){
                            data['doc'].reference.update({'deletedForMe': true});
                            Navigator.of(context).pop();
                             _utils.scaffoldMessenger(context, 'message deleted', 40.h, 120.w, 1, null);},
                              child: row(const
                              Icon(Icons.check_box_outline_blank_rounded, color: Colors.black,),
                                  Text('delete for me',style: textStyle,))),

                          InkWell(   onTap: () async {
                            await data['doc'].reference.delete();
                            Navigator.of(context).pop();
                            final directory = await getApplicationDocumentsDirectory();
                            final file = File('${directory!.path}/${doc['id']}_chat${widget.userData['Email']}.img');
                            file.existsSync()?file.delete():null;
                            _utils.scaffoldMessenger(context, 'message deleted',40.h, 120.w, 1, null);
                          },
                              child: row(const Icon(Icons.check_box_outline_blank_rounded, color: Colors.black,),
                                  Text('delete for all', style: textStyle,)))
                        ],)
                          :InkWell(  onTap: () {
                           data['doc'].reference.update({'deletedForOthers': true});
                           Navigator.of(context).pop();
                      },
                          child: row(const
                          Icon(Icons.delete, color: Colors.black,),
                              Text('delete for me',style: textStyle,))),

                      data['imageUrl'] == null && data['videoUrl']['videoUrl']==null
                          ?InkWell(
                          onTap: () {
                            Clipboard.setData( ClipboardData(text: data['message']) );
                            _utils.scaffoldMessenger(context, 'Text copied to clipboard', 60.h, 50.w,1, null);
                            Navigator.of(context).pop();
                          },
                          child: row(const Icon(Icons.copy),  Text('copy',style: textStyle,))):
                      const SizedBox(width: 0,height: 0,)
                    ],
                  );
                });
          }
          },

        child: Align(
            alignment:
                isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,

            child: data['message'] != null
                ? textTypeChatWidget(isCurrentUser, data, dateTime, false)

                : data['imageUrl'] != null

                    ? data.containsKey('deletedForMe') && isCurrentUser
                ||data.containsKey('deletedForOthers') && !isCurrentUser
                ||data.containsKey('removeWidgetForMe') && isCurrentUser
                ||data.containsKey('removeWidgetForOthers') && !isCurrentUser?
            textTypeChatWidget(isCurrentUser, data, dateTime, true)
                :Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                    height: 232.h,
                                    width: 193.4.w,
                                    color: Colors.white24,
                                    child:  Center(
                                      child: Text(
                                        '',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12.sp),
                                      ),
                                    )),
                                Positioned(
                                  top: 2.h,
                                  left: 2.w,
                                  child: FutureBuilder(
                                    future: getApplicationDocumentsDirectory(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData){
                                        final directory = snapshot.data;
                                        final file = File('${directory!.path}/${doc['id']}_chat${widget.userData['Email']}.img');
                                        return GestureDetector(
                                          onTap: () => Get.to(ShowPicture(
                                            imageUrl: data['imageUrl'],
                                            localPath: file.path
                                            // isCurrentUser
                                            //     ? data['localPath']['sender'].toString()
                                            //     : data['localPath']['receiver']
                                            //     .toString(),
                                          )),
                                          child: Container(
                                            height: 230.h,
                                            width: 190.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadiusDirectional.circular(
                                                    20.r),
                                                image: DecorationImage(
                                                    image: imageProvider(file,'img'),

                                                    // isCurrentUser
                                                    //     ? FileImage(File(
                                                    //     data['localPath']['sender']
                                                    //         .toString()))
                                                    //     : !isCurrentUser &&
                                                    //     data['localPath']
                                                    //     ['stored'] ==
                                                    //         true
                                                    //     ? FileImage(File(
                                                    //     data['localPath']
                                                    //     ['receiver']
                                                    //         .toString()))
                                                    //     : FileImage(File(
                                                    //     data['localPath']
                                                    //         .toString())),

                                                    fit: BoxFit.cover)),
                                          ),
                                        );
                                      }else{
                                        return Container(
                                            height: 230.h,
                                            width: 190.w,
                                          color: Colors.black38.withOpacity(0.5),
                                        );
                                      }
                                    },

                                  ),
                                ),
                              ],
                            ),
                            mediaTimeDisplay(isCurrentUser, dateTime, data)
                          ],
                        ),
                      )

                    : data.containsKey('deletedForMe')&&isCurrentUser
                ||data.containsKey('deletedForOthers')&& !isCurrentUser
                ||data.containsKey('removeWidgetForMe') && isCurrentUser
                ||data.containsKey('removeWidgetForOthers') && !isCurrentUser?
            textTypeChatWidget(isCurrentUser, data, dateTime, true)
                :Padding(
                        padding:  EdgeInsets.symmetric(
                            horizontal: 10.h, vertical: 8.h),
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: getApplicationDocumentsDirectory(),
                              builder: (context, snapshot) {

                                Widget center (){
                                  return Center(
                                      child:
                                      !isCurrentUser &&
                                          data['videoUrl']['downloaded'] == false
                                          ?  Obx(
                                            () => videoDownloadInProgress.value == false ? IconButton(
                                            onPressed: () async {
                                              videoDownloadInProgress.value = true;
                                              syncVideoLocally(
                                                  data['videoUrl']['videoUrl'],
                                                  'receiver',
                                                  currentUserID,
                                                  doc,
                                                  'sharedTo.',
                                                  'mp4');
                                            },
                                            icon: Icon(
                                              Icons.download_for_offline_outlined,
                                              size: 40.w,
                                              color: Colors.white60,
                                            )
                                        ):const CircularProgressIndicator(),
                                      ) : IconButton(
                                          onPressed: ()async {
                                            if(isCurrentUser){
                                              if( File(data['localPath']['sender'].toString()).existsSync()){
                                                Get.to( VideoPlayScreen(
                                                  localPath:
                                                  data['localPath']['sender'].toString(),
                                                  videoUrl: data['videoUrl']['videoUrl'],
                                                  //doc: doc,
                                                ));
                                              }else {Get.to( BlancLoading(
                                                videoUrl: data['videoUrl']['videoUrl'],
                                                otherUserID: widget.userData['Email'],
                                                isCurrentUser: isCurrentUser,
                                                docID: doc['id'],
                                              ));}

                                            }else{
                                              if (File(data['localPath']['receiver'].toString()).existsSync()){
                                                Get.to(
                                                    VideoPlayScreen(
                                                      localPath: data['localPath']['receiver'].toString(),
                                                      videoUrl: data['videoUrl']['videoUrl'],
                                                      //doc: doc,
                                                    ));}
                                              else{Get.to( BlancLoading(
                                                videoUrl: data['videoUrl']['videoUrl'],
                                                otherUserID: widget.userData['Email'],
                                                isCurrentUser: isCurrentUser,
                                                docID: doc['id'],
                                              ));}

                                            }
                                          },
                                          icon:  Icon(
                                            Icons.play_arrow_rounded,
                                            size: 70.w,
                                            color: Colors.white,
                                          )));
                                }

                                if (snapshot.hasData){
                                  final directory = snapshot.data;
                                  final file = File('${directory!.path}/${doc['id']}_chat${widget.userData['Email']}.img');
                                  return Container(
                                      height: 230.h,
                                      width: 170.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadiusDirectional.circular(20.r),
                                        color: Colors.white24,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider(file, 'video')

                                        ),
                                      ),
                                      child: center()
                                  );
                                }else{
                                  return Container(
                                    height: 230.h,
                                    width: 190.w,
                                    color: Colors.black38.withOpacity(0.5),
                                    child: center(),
                                  );
                                }
                              },

                            ),
                            mediaTimeDisplay(isCurrentUser, dateTime, data)
                          ],
                        ),
                      )
        ),
      ),
    );
  }

  Widget textTypeChatWidget (isCurrentUser, data, dateTime, deleted){

    Widget card (Widget widget){
      return data.containsKey('removeWidgetForMe')&&isCurrentUser
          ?const SizedBox(height: 0, width: 0,)

          :data.containsKey('removeWidgetForOthers')&&!isCurrentUser
          ?const SizedBox(height: 0, width: 0,)

      :Card(
          shape: RoundedRectangleBorder(
              borderRadius: isCurrentUser
                  ?  BorderRadiusDirectional.only(
                topStart: Radius.circular(15.r),
                bottomEnd: Radius.circular(15.r),
                bottomStart: Radius.circular(15.r),
              )
                  :  BorderRadiusDirectional.only(
                topEnd: Radius.circular(15.r),
                bottomEnd: Radius.circular(15.r),
                bottomStart:  Radius.circular(15.r),
              )),
          elevation: 8.dm,
          color:
          data['showUnreadMsgIndicator'] == true && !isCurrentUser
              ? Colors.purpleAccent
              : isCurrentUser
              ? Colors.white
              : Colors.deepPurple,
          child:data.containsKey('deletedForMe')&&isCurrentUser
              ||data.containsKey('deletedForOthers')&& !isCurrentUser||deleted==true?

          SizedBox(width: 100.w, height: 30.h,
              child: const Center(child:  Text('deleted for me', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),)))
              :Padding(
              padding:  EdgeInsets.all(5.0.w),
              child: Column(

                mainAxisSize: MainAxisSize.min,
                children: [
                  data['storyReply'] != null?widget:const SizedBox(width: 0, height: 0,),
                  Padding(
                      padding:
                       EdgeInsets.only(right: 20.w, left: 10.w),
                      child: Text(data['message'])),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat().add_jm().format(dateTime),
                        style:  TextStyle(
                            fontSize: 10.sp, color: Colors.blue),
                      ),
                       SizedBox(
                        width: 3.w,
                      ),
                      data['received'] == false &&
                          isCurrentUser &&
                          data['unread'] == true
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
                          : isCurrentUser
                          ?  Icon(
                        Icons.access_time,
                        size: 12.w,
                      )
                          :  Text(
                        '',
                        style: TextStyle(fontSize: 5.sp),
                      )
                    ],
                  ),
                ],
              ))
      );
    }

    if (data['storyReply'] != null){

      void persistThumbnail (context) async {
        final directory =await getTemporaryDirectory();
        final file = File('${directory.path}/${data['id']}_statusRepliedTo${widget.userData['Email']}');
        !file.existsSync() ?_pathProvider.storeImageInProvider(data['storyReply']['thumbnailUrl'],
            '${data['id']}_statusRepliedTo${widget.userData['Email']}', context, 'temporary'): null;
      }
      data['storyReply']['thumbnailUrl']!=null? persistThumbnail(context): null;
      return card(
        Card(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          color: Colors.white10.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10.r)),
          child: data['storyReply']['thumbnailUrl']!=null?SizedBox(height: 40.h,
          child:  Padding(
            padding:  EdgeInsets.only(left: 5.w, top: 2.h, bottom: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
              SizedBox(width: 100.w,
                  child: Text(
                    data['storyReply']['text'],
                    style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, maxLines: 2,)),
              ClipRRect(borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(10.dm), bottomEnd:Radius.circular(10.dm) ),
                child: FutureBuilder(
                  future: getTemporaryDirectory(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      final directory = snapshot.data;
                      final file = File('${directory?.path}/${data['id']}_statusRepliedTo${widget.userData['Email']}');

                     return file.existsSync()?Image.file(file, fit: BoxFit.cover,width: 50.w,)
                      : Image.network(data['storyReply']['thumbnailUrl'], width: 50.w,filterQuality: FilterQuality.low,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => SizedBox(height: 40.h, width: 30.w,
                          child: Center(child: Icon(Icons.file_download_off_outlined, color: Colors.red[200],size: 15.w,),),) ,
                      ) ;
                    }else{
                      return const Text('');
                    }
                  },

                ),
              )
            ],),
          ) ): SizedBox(height: 40.h, width: 100.w,
            child: Center(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 3.w),
                child: Text(data['storyReply']['text'], style: TextStyle(color: Colors.white, fontSize: 12.sp,),
                overflow: TextOverflow.ellipsis,maxLines: 2,),
              ),
            ),
          ),
        )
      );

    }else{
      return card(const SizedBox());
    }



  }

  Widget mediaTimeDisplay(
      bool isCurrentUser, dateTime, Map<String, dynamic> data) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: isCurrentUser
                ?  BorderRadiusDirectional.all(Radius.circular(15.r))
                :  BorderRadiusDirectional.all(Radius.circular(15.r))),
        elevation: 8.dm,
        color: data['showUnreadMsgIndicator'] == true && !isCurrentUser
            ? Colors.purpleAccent
            : isCurrentUser
                ? Colors.white
                : Colors.deepPurple,
        child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 3.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat().add_jm().format(dateTime),
                  style:  TextStyle(fontSize: 10.sp, color: Colors.blue),
                ),
                data['received'] == false &&
                        isCurrentUser &&
                        data['unread'] == true
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
                            : isCurrentUser && data['received'] == false
                                ?  Icon(
                                    Icons.access_time,
                                    size: 12.w,
                                  )
                                : const Text(
                                    '',
                                  )
              ],
            )));
  }

  PopupMenuItem popupMenuItem (textController,void Function()? function){
    return PopupMenuItem(
        onTap: (){
          final focus = FocusNode(canRequestFocus: true);
          _utils.confirmDialog(
              context,

              Padding(
                padding:  EdgeInsets.only(left: 8.w),
                child: Row(children: [
                  Text('save As:',
                    style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                  ),
                  SizedBox(width: 130.w, height: 45.h,
                    child: Card(color: Colors.transparent,
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 2.w),
                        child: TextFormField(maxLines: 1,
                          focusNode: focus,
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).primaryColor),
                          decoration:  InputDecoration(
                              contentPadding:EdgeInsets.symmetric(horizontal: 3.w)
                          ),

                          controller: textController,
                        ),
                      ),
                    ),
                  )
                ],),
              ),
              function,
              true);
          focus.requestFocus();

        },
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1_outlined),
            SizedBox(width: 5.w,),

            Text('save',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ));
  }

  void syncVideoLocally(data, field, currentUserID, doc, string, mediaType) {
    _pathProvider
        .storeImageInProvider(
            data, '$string$currentUserID${DateTime.now()}.$mediaType', context,'permanent')
        .then((file) => file != null
            ? chatServices.updateMsgData(
                widget.userData['Email'],
                {
                  'localPath.$field': file.path,
                  'videoUrl.downloaded':  true,

                },
                doc['id'])
            : null);
  }

  void internetCheck()async{
    final isDeviceConnected = await InternetConnectionCheckerPlus().connectionStatus;
    if (isDeviceConnected == InternetConnectionStatus.disconnected) {
      showActiveStatus.value = false;
    } else if (isDeviceConnected == InternetConnectionStatus.connected) {
      showActiveStatus.value = true;
    }
  }
}
