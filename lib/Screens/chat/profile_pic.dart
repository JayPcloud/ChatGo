import 'package:chatgo/Controlller_logic/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controlller_logic/class_message.dart';
class ShowProfilePicture extends StatelessWidget {

   ShowProfilePicture({super.key, required this.pic});
   final MyContact pic ;

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black87,
      appBar:AppBar(backgroundColor: Colors.black,

      actions: [Expanded(
        child: Row(
          mainAxisAlignment:  MainAxisAlignment.start,
            children:[Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
               onPressed: () {Get.offNamed('/contacts');},
               icon:const Icon(Icons.arrow_back_ios,color: Colors.white,), ),
        ),

         Padding(
           padding: const EdgeInsets.only(),
           child: Text(pic.title,style:const TextStyle(color: Colors.white,fontSize: 20),),
         )]),
      )],


      automaticallyImplyLeading: false,
      ),
        body:Container(height:700,width:400,
         decoration: const BoxDecoration(color: Colors.black,),
         child: Padding(
           padding: const EdgeInsets.only(left: 0,right: 0,top: 100,bottom: 100),
           child: Image.asset(pic.image,fit: BoxFit.fill),
         ),
    ),
    );

  }
}
