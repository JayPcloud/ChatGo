import 'package:chatgo/Authentication/login.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:flutter/material.dart';
class ToggleSignUp extends StatefulWidget {
  const ToggleSignUp({super.key});

  @override
  State<ToggleSignUp> createState() => _ToggleSignUpState();
}

class _ToggleSignUpState extends State<ToggleSignUp> {
  bool showLoginPage=false;

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
