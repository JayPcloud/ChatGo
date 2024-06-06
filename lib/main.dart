import 'package:chatgo/Authentication/authenticate.dart';
import 'package:chatgo/Authentication/forgotPassword.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:chatgo/Authentication/signUpToggleAuthentication.dart';
import 'package:chatgo/Screens/otherScreens/profile.dart';
import 'package:chatgo/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Controlller_logic/class_message.dart';
import 'Screens/top_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Screens/chat/profile_pic.dart';
import 'Controlller_logic/theme_constants.dart';
import 'Screens/chat/private_chatRoom.dart';
import 'Controlller_logic/controller.dart';
import 'Authentication/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp(contact: MyContact(image: '', title: '',),));
}

class MyApp extends StatefulWidget {
    MyApp({super.key,required this.contact});
  final MyContact contact;
 
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   ChatController chatController = Get.put(ChatController());

   // toggle between signUp and login page
   bool showLoginPage=false;
   void toggleScreens(){
     setState(() {
       showLoginPage=!showLoginPage;
     });
   }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,

      themeMode: ThemeMode.light,
      getPages: [
        GetPage(name: "/welcome", page: () => MyApp(contact: widget.contact,)),
        GetPage(
          name: "/login",
          page: () =>  Login(showSignUpPage: () {  },),
        ),
        GetPage(name: "/chat", page: () => ChatPage(myContact:widget.contact, pic:widget.contact, ),),
        GetPage(name: "/contacts", page: () =>const ContactList(),),
        GetPage(name: "/forgotPassword", page: () =>const ForgotPassword(),),
        GetPage(name: "/wrapper", page: () =>const Wrapper(),),
        GetPage(name: "/profilePage", page: () =>const ProfilePage(),),
        GetPage(name: "/signUp", page: () => SignUp(showLoginPage: () {  },),preventDuplicates: true),
        GetPage(name: "/profilePic", page: () => ShowProfilePicture(pic:widget.contact, ),
        transition: Transition.fadeIn,)

      ],
      home: Scaffold(backgroundColor: Colors.deepPurple.shade100,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 50,
          shadowColor: Colors.black,
          title: const Text('Chat-Go',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                // shadows: [Shadow(color: Colors.red, blurRadius: 5)],
              )),
        ),
        body: Stack(children: [
          Positioned(
            left: 87,
            top: 30,
            child: AnimatedContainer(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.indigoAccent.shade100,
                  borderRadius:const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20))),
              duration:const Duration(seconds: 10),
              child:const Center(
                child: Text(
                  'WELCOME!',
                  style: TextStyle(
                    shadows: [Shadow(color: Colors.red, blurRadius: 10)],
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 35,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 70,
            right: 0,
            child: Image.asset(
              'assets/Screenshot_20240118-225647.jpg',
              fit: BoxFit.fill,
              height: 450,
            ),
          ),
          Positioned(
            top: 540,
            left: 80,
            child: TextButton(
              onPressed: (){Get.to(SignUpToggle());},
              style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(20))),
                  backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
                  side:
                  const MaterialStatePropertyAll(BorderSide(color: Colors.blue)),
                  elevation: const MaterialStatePropertyAll(50),
                  fixedSize:const MaterialStatePropertyAll(Size(200, 40))),
              child:const Text("SignUp"),
            ),
          ),
          const Positioned(
              top: 590,
              left: 70,
              child: Text("Already have an existing account?")),
            Positioned(
            top: 610,
            left: 130,
            child: TextButton(
              onPressed: () => Get.toNamed("/wrapper"),
              style: ButtonStyle(
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(20))),
                backgroundColor:const MaterialStatePropertyAll(Colors.transparent),
                // side: MaterialStatePropertyAll(BorderSide(color: Colors.blue)),
                elevation:const MaterialStatePropertyAll(50),
                fixedSize: const MaterialStatePropertyAll(Size(90, 10)),
              ),
              child: const Text(
                "SIGN-IN",
                style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
