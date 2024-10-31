import 'package:chatgo/Services/firebase/firebaseFirestore.dart';
import 'package:chatgo/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Controlller_logic/utils.dart';


class SignUp extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignUp({super.key, required this.showLoginPage});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool? isChecked = false;
  bool isValidEmail = true;
  bool isValidPassword=true;
  bool passwordMatch=true;
  String errorMessage = '';
  String errorEmail = '';
  bool showPassword = true;
  String confirmError='password does not match';
  bool isValidUserName=true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController= TextEditingController();
  final confirmPassController= TextEditingController();

  final _fireStore = FireStoreService();

  final _utils = Utils();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }
  bool validCredentials() {
    closeSnackBar();
    RegExp emailRegex =
    RegExp(r'^[a-zA-Z0-9_.+-]+@gmail\.com$', caseSensitive: false);
    String email = emailController.text.trim();
    setState(() {isValidEmail=emailRegex.hasMatch(email);});

    //email
    if (isValidEmail){
      errorEmail = '';
    }else{ errorEmail = 'Email-address is not valid';
    }

    String password = passwordController.text.trim();

    if (password.length >= 6 && isValidEmail==true) {
      //Get.toNamed('/contacts');
      closeSnackBar();

    } else {if(password.isEmpty&&email.isEmpty){
      errorMessage='input password';
      errorEmail='input email';
    }}
    //password
    if (password.length >= 6){
      isValidPassword=true;
      setState(() {closeSnackBar();

      });
    }else{
      errorMessage = 'Invalid password';
      snackBar('password! : minimum of 6 characters',Colors.black,
          IconButton(icon:  Icon(Icons.close,size:20.w,),
              onPressed:closeSnackBar,));
      isValidPassword=false;

      //confirmPassword

      String confirmPass=confirmPassController.text.trim();

      if(confirmPass==password){setState(() {
        passwordMatch=true;});
      }else{setState(() {
        passwordMatch=false;});}
    }
    final userName=userNameController.text.trim();
    if(userName.length<4){
      isValidUserName=false;
    }else{isValidUserName=true;}

    if(isValidEmail && isValidPassword && passwordMatch==true && isValidUserName==true){
      return true;
    }else{return false;}
  }
  void snackBar (String message,Color color, Widget icon){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(message),
            icon,
          ],
        ),
          duration:const Duration(seconds:5),
          //showCloseIcon: close,
          dismissDirection: DismissDirection.horizontal,
          width: 320.w,
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(20)),
          behavior:SnackBarBehavior.floating,));
  }
  void closeSnackBar(){
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
  // Register

  Future register ()async{

   if(validCredentials()==true){

     _utils.loadingCircle(context);

     try{
       if(validCredentials()==true){
         UserCredential? userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
             email: emailController.text.trim(),
             password: passwordController.text.trim()
         ).then((value) async {
           await _fireStore. createUserDocument(
               userNameController.text.trim(),
               value,
               passwordController.text.trim(),
               userNameController.text.trim().toLowerCase()
           );
           Get.off(const Wrapper());
           //Navigator.pop(context);
         });




         //Get.offAll(()=>Login(showSignUpPage: ()=>Get.to(SignUp(showLoginPage: () => Get.back(),)),));

         snackBar('User created successfully',Colors.black,const Icon(Icons.verified_outlined,color: Colors.green,));

       } } on FirebaseAuthException catch(e){
       Navigator.of(context).pop();
       showDialog(context: context,
         builder: (context) => AlertDialog(
             title: Text('ERROR!',style:TextStyle(color:Colors.red)),
             content: Text(e.message.toString())
         ),);
     }
   }



  }

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
            child: Text('signUp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 200.h, left: 10.w, right: 10.w),
            child: Container(
              height: 450.h,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30.r)),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 230.h, left: 30.w, right: 30.w),
            child: TextFormField(
              controller: userNameController,
              onChanged: (value) {
                setState(() {
                  isValidUserName=true;
                });
              },
              cursorWidth: 1.3.w,
              cursorRadius:  Radius.circular(2.r),
              style:  TextStyle(fontSize: 17.sp),
              // enableSuggestions: true,
              decoration: InputDecoration(
                errorText: isValidUserName==true?null:'at-least four characters',
                labelText: "username",
                labelStyle:
                const TextStyle(
                    color: Colors.black26, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.abc),
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
            padding:  EdgeInsets.only(top: 300.h, left: 30.w, right: 30.w),
            child: TextFormField(
              controller: emailController,
              onChanged: (value) {
                setState(() {
                  isValidEmail=true;
                });
              },
              cursorWidth: 1.3.w,
              cursorRadius:  Radius.circular(2.r),
              style:  TextStyle(fontSize: 17.sp),
              // enableSuggestions: true,
              decoration: InputDecoration(

                errorText: isValidEmail==true?null:errorEmail,
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
            padding:  EdgeInsets.only(top: 370.h, left: 30.w, right: 30),
            child: TextFormField(
              obscureText: showPassword==false?true:false,
              onChanged: (value) {
                setState(() {
                  isValidPassword=true;
                  closeSnackBar();
                });
              },
              controller: passwordController,
              cursorWidth: 1.3.w,
              maxLength: 12,
              style:  TextStyle(fontSize: 17.sp),
              decoration: InputDecoration(
                errorText: isValidPassword==true?null:errorMessage ,
                suffixIcon: IconButton(onPressed:() {
                  if (showPassword==true){setState(() {showPassword=false;});
                  } else {setState(() {
                    showPassword=true;
                  });}},
                    icon:showPassword==true?const Icon(Icons.visibility):const Icon(Icons.visibility_off) ),

                labelText: "password(6 characters min.)",
                labelStyle: const TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.lock),
                contentPadding:  EdgeInsets.only(left: 10.w),
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
            padding:  EdgeInsets.only(top: 440.h, left: 30.w, right: 30.w),
            child: TextFormField(
              obscureText: showPassword==false?true:false,
              onChanged: (value) {
               setState(() {
                 confirmError='';
               });

              },
              controller: confirmPassController,
              cursorWidth: 1.3.w,
              style:  TextStyle(fontSize: 17.sp),
              decoration: InputDecoration(
                 errorText:confirmPassController.text.trim()==passwordController.text.trim()?null:confirmError ,
                labelText: "confirm_password",
                labelStyle: const TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.system_security_update_good),
                contentPadding:  EdgeInsets.only(left: 10.w),
                border: OutlineInputBorder(
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
              padding:  EdgeInsets.only(top: 500.h, left: 18.w),
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
                    ]),
                  )
                ],
              )),

          Padding(
            padding:  EdgeInsets.only(top: 550.h, left: 130.w,),
            child: TextButton(
              onPressed: register,
              style: ButtonStyle(
                // fixedSize: MaterialStatePropertyAll(Size(20,10)),
                  textStyle:  MaterialStatePropertyAll(
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  overlayColor: const MaterialStatePropertyAll(Colors.blue),
                  backgroundColor: const MaterialStatePropertyAll(
                      Colors.redAccent),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(15.r)))),
              child:const Text("     Register     "),
            ),
          ),
          Padding(
            padding:  EdgeInsets.only(top: 610.h,),
            child: Center(
              child: GestureDetector(
                onTap:widget.showLoginPage,
                child: RichText(
                    text:const TextSpan(
                        children: [
                          TextSpan(text: 'SignIn',
                            style: TextStyle(color: Colors.deepPurple,
                              fontWeight: FontWeight.w700,

                            ),
                          ),
                          TextSpan(text: ' to an existing account'),
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
