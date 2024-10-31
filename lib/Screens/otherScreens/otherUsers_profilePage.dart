import 'dart:io';
import 'package:chatgo/Screens/Chat/private_chatRoom.dart';
import 'package:chatgo/Screens/chat/active_contacts.dart';
import 'package:chatgo/Screens/otherScreens/profile.dart';
import 'package:chatgo/Services/firebase/firebaseFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../Controlller_logic/utils.dart';

class OtherUserProfile extends StatelessWidget {
  OtherUserProfile({super.key, required this.file, required this.doc, required this.contactList});

  final File file;
  //either QueryDocSnapshot or Map
  final dynamic doc;
  final _fireStore = FireStoreService();
  final _firebaseAuth = FirebaseAuth.instance;
  final List contactList;

  @override
  Widget build(
    BuildContext context,) {

    return Scaffold(
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor,
        body: Container(
          height: 900.h,
          width: 380.w,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/Screenshot_20240528-134244.jpg',
                  ),
                  fit: BoxFit.fill)),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: 900.h,
              width: 400.w,
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Positioned(
                    top: 40.h,left: 10.w,
                      child: IconButton(onPressed: ()=>Get.back(), icon:const Icon(Icons.arrow_back_rounded,color: Colors.black,))),
                  Align(
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Container(
                      height: 700.h,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius:
                          BorderRadiusDirectional.only(
                            topStart: Radius.circular(40.r),
                            topEnd: Radius.circular(40.r),
                          )),
                    ),
                  ),
                  Positioned(
                      top: 135.h,
                      child: GestureDetector(
                        onTap: (){
                          showDialog(context: context,
                              builder: (context) {
                                return CircleAvatar(
                                  backgroundImage: doc['Profile Picture']!=null?
                                  file.existsSync()?Image.file(file, fit: BoxFit.contain,).image
                                      :NetworkImage(doc["Profile Picture"]['imageUrl'],
                                    ):Image.asset('assets/0ca6ecf671331f3ca3bbee9966359e32.jpg',fit: BoxFit.contain,).image,
                                  radius: 55.r,
                                );
                              },);
                        },
                        child: CircleAvatar(
                          backgroundImage: doc['Profile Picture']!=null?
                              file.existsSync()?Image.file(file).image
                                  :NetworkImage(doc["Profile Picture"]['imageUrl'],
                                scale: 1,):Image.asset('assets/0ca6ecf671331f3ca3bbee9966359e32.jpg').image,
                          radius: 55.r,
                        ),
                      )
                      // profilePicture(110, 110, 70,context,user!['Profile Picture'],
                      //     user!['Profile Picture']!=null?DecorationImage(image:
                      //     //profilePicPath!=null&&profilePicPath!.existsSync()
                      //     user!['Profile Picture']!=null?Image.file(profilePicPath!).image:NetworkImage(user!['Profile Picture']['imageUrl']),
                      //       fit: BoxFit.fitWidth,
                      //     ):null,
                      //     _profileState!

                      ),
                  Positioned(
                    top: 247.h,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(
                          horizontal: 10.w),
                      child: Column(children: [
                        Text(doc['User Name'],
                            style:  TextStyle(
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w500,
                            )),
                        Padding(
                          padding:  EdgeInsets.symmetric(
                              horizontal: 20.w),
                          child: Container(
                              padding:  EdgeInsets.symmetric(
                                  horizontal: 5.w),
                              height: 20.h,
                              decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius:
                                  BorderRadiusDirectional
                                      .circular(5.r),
                                  gradient: const LinearGradient(
                                      colors: [
                                        Colors.black12,
                                        Colors.white70,
                                        Colors.white70,
                                        Colors.black12
                                      ])),
                              child: GestureDetector(
                                onLongPressStart: (v) => Clipboard.setData(
                                    ClipboardData(text:doc['Email'] )).then((value) =>
                                    Utils().scaffoldMessenger(context,'Email copied',
                                        20.h, 75, 2,  Icon(Icons.copy,size: 20.w,))),
                                child: Row(
                                  children: [
                                    Icon(
                                        Icons.attach_email_rounded,
                                        color: Colors.grey,
                                        size: 15.w),
                                    SizedBox(width: 5.w),
                                    Text(doc['Email'],
                                        style:  TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.sp)),
                                  ],
                                ),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 20.h),
                          child: SizedBox(
                            width: 300.w,
                            child: Align(
                              alignment:
                              AlignmentDirectional.topCenter,
                              child: Text(doc['Bio'],
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.sp)),
                            ),
                          ),
                        ),
                        Row(children: [
                          MaterialButton(
                              height: 40.h,
                              color: contactList!.contains(doc['Email'])?Colors.grey:Colors.deepPurple,
                              elevation: 5.dm,
                              onPressed: !contactList!.contains(doc['Email'])?() async {
                                Utils().loadingCircle(context);
                                await _fireStore.addToContact(
                                    currentUser: _firebaseAuth.currentUser!.email!,
                                    contact: doc['Email']).then((value) {
                                      Navigator.of(context).pop();
                                      Utils().scaffoldMessenger(context,'Added to chat', 0, 80.w, 2, null);
                                });
                              }:null,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadiusDirectional
                                    .circular(10.r),
                              ),
                              child: const Row(children: [
                                Icon(Icons.person_2_outlined),
                                Text('   Add User')
                              ])),
                           SizedBox(width: 50.w),
                          MaterialButton(
                              height: 40.h,
                              color: Colors.deepPurple,
                              elevation: 5,
                              onPressed: ()=>Get.to(ChatPage(contactName: doc['User Name'],
                                  userData: doc, contactList: contactList,navigatingFrom: 'otherUsersProfile',
                              imageUrl: doc['Profile Picture']!=null?doc["Profile Picture"]['imageUrl']:null,
                              dpLocalPath: file.path,)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadiusDirectional
                                      .circular(10.r),
                                  side: const BorderSide(
                                      color: Colors.deepPurple)),
                              child: const Row(children: [
                                Icon(Icons.messenger_outline),
                                Text('   Message')
                              ]))
                        ]),
                        SizedBox(
                          height: 50.h,
                        ),
                        Container(
                            height: 2.h,
                            width: 320.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300
                                  .withOpacity(0.2),
                            )),

                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 230.w, top: 20.h),
                              child:const Text(
                                'Personal info',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            personalInfo(
                              doc['Date of Birth'],
                              'date of birth',
                              'gender',
                              doc['Gender'],
                              Icons.calendar_month,
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            personalInfo(
                              doc['mobileNo']??'---',
                              'mobile',
                              'region',
                              doc['Location'],
                              Icons.call,
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            personalInfo(
                              doc['Email'],
                              'mail',
                              'occupation',
                              doc['Occupation'],
                              Icons.mail_outline,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),

                        // listTile(
                        //     'Edit Profile',
                        //     null,
                        //     Icons.edit,
                        //     Icons.arrow_forward_ios_sharp,
                        //     Colors.blueGrey, () {
                        //   setState(() {
                        //     _profileState = ProfileState.EDIT;
                        //   });
                        // },
                        //     Colors.grey.shade700,context),
                        // listTile(
                        //     'Settings',
                        //     null,
                        //     Icons.settings,
                        //     Icons.arrow_forward_ios_sharp,
                        //     Colors.blueGrey,
                        //         () {},
                        //     Colors.grey.shade700,context),
                        // listTile(
                        //     'LogOut',
                        //     null,
                        //     Icons.logout_outlined,
                        //     Icons.arrow_forward_ios_sharp,
                        //     Colors.red.shade700.withOpacity(0.8),
                        //         (){_fireStore.signOut(context);Get.offAll(const Wrapper());},
                        //     Colors.grey.shade700,context),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
    // return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    //   future: FirebaseFirestore.instance.collection('users').doc(doc.id).get(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Scaffold(body: Center(child: CircularProgressIndicator()),);
    //     } else if (snapshot.hasError) {
    //       return Text("Error: ${snapshot.error}");
    //     } else if (snapshot.hasData) {
    //       user = snapshot.data!.data();
    //
    //
    //     } else {
    //       return const Center(child: Text('No data'));
    //     }
    //   },
    // )
    // return Scaffold(
    //   appBar: AppBar(
    //     elevation: 20,
    //     title: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           query[index]['User Name'],
    //           style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 17),
    //         ),
    //         SelectableText(query[index]['Email'],style:const TextStyle(color: Colors.blue, fontSize: 13),)
    //       ],
    //     ),
    //     backgroundColor: Colors.transparent,
    //   ),
    //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    //   body: Align(
    //     alignment: Alignment.center,
    //     child: SizedBox(
    //       height: 200,
    //       width: 200,
    //       child: Card(
    //         elevation: 20,
    //         child: Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: [
    //               InkWell(
    //                 onTap: () {},
    //                 child: const Row(
    //                   children: [
    //                     Icon(Icons.account_circle_rounded),
    //                     SizedBox(
    //                       width: 10,
    //                     ),
    //                     Text('View profile'),
    //                   ],
    //                 ),
    //               ),
    //               InkWell(
    //                 onTap: () async {
    //                   showDialog(
    //                     barrierDismissible: false,
    //                     context: context,
    //                     builder: (context) {
    //                       return const Center(
    //                         child: CircularProgressIndicator(),
    //                       );
    //                     },
    //                   );
    //                   try {
    //                     await _fireStore.addToContact(
    //                         currentUser: _firebaseAuth.currentUser!.email!,
    //                         contact: query[index]['Email']);
    //                     ScaffoldMessenger.of(context)
    //                         .showSnackBar(const SnackBar(
    //                             // backgroundColor:Colors.grey,
    //                             duration: Duration(seconds: 2),
    //                             content: Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 Text('User Added'),
    //                                 Icon(
    //                                   Icons.check_circle_outline,
    //                                   color: Colors.green,
    //                                 )
    //                               ],
    //                             )));
    //                     Navigator.of(context).pop();
    //                     Get.back();
    //                   } catch (e) {
    //                     print(e.toString());
    //                   }
    //                 },
    //                 child: const Row(
    //                   children: [
    //                     Icon(Icons.person_add_alt_rounded),
    //                     SizedBox(
    //                       width: 10,
    //                     ),
    //                     Text('Add User'),
    //                   ],
    //                 ),
    //               ),
    //               InkWell(
    //                 onTap: () {
    //                   Get.off(()=>ChatPage(
    //                     contactName: query[index]['User Name'],
    //                       imageUrl: query[index]['Profile Picture']!=null?query[index]['Profile Picture']['imageUrl']:null,
    //                       otherUserID: query[index]['Email'],
    //                     contactList: contactList,
    //                       dpLocalPath:'',
    //                       navigatingFrom:'otherUsersProfile'
    //                       ),);
    //                 },
    //                 child: const Row(
    //                   children: [
    //                     Icon(Icons.chat),
    //                     SizedBox(
    //                       width: 10,
    //                     ),
    //                     Text('Chat'),
    //                   ],
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
