import 'package:chatgo/Authentication/authenticate.dart';
import 'package:chatgo/Authentication/login.dart';
import 'package:chatgo/Screens/top_tabs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder:(context, snapshot) {
            if (snapshot.hasData){return const ContactList();
            }else{return const Authenticate();}
          },),
    );
  }
}

