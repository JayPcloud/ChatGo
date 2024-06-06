import 'package:chatgo/Services/firebaseFirestore.dart';
import'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future <void> passwordReset() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return const Center(child: CircularProgressIndicator(
            strokeCap:StrokeCap.butt ,
          ));
        });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim());
      Navigator.of(context).pop();
      showDialog(context: context,
          builder: (context){
            return AlertDialog(
              title:Text('Password reset'),
              content: Text("Password reset link has been sent! Please check your email"),
            );
          });
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      showDialog(context: context,
          builder: (context){
        return AlertDialog(
          title:Text('ERROR!', style:TextStyle(color:Colors.red)),
          content: Text(e.message.toString()),
          actions:[IconButton(icon:Icon(Icons.close),onPressed: ()=> Get.back(),)]
        );
          });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 200, 20, 0),
        child: Column(
          children: [
            const Text(
                "Enter your user Email and we will send you a password reset link"),
            const SizedBox(height: 10,),
            TextFormField(
              controller: _emailController,
              cursorWidth: 1.3,
              cursorRadius: const Radius.circular(2),
              style: const TextStyle(fontSize: 17),
              // enableSuggestions: true,
              decoration: InputDecoration(

                // errorText: isValidEmail?null:'',
                labelText: "Enter e-mail",
                labelStyle:
                const TextStyle(
                    color: Colors.black26, fontWeight: FontWeight.w600),
                icon: const Icon(Icons.abc),
                contentPadding: const EdgeInsets.only(left: 10),
                border: OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    )),
              ),
            ),
            const SizedBox(height: 10,),
            MaterialButton(shape: const RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.all(Radius.circular(15))),
              color: Colors.deepPurple[200],
              onPressed: passwordReset,
              child: const Text("send link",),
            )
          ],
        ),
      ),
    );
  }
}
