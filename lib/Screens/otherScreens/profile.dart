import 'package:flutter/material.dart';
import 'package:chatgo/Services/firebaseFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
enum ProfileState {
  CURRENT,
  EDIT,
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.profileState = ProfileState.CURRENT});

  final ProfileState profileState;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileState? _profileState = ProfileState.CURRENT;
  final _fireStore = FireStoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? user;

  var userNameController = TextEditingController();
  var bioController = TextEditingController();
  final emailController = TextEditingController();
  final occupationController=TextEditingController();
  final locationController = TextEditingController();
  bool errorTextField = false;

  @override
  void dispose() {
    userNameController.dispose();
    bioController.dispose();
    emailController.dispose();
    occupationController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void bottomSheet(String updateGuide, int maxLength,
      TextEditingController? controller,  void Function()? onSave,
      Widget? error, String? helperText) {
    // setState(() {
    //   controller=TextEditingController(text: user);
    // });
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      context: context,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom),
          child: SizedBox(
            height: 152,
            width: 360,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 15,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      updateGuide,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 250,
                          child: TextFormField(
                            decoration: InputDecoration(
                              helperText:helperText,
                              helperStyle:const TextStyle(fontWeight: FontWeight.w200, fontSize:12,),
                                error: errorTextField == true ? error : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 3)),
                            cursorWidth: 1,
                            maxLength: maxLength,
                            maxLines: 2,
                            controller: controller,
                          ),
                        )
                      ],
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                            onPressed:
                            onSave,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadiusDirectional.circular(20)),
                            child: const Text(
                              'save',
                              style: TextStyle(color: Colors.deepPurple),
                            )),
                        MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                              setState(() {
                                controller!.clear();
                                setState((){errorTextField=false;});
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadiusDirectional.circular(20)),
                            child: const Text(
                              'cancel',
                              style: TextStyle(color: Colors.deepPurple),

                            )),
                      ])
                ],
              ),
            ),
          ),
        );
      },
    );
  }
 // StreamBuilder for streaming data from database for the Edit Page (Enum: ProfilePage.EDIT)
  Widget streamBuilder(String streamData) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _fireStore.getUserDocumentAfterEdit(currentUser),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic>? snapshotData = snapshot.data!.data();
          return Text(snapshotData![streamData]);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Loading...', style: TextStyle(color: Colors.grey,),);
        } else if (snapshot.hasError) {
          return const Text('...', style: TextStyle(color: Colors.grey,));
        } else {
          return const Text('No data');
        }
      },);
  }



  // Open Date Picker for choose date of birth
  void dateOfBirthPicker (){
    showDatePicker(context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 4000)),
    ).then((value){
      _fireStore.updateDOBDocs(currentUser, value!.toString().trim());

    });
  }

  @override
  Widget build(BuildContext context) {
    return _profileState == ProfileState.CURRENT
        ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _fireStore.getUSerDocument(currentUser),
      builder: (context, snapshot) {
//Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          user = snapshot.data!.data();
          return Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .scaffoldBackgroundColor,
              body: Container(
                height: 900,
                width: 380,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/Screenshot_20240528-134244.jpg',
                        ),
                        fit: BoxFit.fill)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    height: 900,
                    width: 400,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: Container(
                            height: 795,
                            decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .scaffoldBackgroundColor,
                                borderRadius:
                                const BorderRadiusDirectional.only(
                                  topStart: Radius.circular(40),
                                  topEnd: Radius.circular(40),
                                )),
                          ),
                        ),
                        Positioned(
                          top: 55,
                          child: profilePicture(110, 110, 70),
                        ),
                        Positioned(
                          top: 167,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10),
                            child: Column(children: [
                              Text(user!['User Name'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius:
                                        BorderRadiusDirectional
                                            .circular(5),
                                        gradient: const LinearGradient(
                                            colors: [
                                              Colors.black12,
                                              Colors.white70,
                                              Colors.white70,
                                              Colors.black12
                                            ])),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.attach_email_rounded,
                                            color: Colors.grey,
                                            size: 15),
                                        const SizedBox(width: 5),
                                        Text(user!['Email'],
                                            style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12)),
                                      ],
                                    )),
                              ),
                               Padding(
                                padding:const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 300,
                                  child: Align(
                                    alignment:
                                    AlignmentDirectional.topCenter,
                                    child: Text(user!['Bio'],
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style:const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14)),
                                  ),
                                ),
                              ),
                              Row(children: [
                                MaterialButton(
                                    height: 40,
                                    color: Colors.deepPurple,
                                    elevation: 10,
                                    onPressed: () {},
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadiusDirectional
                                          .circular(10),
                                    ),
                                    child: const Row(children: [
                                      Icon(Icons.person_2_outlined),
                                      Text('Followers: 500k')
                                    ])),
                                const SizedBox(width: 30),
                                MaterialButton(
                                    height: 40,
                                    color: Colors.deepPurple,
                                    elevation: 20,
                                    onPressed: () {},
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadiusDirectional
                                            .circular(10),
                                        side: const BorderSide(
                                            color: Colors.deepPurple)),
                                    child: const Row(children: [
                                      Icon(Icons.person_2_outlined),
                                      Text('Following: 230k')
                                    ]))
                              ]),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: Container(
                                  height: 100,
                                  width: 320,
                                  child: const Column(
                                    children: [
                                      Align(
                                        alignment:
                                        AlignmentDirectional.topStart,
                                        child: Text(
                                          'Posts',
                                          style: TextStyle(
                                              color: Colors.blueGrey),
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                        AlignmentDirectional.center,
                                        child: Text('No data'),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 230),
                                    child: Text(
                                      'Personal info',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  personalInfo(
                                    user!['Date of Birth'],
                                    'date of birth',
                                    'gender',
                                    user!['Gender'],
                                    Icons.calendar_month,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  personalInfo(
                                    '+234 9123922764',
                                    'mobile',
                                    'region',
                                    user!['Location'],
                                    Icons.call,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  personalInfo(
                                    user!['Email'],
                                    'mail',
                                    'occupation',
                                    user!['Occupation'],
                                    Icons.mail_outline,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                  height: 2,
                                  width: 320,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300
                                        .withOpacity(0.2),
                                  )),
                              listTile(
                                  'Edit Profile',
                                  null,
                                  Icons.edit,
                                  Icons.arrow_forward_ios_sharp,
                                  Colors.blueGrey, () {
                                setState(() {
                                  _profileState = ProfileState.EDIT;
                                });
                              },
                                  Colors.grey.shade700),
                              listTile(
                                  'Settings',
                                  null,
                                  Icons.settings,
                                  Icons.arrow_forward_ios_sharp,
                                  Colors.blueGrey,
                                      () {},
                                  Colors.grey.shade700),
                              listTile(
                                  'LogOut',
                                  null,
                                  Icons.logout_outlined,
                                  Icons.arrow_forward_ios_sharp,
                                  Colors.red.shade700.withOpacity(0.8),
                                  _fireStore.signOut,
                                  Colors.grey.shade700),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        } else {
          return const Center(child: Text('No data'));
        }
      },
    )
        : Scaffold(
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        size: 20),
                    onPressed: () {
                      setState(() {
                        _profileState = ProfileState.CURRENT;
                      });
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text('Edit Profile',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.topCenter,
                child: Stack(
                  children: [
                    profilePicture(140, 140, 90),
                    Positioned(
                      top: 95,
                      left: 100,
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple.shade400
                                  .withOpacity(0.8)),
                          child: Center(
                              child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_a_photo,
                                      size: 20, color: Colors.white)))),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              listTile(
                  'username',
                  streamBuilder('User Name'),
                  Icons.person_2_outlined,
                  Icons.edit,
                  Colors.black,
                  //Open Bottom Sheet (Function)
                      () {
                    bottomSheet(
                        'Update Name',
                        20,
                        userNameController,
                            () {
                          if (userNameController.text.trim().length < 4) {
                            setState((){errorTextField=true;});
                          } else {
                            _fireStore.updateUserDocument(userNameController.text.trim(),
                                bioController.text.trim(),occupationController.text.trim(),locationController.text.trim(), currentUser, context);
                            setState((){errorTextField=false;});
                          }},

                        const Text('4 characters minimum',style:TextStyle(color:Colors.red)),
                      '4 characters minimum'
                    );
                  },
                  Colors.deepPurple),
              listTile(
                  'bio',
                  streamBuilder('Bio'),
                  Icons.info_outline_rounded,
                  Icons.edit,
                  Colors.black,
                      () =>
                      bottomSheet(
                          'Update Bio', 100, bioController,
                              () {
                            if (bioController.text.trim().isEmpty) {
                              setState((){errorTextField=true;});
                            } else {
                              _fireStore.updateUserDocument(userNameController.text.trim(),
                                  bioController.text.trim(),occupationController.text.trim(),locationController.text.trim(), currentUser, context);
                              setState((){errorTextField=false;});
                            }},
                          const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                          'cancel to retain current .Bio.'),
                  Colors.deepPurple),
              listTile(
                  'date of birth',
                  streamBuilder('Date of Birth'),
                  Icons.cake_outlined,
                  Icons.edit,
                  Colors.black,
                      dateOfBirthPicker,
                  Colors.deepPurple),
              listTile(
                  'occupation',
                  streamBuilder('Occupation'),
                  Icons.work_outline_rounded,
                  Icons.edit,
                  Colors.black,
                      () {
                    bottomSheet(
                        'Update Occupation',
                        20,
                        occupationController,
                            () {
                          if (occupationController.text.trim().isEmpty){
                            setState((){errorTextField=true;});
                          }else{ _fireStore.updateUserDocument(userNameController.text.trim(),
                              bioController.text.trim(),occupationController.text.trim(),locationController.text.trim(), currentUser, context);
                          setState((){errorTextField=false;});}
                        },

                        const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                        'Work Experience'
                    );
                  },
                  Colors.deepPurple),
              listTile(
                  'location',
                  streamBuilder('Location'),
                  Icons.work_outline_rounded,
                  Icons.edit,
                  Colors.black,
                      () {
                    bottomSheet(
                        'Update Location',
                        20,
                        locationController,
                            () {
                          if (locationController.text.trim().isEmpty){
                            setState((){errorTextField=true;});
                          }else{ _fireStore.updateUserDocument(userNameController.text.trim(),
                              bioController.text.trim(),occupationController.text.trim(),locationController.text.trim(), currentUser, context);
                          setState((){errorTextField=false;});}
                        },

                        const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                        'region'
                    );
                  },
                  Colors.deepPurple),
              listTile(
                  'gender',
                  streamBuilder('Gender'),
                  Icons.person_4_outlined,
                  Icons.arrow_drop_down_sharp,
                  Colors.black,
                      () {showMenu(context: context,
                          position:RelativeRect.fromSize(Rect.fromLTWH(10, 10, 60, 50), Size.fromHeight(60)),
                          items: [PopupMenuItem(child:Text('Male'),onTap:()=>_fireStore.updateGenderDocs(currentUser, 'Male'), ),
                            PopupMenuItem(child: Text('Female'),onTap:() => _fireStore.updateGenderDocs(currentUser, 'Female'),),
                          ]);},
                  Colors.deepPurple),

              listTile(
                  'email',
                  Text(
                    user!['Email'],
                  ),
                  Icons.email_outlined,
                  null,
                  Colors.black,
                      () {},
                  Colors.deepPurple),
              listTile(
                  'mobile',
                  const Text(
                    '+234 9123922764',
                  ),
                  Icons.phone,
                  null,
                  Colors.black,
                      () {},
                  Colors.deepPurple),
            ],
          ),
        ),
      ),
    );
  }
}

Widget personalInfo(String subtitle,
    String title,
    String title2,
    String subtitle2,
    IconData icon,) {
  return SizedBox(
    width: 350,
    height: 50,
    child: Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.pinkAccent.shade100.withOpacity(0.8),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                ]),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text(title2,
                      style: const TextStyle(
                        color: Colors.grey,
                      ))),
              Expanded(
                  child: Text(
                    subtitle2,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800),
                  ))
            ]),
          ),
        ],
      ),
    ),
  );
}

Widget listTile(String title,
    Widget? subtitle,
    IconData iconLead,
    IconData? iconTrail,
    Color color,
    void Function()? onTap,
    Color iconTrailColor) {
  return SizedBox(
    width: 370,
    child: ListTile(
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: subtitle,
      leading: Icon(
        iconLead,
        color: color,
      ),
      trailing: Icon(
        iconTrail,
        color: iconTrailColor,
        size: 16,
      ),
      onTap: onTap,
    ),
  );
}

Widget profilePicture(double height, double width, double iconHeight) {
  return Container(
    height: height,
    width: width,
    decoration:
    const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    child: Icon(Icons.person,
        color: Colors.black.withOpacity(0.5), size: iconHeight),
  );
}


// Scaffold(
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         body: Container(
//           height: 900,
//           width: 380,
//           decoration: const BoxDecoration(
//               image: DecorationImage(
//                   image: AssetImage(
//                     'assets/Screenshot_20240528-134244.jpg',
//                   ),
//                   fit: BoxFit.fill)),
//           child: SingleChildScrollView(scrollDirection: Axis.vertical,
//             child: Container(
//               height: 900,width: 400,
//               child: Stack(
//                 alignment: AlignmentDirectional.topCenter,
//                 children: [
//                   Align(
//                     alignment: AlignmentDirectional.bottomCenter,
//                     child: Container(
//                       height: 795,
//                       decoration: BoxDecoration(
//                           color: Theme.of(context).scaffoldBackgroundColor,
//                           borderRadius: const BorderRadiusDirectional.only(
//                             topStart: Radius.circular(40),
//                             topEnd: Radius.circular(40),
//                           )),
//                     ),
//                   ),
//                   Positioned(
//                     top: 55,
//                     child: Container(
//                       height: 110,
//                       width: 110,
//                       decoration: const BoxDecoration(
//                           shape: BoxShape.circle, color: Colors.white),
//                       child: Icon(Icons.person,
//                           color: Colors.black.withOpacity(0.5), size: 70),
//                     ),
//                   ),
//                   Positioned(
//                     top: 167,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       child: Column(children: [
//                         const Text('JayP',
//                             style: TextStyle(
//                               fontSize: 23,
//                               fontWeight: FontWeight.w500,
//                             )),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Container(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 5),
//                               height: 20,
//                               decoration: BoxDecoration(
//                                   color: Colors.white24,
//                                   borderRadius:
//                                       BorderRadiusDirectional.circular(5),
//                                   gradient: const LinearGradient(colors: [
//                                     Colors.black12,
//                                     Colors.white70,
//                                     Colors.white70,
//                                     Colors.black12
//                                   ])),
//                               child: const Row(
//                                 children: [
//                                   Icon(Icons.attach_email_rounded,
//                                       color: Colors.grey, size: 15),
//                                   SizedBox(width: 5),
//                                   Text('nwankwojohnpaul681@gmail.com',
//                                       style: TextStyle(
//                                           color: Colors.black54, fontSize: 12)),
//                                 ],
//                               )),
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: SizedBox(
//                             width: 300,
//                             child: Align(
//                               alignment: AlignmentDirectional.topCenter,
//                               child: Text('~ Eccentric',
//                                   maxLines: 4,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                       color: Colors.black, fontSize: 14)),
//                             ),
//                           ),
//                         ),
//                         Row(children: [
//                           MaterialButton(
//                               height: 40,
//                               color: Colors.deepPurple,
//                               elevation: 10,
//                               onPressed: () {},
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadiusDirectional.circular(10),
//                               ),
//                               child: const Row(children: [
//                                 Icon(Icons.person_2_outlined),
//                                 Text('Followers: 500k')
//                               ])),
//                           const SizedBox(width: 30),
//                           MaterialButton(
//                               height: 40,
//                               color: Colors.deepPurple,
//                               elevation: 20,
//                               onPressed: () {},
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadiusDirectional.circular(10),
//                                   side: const BorderSide(
//                                       color: Colors.deepPurple)),
//                               child: const Row(children: [
//                                 Icon(Icons.person_2_outlined),
//                                 Text('Following: 230k')
//                               ]))
//                         ]),
//                         const SizedBox(
//                           height: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal:10),
//                           child: Container(height: 100,
//                           width: 320,
//                           child:const Column(children: [
//                             Align(alignment: AlignmentDirectional.topStart,
//                             child: Text('Posts',style: TextStyle(color:Colors.blueGrey),),),
//                             Align(alignment: AlignmentDirectional.center,
//                             child: Text('No data'),)
//                           ],),),
//                         ),
//                         Column(
//                           children: [
//                             const Padding(
//                               padding: EdgeInsets.only(right: 230),
//                               child: Text(
//                                 'Personal info',
//                                 style: TextStyle(
//                                   color: Colors.blueGrey,
//                                 ),
//                               ),
//                             ),
//                              const SizedBox(height: 10),
//                             personalInfo(
//                               '27 Oct 2007',
//                               'date of birth',
//                               'gender',
//                               'Male',
//                                Icons.calendar_month,
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             personalInfo(
//                               '+234 9123922764',
//                               'mobile',
//                               'region',
//                               'Anambra,Nigeria',
//                               Icons.call,
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             personalInfo(
//                               'nwankwojohnpaul@gmail.com',
//                               'mail',
//                               'occupation',
//                               'Student',
//                               Icons.mail_outline,
//                             ),
//                           ],
//                         ),
//                          SizedBox(height: 20,),
//                          Container(height: 2,width: 320,
//                            decoration: BoxDecoration(color: Colors.grey.shade300.withOpacity(0.2),)),
//                         listTile( 'Edit Profile',Icons.edit,Icons.arrow_forward_ios_sharp,Colors.blueGrey,),
//                         listTile( 'Settings',Icons.settings,Icons.arrow_forward_ios_sharp,Colors.blueGrey,),
//                         listTile( 'LogOut',Icons.logout_outlined,Icons.arrow_forward_ios_sharp,Colors.red.shade700.withOpacity(0.8)),
//                       ]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ))
