import 'package:chatgo/Controlller_logic/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Authentication/toggleFromLoginPage.dart';
import '../Authentication/toggleFromSignUp.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

 bool isLastIndex = false;

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    PageController pageController = PageController();
    return    Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:  EdgeInsets.only(top: 40.h, left: 15.w, right: 15.w, bottom: 10.h),
        child: Column(
          children: [
            Row(children: [
              Text('WELCOME!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800,
                  fontSize: 25.sp),),
            ],),
            SizedBox(width: screenWidth,height: screenHeight*0.8,
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    isLastIndex = index==2;
                  });
                },
                children: [
                  onBoardingWidget(heading: 'Chat with friends and family',
                    imageString: 'assets/onBoarding_chat.jpg',
                    pageController: pageController,
                    info: 'Share thoughts, ideas, and moments with our intuitive chat interface',
                   context: context,
                  ),
                  onBoardingWidget(heading: 'Share story updates',
                      imageString: 'assets/onBoarding_story.jpg',
                      pageController: pageController,
                      info: 'Stay connected with loved ones and share your daily adventures!',
                    context: context,
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10.h,),
                      Image.asset(
                        'assets/onBoarding_signUp.jpg',
                        fit: BoxFit.fill,
                        width: screenWidth*0.8,
                        height: screenHeight*0.4,
                      ),

                      SizedBox(height: 100.h,),

                      MaterialButton(onPressed:() async {

                        Utils().loadingCircle(context);
                        final prefs = GetStorage();
                        prefs.write('jumpOnboardingScreen', true);
                        Navigator.of(context).pop();

                        Get.off(const ToggleSignUp());
                        },
                        //elevation: 15,
                      height: 40.h,
                        minWidth: screenWidth*0.7,
                        color: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10.r)),
                        child: const Text('Sign up',style: TextStyle(color: Colors.white) ),
                      ),

                      SizedBox(height: 30.h,),

                      const Text("Already have an existing account?", style: TextStyle(color: Colors.black54)),

                      SizedBox(height: 20.h,),

                      MaterialButton(onPressed:() async {

                        Utils().loadingCircle(context);
                        final prefs = GetStorage();
                        prefs.write('jumpOnboardingScreen', true);
                        Navigator.of(context).pop();

                        Get.off(const ToggleSignIn());},
                        //elevation: 15,
                        height: 40.h,
                        minWidth: screenWidth*0.4,
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10.r)),
                        child: const Text('login',style: TextStyle(color: Colors.deepPurple) ),
                      ),

                    ],

                  )

                ],

              ),
            ),
            SmoothPageIndicator(
              onDotClicked: (index) => pageController.animateToPage(index, duration: const Duration(seconds: 1), curve: Curves.decelerate),
              controller: pageController,
              count: 3,
              effect: JumpingDotEffect(dotHeight: 5.h,dotWidth: 5.w,activeDotColor: Colors.deepPurple,dotColor: Colors.grey,),
            ),
            !isLastIndex?Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(onPressed:()=>pageController.jumpToPage(2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(5.r),
                    side: const BorderSide(color: Colors.deepPurple,),),
                  minWidth: 20.w,height: 25.h,
                  child: const Text('Skip', style: TextStyle(color: Colors.deepPurple),),
                ),
                MaterialButton(onPressed:()=>pageController.nextPage(
                    duration:const Duration(seconds: 1), curve: Curves.decelerate),
                  minWidth: 10.w,height: 25.h,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(5.r),),
                  color: Colors.deepPurple,
                  child:   Icon(Icons.navigate_next,size: 30.w,color: Colors.white,),

                ),
              ],
            ): const SizedBox()
          ],
        ),
      ),
    );
  }

  Widget onBoardingWidget(
      {context, pageController, imageString, heading, info}){
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(height: 10.h,),
        Image.asset(
          imageString,
          fit: BoxFit.fill,
          width: screenWidth,
          height: screenHeight*0.6,
        ),
         Text(heading, style:  TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w800,
            fontSize: 25.sp),),
        SizedBox(height: 10.h,),
        Expanded(
          child:  Text( info,
            textAlign:  TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black54, fontSize: 14.sp,),),
        ),
        SizedBox(height: 30.h,),

      ],

    );
  }
}
