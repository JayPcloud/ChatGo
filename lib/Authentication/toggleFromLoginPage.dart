import 'package:chatgo/Authentication/login.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:flutter/material.dart';

class ToggleSignIn extends StatefulWidget {
  const ToggleSignIn({super.key,});

  @override
  State<ToggleSignIn> createState() => _ToggleSignInState();
}

class _ToggleSignInState extends State<ToggleSignIn> {
   bool showLoginPage=true;

  void toggleScreens(){
    setState(() {
      showLoginPage=!showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
   if(showLoginPage){return Login(showSignUpPage: toggleScreens,);
   }else{return SignUp(showLoginPage:toggleScreens ,);}
  }
}
