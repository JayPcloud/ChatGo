import 'package:chatgo/Controlller_logic/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Screens/chat/private_chatRoom.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  final VoidCallback showSignUpPage;
  const Login({super.key, required this.showSignUpPage});


  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();



  bool? isChecked = false;
  bool showPassword = true;

  Future signInEP() async {

    Utils().loadingCircle(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password:passwordController.text.trim()
      );

    Navigator.of(context).pop();
    Get.offAllNamed("/wrapper");

    } on FirebaseAuthException catch(e){
      Navigator.of(context).pop();
      showDialogMessage(e.message.toString(),);
    }
  }

  void showDialogMessage (String message,){
   showDialog(context: context,
        barrierDismissible: false,
       builder: (context) => AlertDialog(
           title: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
             const Text('ERROR!',style: TextStyle(color: Colors.redAccent),),
             IconButton(onPressed:() => Navigator.pop(context),
                 icon: const Icon(Icons.cancel))
           ],),
           content: Text(message)),);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
//final AuthService _auth = AuthService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(children: [
          Image.asset(
            "assets/Screenshot_20240120-001335.jpg",
            fit: BoxFit.fill,
            height: 805.5.h,
            width: 400.w,
          ),
           Padding(
            padding: EdgeInsets.only(top: 60.h, left: 125.w),
            child: Text('CHAT-GO',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(color: Colors.pinkAccent, blurRadius: 4.r)
                    ])),
          ),
           Padding(
            padding: EdgeInsets.only(
              top: 140.h,
              left: 10.w,
            ),
            child: Text('LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 200.h, left: 10.w, right: 10.w),
            child: Container(
              height: 350.h,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30.r)),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 240.h, left: 30.w, right: 30.w),
            child: TextFormField(
              controller: emailController,
              cursorWidth: 1.3.w,
              cursorRadius:  Radius.circular(2.r),
              style:  TextStyle(fontSize: 17.sp),
              decoration: InputDecoration(
                labelText: "e-mail",
                labelStyle:
                const TextStyle(
                    color: Colors.black26, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.email),
                contentPadding:  EdgeInsets.only(left: 10.w),
                border: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                      
                    )),
              ),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 320.h, left: 30.w, right: 30.w),
            child: TextFormField(
              obscureText: showPassword==false?true:false,
              controller: passwordController,
              cursorWidth: 1.3.w,
              maxLength: 12,
              style:  TextStyle(fontSize: 17.sp),
              decoration: InputDecoration(
                suffixIcon: IconButton(onPressed:() {
                  if (showPassword==true){setState(() {showPassword=false;});
                  } else {setState(() {
                    showPassword=true;
                  });}},
                    icon:showPassword==true?const Icon(Icons.visibility):const Icon(Icons.visibility_off) ),

                labelText: "password",
                labelStyle: const TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.lock),
                contentPadding:  EdgeInsets.only(left: 10.r),
                border:

                OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:  BorderSide(
                      color: Colors.black12,
                      width: 10.w,
                    )),
              ),
            ),
          ),


          Padding(
              padding:  EdgeInsets.only(top: 390.h, left: 18.w),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (newBool) {
                      setState(() {
                        isChecked = newBool;
                      });
                    },
                    activeColor: Colors.transparent,
                    side: const BorderSide(
                      color: Colors.white,
                    ),
                    checkColor: Colors.green,
                    fillColor: const MaterialStatePropertyAll(Colors.white24),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        RichText(
                          text: const TextSpan(children: [
                            TextSpan(
                                text: "Remember Me",
                                style: TextStyle(
                                  color: Colors.black38,
                                )),
                          ]),
                        ),
                         SizedBox(width: 57.w),
                         GestureDetector(
                           onTap:()=> Get.toNamed("/forgotPassword"),
                           child: const Text("forgot password?",
                              style: TextStyle(
                                color: Colors.purple,
                              )),
                         ),
                      ],
                    ),
                  )
                ],
              )),

          Padding(
            padding:  EdgeInsets.only(top: 440.h, left: 130.w,),
            child: TextButton(
              onPressed: signInEP,
              style: ButtonStyle(
                // fixedSize: MaterialStatePropertyAll(Size(20,10)),
                  textStyle:  MaterialStatePropertyAll(
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  overlayColor: const MaterialStatePropertyAll(Colors.blue),
                  backgroundColor: const MaterialStatePropertyAll(
                      Colors.redAccent),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(15.r)))),
              child:  const Text("     LOGIN     "),
            ),
          ),
         Padding(
           padding:  EdgeInsets.only(top: 510.h,),
           child: Center(
             child: GestureDetector(
               onTap: widget.showSignUpPage,
               child: RichText(
                   text:const TextSpan(
                 children: [
                  TextSpan(text: 'Not a User?'),
                  TextSpan(text: '  Create Account',
                      style: TextStyle(color: Colors.deepPurple,
                       fontWeight: FontWeight.w700,

                      ),
                  ),
                 ]
               )),
             ),
           ),
         )
        ]),
      ),
    );
  }

}



