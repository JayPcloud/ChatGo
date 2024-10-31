import 'dart:io';
import 'dart:typed_data';
import 'package:chatgo/Screens/otherScreens/settings.dart';
import 'package:chatgo/wrapper.dart';
import 'package:chatgo/Services/firebase/firebase_storage.dart';
import 'package:chatgo/Services/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatgo/Services/firebase/firebaseFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Controlller_logic/utils.dart';
enum ProfileState {
  // CURRENT displays the profile page widget while EDIT displays the Edit profile widget
  // They states are on the same page
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
  final _firebaseStorage = FirebaseStorageService();
  final _pathProvider = PathProvider();
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
      Widget? error, String? helperText,TextInputType? keyboardType) {

    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,

      backgroundColor: Colors.deepPurple.shade100,
      context: context,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom),
          child: SizedBox(
            height: 152.h,
            width: 360.w,
            child: Padding(
              padding:  EdgeInsets.only(
                left: 30.w,
                right: 30.w,
                top: 15.h,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Text(
                      updateGuide,
                      style:  TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 60.h,
                          width: 250.w,
                          child: TextFormField(
                            keyboardType: keyboardType,
                            decoration: InputDecoration(
                              helperText:helperText,
                              helperStyle:const TextStyle(fontWeight: FontWeight.w200, fontSize:12,),
                                error: errorTextField == true ? error : null,
                                contentPadding:  EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 3.h)),
                            cursorWidth: 1.w,
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
                                BorderRadiusDirectional.circular(20.r)),
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
                                BorderRadiusDirectional.circular(20.r)),
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
      lastDate: DateTime.now().subtract(const Duration(days: 1000)),
    ).then((value){
      _fireStore.updateDOBDocs(currentUser, value!.toString().trim());

    });
  }


   File? profilePicPath;

 Future<void> onTapEditProfilePhoto () async {
   // pick image from user's gallery
   final ImagePicker imagePicker = ImagePicker();
   final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
   final Uint8List? imageByte=await image?.readAsBytes();
    if (image!=null){
      _pathProvider.load(context);
       await _firebaseStorage.uploadFile(currentUser!.email!, imageByte,currentUser,"users",);
         String?  getUrl = await _firebaseStorage.getFileUrl(currentUser!.email!);
         // store image with provider
       final imagePath =await _pathProvider.storeImageInProvider(getUrl," ${currentUser!.email}'s ProfilePicture",context,'permanent');
      Navigator.pop(context);
       setState(() {
         profilePicPath=imagePath;
       });
    }else{}

  }
 void getProfilePhoto ()async{
  File? filePath = await _pathProvider.getProfilePhotoFilePath(currentUser);
  setState(() {
    profilePicPath=filePath;
  });

}

@override
void initState() {
    super.initState();
    getProfilePhoto();
  }

  @override
  Widget build(BuildContext context) {
    return _profileState == ProfileState.CURRENT
        ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
         stream: _fireStore.getUSerDocument(currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()),);
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          user = snapshot.data!.data();

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
                        Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: Container(
                            height: 795.h,
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
                          top: 55.h,
                          child: profilePicture(110.h, 110.w, 70.w,context,user!['Profile Picture'],
                              user!['Profile Picture']!=null?DecorationImage(image:
                              //profilePicPath!=null&&profilePicPath!.existsSync()
                              user!['Profile Picture']!=null?Image.file(profilePicPath!).image:NetworkImage(user!['Profile Picture']['imageUrl']),
                              fit: BoxFit.fitWidth,
                            ):null,
                              _profileState!

                        )),
                        Positioned(
                          top: 167.h,
                          child: Padding(
                            padding:  EdgeInsets.symmetric(
                                horizontal: 10.w),
                            child: Column(children: [
                              Text(user!['User Name'],
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
                                    child: Row(
                                      children: [
                                         Icon(
                                            Icons.attach_email_rounded,
                                            color: Colors.grey,
                                            size: 15.w),
                                         SizedBox(width: 5.w),
                                        Text(user!['Email'],
                                            style:  TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12.sp)),
                                      ],
                                    )),
                              ),
                               Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 8.h),
                                child: SizedBox(
                                  width: 300.w,
                                  child: Align(
                                    alignment:
                                    AlignmentDirectional.topCenter,
                                    child: Text(user!['Bio'],
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.sp)),
                                  ),
                                ),
                              ),

                               SizedBox(
                                height: 20.h,
                              ),

                              Column(
                                children: [
                                   Padding(
                                    padding: EdgeInsets.only(right: 230.w),
                                    child:const Text(
                                      'Personal info',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                   SizedBox(height: 10.h),
                                  personalInfo(
                                    user!['Date of Birth'],
                                    'date of birth',
                                    'gender',
                                    user!['Gender'],
                                    Icons.calendar_month,
                                  ),
                                   SizedBox(
                                    height: 5.h,
                                  ),
                                  personalInfo(
                                    user!['mobileNo']??'',
                                    'mobile',
                                    'region',
                                    user!['Location'],
                                    Icons.call,
                                  ),
                                   SizedBox(
                                    height: 5.h,
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
                               SizedBox(
                                height: 20.h,
                              ),
                              Container(
                                  height: 2.h,
                                  width: 320.w,
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
                                  Colors.grey.shade700,context),
                              listTile(
                                  'Settings',
                                  null,
                                  Icons.settings,
                                  Icons.arrow_forward_ios_sharp,
                                  Colors.blueGrey,
                                      ()=> Get.to(const AppSettings()),
                                  Colors.grey.shade700,context),
                              listTile(
                                  'LogOut',
                                  null,
                                  Icons.logout_outlined,
                                  Icons.arrow_forward_ios_sharp,
                                  Colors.red.shade700.withOpacity(0.8),
                                  () async {
                                    // Utils().loadingCircle(context);
                                    // final prefs = await SharedPreferences.getInstance().then((value) =>
                                    //     value.setBool('jumpOnboardingScreen', false));
                                    await _fireStore.signOut(context);
                                    Get.offAll(const Wrapper());
                                    },
                                  Colors.grey.shade700,context),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
         body: Padding(
           padding:  EdgeInsets.symmetric(vertical: 25.h),
           child: SingleChildScrollView(
             scrollDirection: Axis.vertical,
             child: Column(
               children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                    icon:  Icon(Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20.sp),
                    onPressed: () {
                      setState(() {
                        _profileState = ProfileState.CURRENT;
                      });
                    }),
              ),
               SizedBox(
                height: 10.h,
              ),
               Padding(
                padding: EdgeInsets.only(left: 20.w),
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text('Edit Profile',
                      style: TextStyle(color: Theme.of(context).primaryColor,
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.topCenter,
                child: Stack(
                  children: [
                    profilePicture(140.h, 140.w, 90.h,context,user!['Profile Picture'],
                        user!['Profile Picture']!=null?DecorationImage(image: profilePicPath!=null&&profilePicPath!.existsSync()
                            ?Image.file(profilePicPath!).image:NetworkImage(user!['Profile Picture']['imageUrl']),
                          fit: BoxFit.fitWidth,
                        ):null,
                        _profileState!

                    ),

                    Positioned(
                      top: 95.h,
                      left: 100.w,
                      child: Container(
                          height: 40.h,
                          width: 40.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepPurple.shade400
                                  .withOpacity(0.8)),
                          child: Center(
                              child: IconButton(
                                  onPressed:onTapEditProfilePhoto,
                                  icon:  Icon(Icons.add_a_photo,
                                      size: 20.w, color: Colors.white))),

                      ),
                    )
                  ],
                ),
              ),
               SizedBox(height: 30.h),
              listTile(
                  'username',
                  streamBuilder('User Name'),
                  Icons.person_2_outlined,
                  Icons.edit,
                  Theme.of(context).primaryColor,
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
                            _fireStore.updateUserDocument({'User Name': userNameController.text.trim()},currentUser, context);
                            setState((){errorTextField=false;});
                          }},

                        const Text('4 characters minimum',style:TextStyle(color:Colors.red)),
                      '4 characters minimum',
                        TextInputType.name
                    );

                  },
                  Colors.deepPurple,context),
              listTile(
                  'bio',
                  streamBuilder('Bio'),
                  Icons.info_outline_rounded,
                  Icons.edit,
                  Theme.of(context).primaryColor,
                      () =>
                      bottomSheet(
                          'Update Bio', 100, bioController,
                              () {
                            if (bioController.text.trim().isEmpty) {
                              setState((){errorTextField=true;});
                            } else {
                              _fireStore.updateUserDocument({'Bio': '~ ${bioController.text.trim()}'},currentUser, context);
                              setState((){errorTextField=false;});
                            }},
                          const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                          'cancel to retain current .Bio.',
                          TextInputType.text
                      ),
                  Colors.deepPurple,context),
              listTile(
                  'date of birth',
                  streamBuilder('Date of Birth'),
                  Icons.cake_outlined,
                  Icons.edit,
                  Theme.of(context).primaryColor,
                      dateOfBirthPicker,
                  Colors.deepPurple,context),
              listTile(
                  'occupation',
                  streamBuilder('Occupation'),
                  Icons.work_outline_rounded,
                  Icons.edit,
                  Theme.of(context).primaryColor,
                      () {
                    bottomSheet(
                        'Update Occupation',
                        20,
                        occupationController,
                            () {
                          if (occupationController.text.trim().isEmpty){
                            setState((){errorTextField=true;});
                          }else{ _fireStore.updateUserDocument({'Occupation':occupationController.text.trim()}, currentUser, context);
                          setState((){errorTextField=false;});}
                        },

                        const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                        'Profession',
                        TextInputType.name
                    );
                  },
                  Colors.deepPurple,context),
              listTile(
                  'location',
                  streamBuilder('Location'),
                  Icons.work_outline_rounded,
                  Icons.edit,
                  Theme.of(context).primaryColor,
                      () {
                    bottomSheet(
                        'Update Location',
                        20,
                        locationController,
                            () {
                          if (locationController.text.trim().isEmpty){
                            setState((){errorTextField=true;});
                          }else{ _fireStore.updateUserDocument({ 'Location':locationController.text.trim()}, currentUser, context);
                          setState((){errorTextField=false;});}
                        },

                        const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                        'region',
                        TextInputType.streetAddress
                    );
                  },
                  Colors.deepPurple,context),
              listTile(
                  'gender',
                  streamBuilder('Gender'),
                  Icons.person_4_outlined,
                  Icons.arrow_drop_down_sharp,
                  Theme.of(context).primaryColor,
                      () {showMenu(context: context,
                          position:RelativeRect.fromSize( Rect.fromLTWH(10.w, 10.h, 60.w, 50.h),  Size.fromHeight(60.h)),
                          items: [PopupMenuItem(child:const Text('Male'),onTap:()=>_fireStore.updateGenderDocs(currentUser, 'Male'), ),
                            PopupMenuItem(child:const Text('Female'),onTap:() => _fireStore.updateGenderDocs(currentUser, 'Female'),),
                          ]);},
                  Colors.deepPurple,context),

                 listTile(
                     'mobile',
                     Text(
                       user!['mobileNo']??'---',
                     ),
                     Icons.phone,
                     null,
                     Theme.of(context).primaryColor,
                         () {
                       bottomSheet(
                           'Mobile No.',
                           20,
                           occupationController,
                               () {
                             if (occupationController.text.trim().isEmpty){
                               setState((){errorTextField=true;});
                             }else{ _fireStore.updateUserDocument({'mobileNo':occupationController.text.trim()}, currentUser, context);
                             setState((){errorTextField=false;});}
                           },

                           const Text('Text Field is empty',style:TextStyle(color:Colors.red)),
                           'include country code (e.g +234 9123922764)',
                           TextInputType.phone
                       );
                     },
                     Colors.deepPurple,context),

              listTile(
                  'email',
                  Text(
                    user!['Email'],
                  ),
                  Icons.email_outlined,
                  null,
                  Theme.of(context).primaryColor,
                      () {},
                  Colors.deepPurple,context),

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
    width: 350.w,
    height: 50.h,
    child: Padding(
      padding:  EdgeInsets.only(left: 15.w),
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
                 SizedBox(width: 10.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: 120.w,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 14.sp,
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
           SizedBox(width: 20.w),
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
                        fontSize: 14.sp,
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
    Color iconTrailColor,
    BuildContext context) {
  return SizedBox(
    width: 370.w,
    child: ListTile(
      title: Text(title,
          style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: subtitle,
      subtitleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
      leading: Icon(
        iconLead,
        color: color,
      ),
      trailing: Icon(
        iconTrail,
        color: iconTrailColor,
        size: 16.w,
      ),
      onTap: onTap,
    ),
  );
}

Widget profilePicture(double height, double width, double iconHeight,BuildContext context, imageUrl,DecorationImage? image,ProfileState profileState, ) {
  return Container(
    height: height,
    width: width,
    decoration:
     BoxDecoration(shape: BoxShape.circle, color: Colors.white,
    border: Border.all(color: Colors.deepPurple.shade500.withOpacity(0.5),width: 0.5),
    image: image ),
    child: imageUrl==null?Icon(Icons.person,
        color: Theme.of(context).splashColor, size: iconHeight):null,
  );
}

