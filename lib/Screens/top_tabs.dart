import 'package:chatgo/Screens/Calls/myCalls.dart';
import 'package:chatgo/Screens/Public/updates.dart';
import 'package:chatgo/Screens/chat/active_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controlller_logic/controller.dart';
import '../Controlller_logic/theme_constants.dart';
import '../Controlller_logic/theme_controller.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  ChatController chatController = Get.put(ChatController());
  ThemeController themeController = Get.put(ThemeController());
  final newValue = false;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          endDrawerEnableOpenDragGesture: true,
          endDrawer: Drawer(
            backgroundColor: Theme.of(context).splashColor,
            child: Column(
              children: [
                Container(
                  height: 166,
                  decoration: const BoxDecoration(color: Colors.white38),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          top: 50,
                        ),
                        child: CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                                'assets/Screenshot_20240208-060551.jpg')),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 2,
                              ),
                              child: DropdownMenu(

                                  inputDecorationTheme: InputDecorationTheme(
                                      disabledBorder: InputBorder.none,
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.grey.shade500,
                                      filled: true),
                                  //trailingIcon: Icon(Icons.arrow_drop_up),
                                  width: 300,
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(
                                      value: null,
                                      labelWidget: Column(
                                        children: [
                                          Text('Jay-P'),
                                          Text(
                                            '+234 9123922764',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                      label: '~Jay-P',
                                      leadingIcon: CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'assets/Screenshot_20240208-060551.jpg')),
                                    ),
                                    DropdownMenuEntry(
                                        label: 'Add Account',
                                        value: null,
                                        leadingIcon: Icon(Icons.add))
                                  ]),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    'Profile',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.perm_contact_calendar_sharp),
                  onTap: () {
                    Get.toNamed("/profilePage");
                  },
                ),
                ListTile(
                  title: Text(
                    'Saved Messages',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.save),
                  onTap: () {},
                ),
                ListTile(
                  title: Text(
                    'Settings',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.settings),
                  onTap: () {},
                ),
                ListTile(
                  title: Text(
                    'Add/Invite friend',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.quick_contacts_mail_rounded),
                  onTap: () {},
                ),
                ListTile(
                  title: Text(
                    'Help',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.help),
                  onTap: () {},
                ),
                ListTile(
                  title: Text(
                    'Theme',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: const Icon(Icons.wb_sunny_outlined),
                  trailing: const Icon(Icons.dark_mode_outlined),
                  onTap: () {
                    (Get.bottomSheet(
                        enableDrag: true,
                        backgroundColor: Colors.grey,
                        Wrap(
                          children: [
                            ListTile(
                                leading: const Icon(Icons.light_mode),
                                title: Text(
                                  'Light Mode',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onTap: () => {
                                      Get.changeTheme(Themes.lightTheme)
                                      //  if (Get.isDarkMode){
                                      //    themeController.changeTheme(Themes.lightTheme),
                                      //  //themeController.saveTheme(false)
                                      //  }else{
                                      //    themeController.changeTheme(Themes.darkTheme),
                                      //    //themeController.saveTheme(true)
                                      // }
                                    }),
                            ListTile(
                              leading: const Icon(Icons.dark_mode),
                              title: Text(
                                'Dark Mode',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onTap: () => {Get.changeTheme(Themes.darkTheme)},
                            ),
                          ],
                        )));
                  },
                ),
                MaterialButton(
                  onPressed: (){
                  _auth.signOut();
                },
                color: Colors.deepPurple[200],
                 child:const Text('sign out'),)
              ],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: const [],
            backgroundColor: Theme.of(context).secondaryHeaderColor,
            bottom: PreferredSize(
              preferredSize:const Size.fromHeight(0),
              child: TabBar(
                dividerColor: Colors.transparent,
                tabs: [
                  Text(
                    'CHATS',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text(
                    'PUBLIC',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text(
                    'CALLS',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],

              ),

            ),
          ),
          body: TabBarView(children: [
            ActiveContacts(),
             PublicUpdates(),
             MyRecentCalls(),
          ])),
    );
  }
}
