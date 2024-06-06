import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controlller_logic/class_message.dart';
import '../../Controlller_logic/controller.dart';
import '../Chat/private_chatRoom.dart';
import '../chat/profile_pic.dart';


class MyRecentCalls extends StatelessWidget {
   MyRecentCalls({super.key});
  final ChatController chatController = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:const EdgeInsetsDirectional.symmetric(vertical: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(children:[
          Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
            IconButton(onPressed: () {  },
              icon: Icon(Icons.add_ic_call_outlined,color:Theme.of(context).primaryColor,)),
            const SizedBox(width: 30,),
            IconButton(onPressed: () {  },
              icon: Icon(Icons.video_camera_front_outlined,color:Theme.of(context).primaryColor,)),
              const SizedBox(width: 30,),
            PopupMenuButton(
              color: Theme.of(context).focusColor,
              iconColor: Theme.of(context).primaryColor,
              itemBuilder:(context) => [
                PopupMenuItem(child:Text('Search',
                  style: TextStyle(color: Theme.of(context).primaryColor),)),
                PopupMenuItem(child:Text('Add Contact',
                  style: TextStyle(color: Theme.of(context).primaryColor),)),
                PopupMenuItem(child:Text('Start New Chat',
                  style: TextStyle(color: Theme.of(context).primaryColor),)),
                PopupMenuItem(child:Text('Settings',
                  style: TextStyle(color: Theme.of(context).primaryColor),)),
              ],),
        ],),
          const SizedBox(height: 20,),
          Row(
            children: [
              Text('Recent Calls',style: TextStyle(color: Theme.of(context).primaryColor,),),
            ],
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: chatController.listOfContacts.length,
            itemBuilder: (context, index) {
            return ListTile(
              titleTextStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black87),
              onTap: () {},
              leading: Padding(
                padding: const EdgeInsets.only(left: 0, right: 0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                      chatController.listOfContacts[index].image),
                ),
              ),
              title: Text(
                chatController.listOfContacts[index].title,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              subtitle: Text(
                DateFormat.yMEd()
                    .format(chatController.listMessage.last.date),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              trailing:const Icon(Icons.call),
            );
          },)
        ]

        ),
      ),
    );
  }
}
