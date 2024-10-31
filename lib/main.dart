import 'package:chatgo/Authentication/forgotPassword.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:chatgo/Controlller_logic/theme_controller.dart';
import 'package:chatgo/Screens/onBoarding_Screen.dart';
import 'package:chatgo/Screens/otherScreens/profile.dart';
import 'package:chatgo/Services/connectivity_check.dart';
import 'package:chatgo/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'Screens/top_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Screens/chat/profile_pic.dart';
import 'Controlller_logic/theme_constants.dart';
import 'Controlller_logic/controller.dart';
import 'Authentication/login.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
   await Firebase.initializeApp();
  //final prefs = await SharedPreferences.getInstance();
  await GetStorage.init();
  Get.put(ConnectivityController());

  final getStorage = GetStorage();
  final jumpOnboardingScreen = getStorage.read('jumpOnboardingScreen',)??false;
  print(jumpOnboardingScreen);
  runApp(  MyApp(jumpOnboardingScreen:jumpOnboardingScreen,  ));
}

class MyApp extends StatefulWidget {
  final bool jumpOnboardingScreen;
  const MyApp({super.key, required this.jumpOnboardingScreen, });


  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   ChatController chatController = Get.put(ChatController());

   @override
   void initState() {
     super.initState();
     splashRemove();
     SystemChrome.setPreferredOrientations([
       DeviceOrientation.portraitUp,

     ]);
  }

 Future<void> splashRemove() async {
     print('pausing...');
     await Future.delayed(const Duration(seconds: 1));
     print('unpausing');
     FlutterNativeSplash.remove();
 }
   // toggle between signUp and login page
   bool showLoginPage=false;
   void toggleScreens(){
     setState(() {
       showLoginPage=!showLoginPage;
     });
   }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:const Size(360.0, 805.5),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Themes.lightTheme,
        darkTheme: Themes.darkTheme,
        themeMode: ThemeController().getThemeMode(),
        getPages: [
          GetPage(name: "/welcome", page: () =>  MyApp(jumpOnboardingScreen: widget.jumpOnboardingScreen,)),
          GetPage(
            name: "/login",
            page: () =>  Login(showSignUpPage: () {  },),
          ),
          //GetPage(name: "/chat", page: () => ChatPage(contactName: , imageUrl: '', ),),
          GetPage(name: "/contacts", page: () =>const ContactList(),),
          GetPage(name: "/forgotPassword", page: () =>const ForgotPassword(),),
          GetPage(name: "/wrapper", page: () =>const Wrapper(),),
          GetPage(name: "/profilePage", page: () =>const ProfilePage(),),
          GetPage(name: "/signUp", page: () => SignUp(showLoginPage: () {  },),preventDuplicates: true),
          GetPage(name: "/profilePic", page: () => ShowPicture( ),
          transition: Transition.fadeIn,)

        ],
        home: widget.jumpOnboardingScreen?const Wrapper(): const OnBoardingScreen()
        // const Wrapper()

      ),
    );
  }
}
