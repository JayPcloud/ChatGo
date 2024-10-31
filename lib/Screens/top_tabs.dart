import 'dart:async';
import 'package:chatgo/Screens/chat/active_contacts.dart';
import 'package:chatgo/Screens/otherScreens/all_users.dart';
import 'package:chatgo/Screens/otherScreens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../Controlller_logic/controller.dart';
import '../Controlller_logic/theme_controller.dart';
import '../Services/connectivity_check.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key, });

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList>with WidgetsBindingObserver {
  ChatController chatController = Get.put(ChatController());
  ThemeController themeController = Get.put(ThemeController());
  final newValue = false;
  final _auth = FirebaseAuth.instance;
  final controller = ConnectivityController();
  final fireStore = FirebaseFirestore.instance;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.detached||state==AppLifecycleState.paused||state==AppLifecycleState.hidden){
      fireStore.collection('users').doc(_auth.currentUser!.email).update({
        'lastSeen':Timestamp.now(),
        'isOnline': false
      },);
    }else{fireStore.collection('users').doc(_auth.currentUser!.email).update({
      'lastSeen':Timestamp.now(),
      'isOnline': true
    },);}
    super.didChangeAppLifecycleState(state);
  }
@override
void initState() {
  WidgetsBinding.instance.addObserver(this);
  fireStore.collection('users').doc(_auth.currentUser!.email).update({'lastSeen':Timestamp.now(), 'isOnline': true});
  Timer.periodic(const Duration(minutes: 2, seconds: 30), (timer) {
    print('online...');
     fireStore.collection('users').doc(_auth.currentUser!.email).update({
      'lastSeen':Timestamp.now(),
    }
    );

  });
  controller.checkConnectivity(context,null, null);
    super.initState();
  }

  int tabIndex = 0;

  final pages = [
    const ActiveContacts(),
    const AllUsers(),
    const ProfilePage(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        //drawerEnableOpenDragGesture:true ,
        // drawer: Drawer(
        //   width:screenWidth*0.75 ,
        //   backgroundColor: Theme.of(context).splashColor,
        //   child: Column(
        //     children: [
        //       Container(
        //         height: 166,
        //         decoration: const BoxDecoration(color: Colors.white38),
        //         child: Column(
        //           children: [
        //             const Padding(
        //               padding: EdgeInsets.only(
        //                 top: 50,
        //               ),
        //               child: CircleAvatar(
        //                   radius: 30,
        //                   backgroundImage: AssetImage(
        //                       )),
        //             ),
        //             Row(
        //               children: [
        //                 Expanded(
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(
        //                       left: 2,
        //                     ),
        //                     child: DropdownMenu(
        //
        //                         inputDecorationTheme: InputDecorationTheme(
        //                             disabledBorder: InputBorder.none,
        //                             border: const UnderlineInputBorder(
        //                               borderSide: BorderSide.none,
        //                             ),
        //                             fillColor: Colors.grey.shade500,
        //                             filled: true),
        //                         //trailingIcon: Icon(Icons.arrow_drop_up),
        //                         width: 300,
        //                         dropdownMenuEntries: const [
        //                           DropdownMenuEntry(
        //                             value: null,
        //                             labelWidget: Column(
        //                               children: [
        //                                 Text('Jay-P'),
        //                                 Text(
        //                                   '+234 9123922764',
        //                                   style:
        //                                       TextStyle(color: Colors.blue),
        //                                 ),
        //                               ],
        //                             ),
        //                             label: '~Jay-P',
        //                             leadingIcon: CircleAvatar(
        //                                 backgroundImage: AssetImage(
        //                                     '')),
        //                           ),
        //                           DropdownMenuEntry(
        //                               label: 'Add Account',
        //                               value: null,
        //                               leadingIcon: Icon(Icons.add))
        //                         ]),
        //                   ),
        //                 )
        //               ],
        //             )
        //           ],
        //         ),
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Profile',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.account_circle_rounded),
        //         onTap: () {
        //           Get.toNamed("/profilePage");
        //         },
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Contact List',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.group_add),
        //         onTap: () {Get.to(()=>const AllUsers());},
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Settings',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.settings),
        //         onTap: () {},
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Add/Invite friend',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.quick_contacts_mail_rounded),
        //         onTap: () {},
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Help',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.help),
        //         onTap: () {},
        //       ),
        //       ListTile(
        //         title: Text(
        //           'Theme',
        //           style: TextStyle(color: Theme.of(context).primaryColor),
        //         ),
        //         leading: const Icon(Icons.wb_sunny_outlined),
        //         trailing: const Icon(Icons.dark_mode_outlined),
        //         onTap: () {
        //           (Get.bottomSheet(
        //               enableDrag: true,
        //               backgroundColor: Colors.grey,
        //               Wrap(
        //                 children: [
        //                   ListTile(
        //                       leading: const Icon(Icons.light_mode),
        //                       title: Text(
        //                         'Light Mode',
        //                         style: TextStyle(
        //                             color: Theme.of(context).primaryColor),
        //                       ),
        //                       onTap: () => {
        //                             Get.changeTheme(Themes.lightTheme)
        //                             //  if (Get.isDarkMode){
        //                             //    themeController.changeTheme(Themes.lightTheme),
        //                             //  //themeController.saveTheme(false)
        //                             //  }else{
        //                             //    themeController.changeTheme(Themes.darkTheme),
        //                             //    //themeController.saveTheme(true)
        //                             // }
        //                           }),
        //                   ListTile(
        //                     leading: const Icon(Icons.dark_mode),
        //                     title: Text(
        //                       'Dark Mode',
        //                       style: TextStyle(
        //                           color: Theme.of(context).primaryColor),
        //                     ),
        //                     onTap: () => {Get.changeTheme(Themes.darkTheme)},
        //                   ),
        //                 ],
        //               )));
        //         },
        //       ),
        //       MaterialButton(
        //         shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10)),
        //         onPressed: (){
        //         _auth.signOut();
        //         Get.offAll(const Wrapper());
        //       },
        //       color: Colors.deepPurple[200],
        //        child:const Text('sign out'),)
        //     ],
        //   ),
        // ),
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: Colors.transparent,
        //   bottom: PreferredSize(
        //     preferredSize:const Size.fromHeight(0),
        //     child: Row(
        //       children: [
        //          DrawerButton(
        //            style: ButtonStyle(
        //              enableFeedback: true,
        //              visualDensity: VisualDensity.adaptivePlatformDensity,
        //              elevation:const MaterialStatePropertyAll(40),
        //                backgroundColor: MaterialStatePropertyAll(Colors.deepPurple[200])), ),
        //         Expanded(
        //           child: TabBar(
        //             indicatorSize: TabBarIndicatorSize.tab,
        //             indicatorPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        //             indicator: BoxDecoration(
        //               color: Colors.deepPurple.shade400,
        //               shape: BoxShape.rectangle,
        //               borderRadius:const BorderRadiusDirectional.all(Radius.circular(15),),
        //             ),
        //             dividerColor: Colors.transparent,
        //             tabs: [
        //               Tab(
        //                 child: Text(
        //                   'CHATS',
        //                   style: TextStyle(color: Theme.of(context).primaryColor),
        //                 ),
        //               ),
        //               Tab(
        //                 child: Text(
        //                   'PUBLIC',
        //                   style: TextStyle(color: Theme.of(context).primaryColor),
        //                 ),
        //               ),
        //               Tab(
        //                 child: Text(
        //                   'CALLS',
        //                   style: TextStyle(color: Theme.of(context).primaryColor),
        //                 ),
        //               ),
        //             ],
        //
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.transparent, borderRadius:
          BorderRadiusDirectional.circular(30.r),
            border: const BorderDirectional(
              top: BorderSide(color: Colors.white),
              start: BorderSide(color: Colors.white),
              end: BorderSide(color: Colors.white),
            )
          ),
          //Theme.of(context).bottomAppBarTheme.surfaceTintColor!,
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal:15.h, vertical: 10.h),
            child: GNav(
              onTabChange: (value) => setState(() {
                 tabIndex = value;
              }),
              backgroundColor:
              Theme.of(context).bottomAppBarTheme.surfaceTintColor! ,
                color: Theme.of(context).primaryColor,
                activeColor: Colors.white,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 8.h),
                textStyle: TextStyle(color: Theme.of(context).primaryColor,),
                tabBackgroundColor: Theme.of(context).bottomAppBarTheme.color!,
                tabs:const [
                  GButton(icon: Icons.chat, text: ' Chats',style: GnavStyle.oldSchool),
                  GButton(icon: Icons.search_rounded, text: ' Search users',),
                  GButton(icon: Icons.person, text: ' Profile',),
                  //GButton(icon: Icons.settings, text: ' settings',),
                ]
            ),
          ),
        ),
        body: pages[tabIndex]
        // TabBarView(children: [
        //   const ActiveContacts(),
        //    const Scaffold(),
        //    MyRecentCalls(),
        // ])
    );
  }
}
