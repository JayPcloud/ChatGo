import 'dart:async';
import 'package:chatgo/Authentication/toggleFromLoginPage.dart';
import 'package:chatgo/Controlller_logic/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../wrapper.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {

  late Timer timer;
  Future<void> sendEmailVerificationLink()async{
    final auth = FirebaseAuth.instance;
    try{
      auth.currentUser?.sendEmailVerification();
    } catch (e){
      Utils().scaffoldMessenger
        (context, 'An error occurred while sending link', 20.h, 10.w, 2, const Icon(Icons.error_outline));
      print(e.toString());
    }
  }
  @override
  void initState() {
    super.initState();
    sendEmailVerificationLink();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser!.reload();
      if(FirebaseAuth.instance.currentUser!.emailVerified){
        timer.cancel();
        Utils().scaffoldMessenger(context, 'Email verified', 20.h, 55, 2,const Icon(Icons.verified,color: Colors.green,));
        Get.offUntil(MaterialPageRoute(builder: (context) => const Wrapper(),), (route) => route.settings.name=='/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor:const Color(0xffBDA2CB),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_email_outlined, size: 80.w,),
            SizedBox(height: 50.h,),
            Text('Verify your email address', style: TextStyle(
                color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.w700),),
            SizedBox(height: 25.h,),
            const Text('We have just sent an email verification link on your email. '
                'Please check your email and click on that link to verify your Email address',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, ),
            ),
            SizedBox(height: 20.h,),
            const Text('if not auto redirected after verification, click on the continue button',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, ),
            ),
            SizedBox(height: 40.h,),
            MaterialButton(onPressed:()=> Get.off(const Wrapper()),
            minWidth: 140.w,
            height: 40.h,
            shape: RoundedRectangleBorder(side:const BorderSide(color: Colors.deepPurple),
                borderRadius:BorderRadiusDirectional.circular(15.r) ),
            child: const Text('Continue',style: TextStyle(color: Colors.deepPurple),),
            ),
           SizedBox(height: 40.h,),
             InkWell(
              onTap: (){
                sendEmailVerificationLink();
                Utils().scaffoldMessenger(context, 'Link sent ', 20.h, 30.w, 2, const Icon(Icons.verified,color: Colors.blue,));
              },
              child: const Text('Resend E-mail Link', style: TextStyle(color: Colors.deepPurple),) ,
            ),
            SizedBox(height: 30.h,),
             InkWell(
              onTap: ()=>Get.offAll(const ToggleSignIn()),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_backspace_sharp, color: Colors.deepPurple,),
                  Text('  Back to login', style: TextStyle(color: Colors.deepPurple),),
                ],
              ) ,
            )
          ],),
      )
    );
  }
}


