import 'package:chatgo/Authentication/login.dart';
import 'package:chatgo/Authentication/signUp.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key,});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
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
