import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  // bool isValidEmail = true;
  // bool isValidPassword=true;
  // String errorMessage = '';
  // String errorEmail = '';




  Future signInEP() async {

      showDialog(context: context,
         barrierDismissible: false,
          builder: (context){
            return const Center(child: CircularProgressIndicator(
              strokeCap:StrokeCap.butt ,
            ));
          });

    try{await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password:passwordController.text.trim());
    Navigator.of(context).pop();
    } on FirebaseAuthException catch(e){
      Navigator.of(context).pop();
      showDialogMessage(e.message.toString(),);
    }
  }

  void showDialogMessage (String message,){
   showDialog(context: context,
       builder: (context) => AlertDialog(
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
            height: 805.5,
            width: 400,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 60, left: 125),
            child: Text('CHAT-GO',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(color: Colors.pinkAccent, blurRadius: 4)
                    ])),
          ),
          const Padding(
            padding: EdgeInsets.only(
              top: 140,
              left: 10,
            ),
            child: Text('LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200, left: 10, right: 10),
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 240, left: 30, right: 30),
            child: TextFormField(
              controller: emailController,
              // onChanged: (value) {
              //   setState(() {
              //     errorEmail = '';
              //     isValidEmail;
              //   });
              // },
              cursorWidth: 1.3,
              cursorRadius: const Radius.circular(2),
              style: const TextStyle(fontSize: 17),
              // enableSuggestions: true,
              decoration: InputDecoration(

                //errorText: isValidEmail?null:errorEmail,
                labelText: "e-mail",
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
          ),
          Padding(
            padding: const EdgeInsets.only(top: 320, left: 30, right: 30),
            child: TextFormField(
              obscureText: showPassword==false?true:false,
              // onChanged: (value) {
              //   setState(() {
              //     errorMessage = '';
              //   });
              // },
              controller: passwordController,
              cursorWidth: 1.3,
              maxLength: 12,
              // cursorRadius: const Radius.circular(2),
              style: const TextStyle(fontSize: 17),
              // enableSuggestions: true,
              decoration: InputDecoration(
                //errorText: isValidPassword?null:errorMessage ,
                suffixIcon: IconButton(onPressed:() {
                  if (showPassword==true){setState(() {showPassword=false;});
                  } else {setState(() {
                    showPassword=true;
                  });}},
                    icon:showPassword==true?Icon(Icons.visibility):Icon(Icons.visibility_off) ),

                labelText: "password",
                labelStyle: const TextStyle(
                  color: Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                icon: const Icon(Icons.lock),
                contentPadding: const EdgeInsets.only(left: 10),
                border:

                OutlineInputBorder(
                    gapPadding: 0,
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                      width: 10,
                    )),
              ),
            ),
          ),


          Padding(
              padding: const EdgeInsets.only(top: 390, left: 18),
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
                        const SizedBox(width: 57),
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
            padding: const EdgeInsets.only(top: 440, left: 130,),
            child: TextButton(
              onPressed: signInEP,
              style: ButtonStyle(
                // fixedSize: MaterialStatePropertyAll(Size(20,10)),
                  textStyle: const MaterialStatePropertyAll(
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  overlayColor: const MaterialStatePropertyAll(Colors.blue),
                  backgroundColor: const MaterialStatePropertyAll(
                      Colors.redAccent),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(15)))),
              child:  const Text("     LOGIN     "),
            ),
          ),
         Padding(
           padding: const EdgeInsets.only(top: 510,),
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



