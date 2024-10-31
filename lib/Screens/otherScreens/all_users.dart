import 'dart:io';
import 'package:chatgo/Screens/otherScreens/otherUsers_profilePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../Controlller_logic/controller.dart';
import '../../Services/firebase/chat_Service.dart';
import '../../Services/firebase/firebaseFirestore.dart';
import '../Chat/private_chatRoom.dart';

enum UsersPageState{
  search, listMyContacts
}

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final ChatController chatController = Get.put(ChatController());

  final _chatService = ChatService();

  final _firebaseAuth = FirebaseAuth.instance;

  final _fireStore = FireStoreService();

  final fireStore= FirebaseFirestore.instance;

  FocusNode focusNode = FocusNode();

  UsersPageState _usersPageState = UsersPageState.listMyContacts;

  final CollectionReference _allUsersRef = FirebaseFirestore.instance.collection("users");

  String searchQuery = '';

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if(focusNode.hasFocus){
        setState(() {
          _usersPageState = UsersPageState.search;
        });
      }else{setState(() {
        _usersPageState = UsersPageState.listMyContacts;
        _searchController.clear();
      });}
    });
  }
 @override
 void dispose() {
    super.dispose();
    focusNode.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding:  EdgeInsets.only(
              top: 50.h,bottom: 30.h,left: 10.w,right: 10.w
            ),
            child: SizedBox(
              height: 50.h,
              width: 350.w,
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery=value;
                  });
                },
                focusNode: focusNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r)),
                    contentPadding:
                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    prefixIcon: focusNode.hasFocus?null:IconButton(onPressed: () => Get.back(),
                        icon: Icon(Icons.arrow_back_outlined,color: Theme.of(context).primaryColor,)),
                    suffixIcon: Icon(Icons.search_sharp,
                      color: focusNode.hasFocus?Colors.deepPurple:Theme.of(context).primaryColor,),
                    hintText: 'Search others by their username',
                    hintStyle: TextStyle(color: Theme.of(context).indicatorColor,fontStyle: FontStyle.italic,fontWeight: FontWeight.normal)
                  )),
            ),
          ),
          Expanded(
            child:  _usersPageState==UsersPageState.search
                ?StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _chatService.getUsersContactData(_firebaseAuth.currentUser!),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return const Center(child: CircularProgressIndicator(),);
                    }else if (snapshot.hasError){
                      return Text(snapshot.error.toString());
                    }else if (snapshot.hasData){
                      List? allContactID = snapshot.data?.docs.map((docs) => docs['Email']).toList();
                      return Container(child:
                       searchUser(allContactID!),);
                    }else{return const Text("No data");}
                  }
                )
                :Column(
                  children: [
                     Row(
                      children: [

                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: const Text('Saved contacts',style: TextStyle(color:Colors.deepPurple),),
                        ),
                      ],
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection("User's Contacts").doc(_firebaseAuth.currentUser!.email).collection('contacts')
                          .where('saved', isEqualTo: true).snapshots(),
                          //_chatService.getUsersContactData(_firebaseAuth.currentUser!),
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
                              final contactSnapshot = snapshot;
                              List? allContactID = snapshot.data?.docs.map((docs) => docs['Email']).toList();
                              // check if contact list (which contains their UID only) is empty
                             if (allContactID!.isNotEmpty){
                               return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                   stream: fireStore.collection('users').where(FieldPath.documentId,
                                       whereIn: allContactID).snapshots(),
                                   builder: (context, snapshot) {
                                     if (snapshot.hasData){
                                       final users = snapshot.data?.docs.toList();
                                       return _fireStore.awaitDataDisplay(snapshot,
                                           ListView.builder(
                                             padding: EdgeInsets.zero,
                                             itemCount: users!.length,
                                             itemBuilder: (
                                                 BuildContext context,
                                                 int index,
                                                 ) {
                                               final doc = contactSnapshot.data!.docs.firstWhere((doc) =>doc.id==users[index]['Email']);
                                               bool isMe = users[index]['Email']==_firebaseAuth.currentUser!.email;

                                               return GestureDetector(
                                                 onTap: ()=>Get.to(ChatPage(
                                                     contactName: users[index]['User Name'],
                                                     userData: users[index],
                                                   contactList:allContactID ,
                                                   imageUrl:users![index]["Profile Picture"]!=null
                                                       ? users![index]["Profile Picture"]['imageUrl']:null ,
                                                   dpLocalPath: doc['profilePhoto']['localPath'],

                                                   contactDoc: doc,
                                                 )),
                                                 child: ListTile(
                                                     titleTextStyle:  TextStyle(
                                                         fontWeight: FontWeight.w500,
                                                         fontSize: 15.sp,
                                                         color: Colors.black87),
                                                     leading: GestureDetector(
                                                       onTap: ()=> Get.to(
                                                           OtherUserProfile(file:File(doc['profilePhoto']['localPath']),
                                                               doc: users[index], contactList:allContactID)),
                                                       child: Padding(
                                                         padding: const EdgeInsets.only(left: 0, right: 0),
                                                         child: dp(users, index),
                                                       ),
                                                     ),
                                                     title: Text(
                                                       isMe?'${users[index]['User Name']}(Me)':doc.data()['savedNameAs'],
                                                       style: TextStyle(
                                                           color: Theme.of(context).primaryColor),
                                                     ),
                                                     subtitle: Text(
                                                       users[index]['Email'].toString(),
                                                       style: TextStyle(
                                                           color: Theme.of(context).primaryColor,
                                                           fontSize: 12.sp),
                                                     ),

                                                     trailing:PopupMenuButton(
                                                       itemBuilder: (BuildContext context) =>[
                                                           PopupMenuItem(
                                                             onTap: ()=> Get.to(
                                                                 OtherUserProfile(file:File(doc['profilePhoto']['localPath']),
                                                                     doc: users[index], contactList:allContactID)),
                                                             child:const Row(
                                                             children: [
                                                             Icon(Icons.person),
                                                             Text('Profile'),
                                                           ],
                                                         )),
                                                       ]



                                                     ),
                                                     //trailing:const Icon(Icons.contact_page_outlined)
                                                 ),
                                               );
                                             },
                                           ));}else {return const Center(child: Text('Loading...'));}

                                   }
                               );
                             }else{return Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Padding(
                                   padding: EdgeInsets.only(bottom: 30),
                                   child: Text('Your contact list is empty ',style: TextStyle(fontStyle: FontStyle.italic,color: Colors.blueGrey),),
                                 ),

                                 InkWell(
                                     onTap: () {setState(() {
                                       focusNode.requestFocus();
                                     });},
                                     child:  Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         const Text('search users', style: TextStyle(color: Colors.deepPurple),),
                                         SizedBox(width: 10.w,),
                                         const Icon(Icons.search_rounded,color:Colors.deepPurple ,)
                                       ],
                                     ))],
                             );}

                            } else {
                              return const Center(child: Text("No data"));
                            }
                          }),

                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
  Widget searchUser (List contactListIDs){
    return StreamBuilder<QuerySnapshot>(
        stream: searchQuery !=''?_allUsersRef.where('userNameForQuery',isGreaterThanOrEqualTo: searchQuery.toLowerCase()).where('userNameForQuery',
        isLessThanOrEqualTo: '${searchQuery.toLowerCase()}\uf8ff').snapshots():null,
        builder: (context, snapshot) {
          if (snapshot.connectionState==ConnectionState.waiting){return const Center(child: CircularProgressIndicator(),);}
          else if (snapshot.hasError){return const Center(child: Text('An error occured', style: TextStyle(fontStyle: FontStyle.italic),),);
          }else if (snapshot.hasData){
            print(contactListIDs);
             final query = snapshot.data!.docs;
            return query.isNotEmpty?FutureBuilder(
              future: getApplicationDocumentsDirectory(),
              builder:(context, snapshot) {

                if (snapshot.hasData){
                  final directory = snapshot.data;
                  return customListViewBuilder(contactListIDs, query, directory, );
                }
                //else if (snapshot.hasError){return const Text('Application Directory not found');}
                else{
                  return customListViewBuilder(contactListIDs, query, null, );
                }

              },
            ): const Text('No user found', style: TextStyle(fontStyle: FontStyle.italic) );
          }else{return const Center(child: Center(child: CircularProgressIndicator(),));}
        },);
  }

  Widget customListViewBuilder (contactListIDs, query,directory,){

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount:query.length ,
      itemBuilder:(context, index) {
        File file = File('${directory?.path}/${query[index]['Email'].toString()} _profilePhoto.jpg');
        return ListTile(
          onTap:!contactListIDs.toList().contains(query[index]['Email'])?  () {
            Get.to(OtherUserProfile(file: file, doc: query[index],contactList:contactListIDs, ));
            _searchController.clear();
          }: () => Get.to(ChatPage(contactList: contactListIDs,contactName: query[index]['User Name'],
            userData: query[index],dpLocalPath: file.path,imageUrl:query[index]["Profile Picture"]!=null?query[index]["Profile Picture"]['imageUrl']:null ,)),
          leading: dp(query, index),
          title: Text(query[index]['User Name'],style: TextStyle(fontSize: 13.sp),),
          subtitle: Text(query[index]['Email'],style: TextStyle(fontSize: 10.sp,color: Colors.deepPurple),),
          trailing:contactListIDs.toList().contains(query[index]['Email'])? Icon(Icons.check_circle_outline,size: 18,color: Colors.deepPurple[200],):Icon(Icons.person_add_alt_outlined,size: 18.w,color: Colors.deepPurple,),
        );
      },
    );

  }


  Widget dp (users, index){

    return FutureBuilder(
        future: getApplicationDocumentsDirectory(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            final directory = snapshot.data;

            ImageProvider image (){
              final file = File('${directory?.path}/${users[index]['Email'].toString()} _profilePhoto.jpg');
              if (file.existsSync()){
                return FileImage(file, scale: 1);
              }else{
                return NetworkImage(
                    users![index]["Profile Picture"]['imageUrl'],
                    scale:1  );
              }
            }

            return CircleAvatar(
                 radius: 20.r,
                 backgroundImage:

                 users![index]["Profile Picture"] != null
                  ? image() : null,
                 child:
                 users![index]["Profile Picture"] == null?
                 Icon(Icons.person,
                  color: Theme.of(context).splashColor,
                  size: 25.sp)
                  : null,
            );
          }else if (snapshot.hasError){
            return CircleAvatar(
              radius: 20.r,
              backgroundImage:

              users![index]["Profile Picture"] != null
                  ? NetworkImage(
                  users![index]["Profile Picture"]!=null
                      ? users![index]["Profile Picture"]['imageUrl']:null,
                  scale:1  )
                  : null,
              child:
              users![index]["Profile Picture"] == null?
              Icon(Icons.person,
                  color: Theme.of(context).splashColor,
                  size: 25.w)
                  : null,
            );
          }else{
            return CircleAvatar(
              radius: 20.r,
              backgroundColor: Colors.white10,

            );
          }
        },);

  }

}
