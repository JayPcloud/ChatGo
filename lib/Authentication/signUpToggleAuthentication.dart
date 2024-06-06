import 'package:chatgo/Authentication/login.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:flutter/material.dart';
class SignUpToggle extends StatefulWidget {
  const SignUpToggle({super.key});

  @override
  State<SignUpToggle> createState() => _SignUpToggleState();
}

class _SignUpToggleState extends State<SignUpToggle> {
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
