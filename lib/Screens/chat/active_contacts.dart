import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Controlller_logic/class_message.dart';
import '../../Controlller_logic/controller.dart';
import 'private_chatRoom.dart';
import 'profile_pic.dart';


class ActiveContacts extends StatelessWidget {
   ActiveContacts({super.key});
  final ChatController chatController = Get.put(ChatController());
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatController.listOfContacts.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black87),
          onTap: () => Get.to(()=>ChatPage(
            myContact: MyContact(
                image: chatController.listOfContacts[index].image,
                title: chatController.listOfContacts[index].title,
                tap: chatController.listOfContacts[index].tap
            ),
            pic: MyContact(
              image: chatController.listOfContacts[index].image,
              title: chatController.listOfContacts[index].title,
            ),
          )),
          leading: GestureDetector(
            onTap: () => Get.to(ShowProfilePicture(
                pic: MyContact(
                    image: chatController.listOfContacts[index].image,
                    title:
                    chatController.listOfContacts[index].title))),
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(
                    chatController.listOfContacts[index].image),
              ),
            ),
          ),
          title: Text(
            chatController.listOfContacts[index].title,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          subtitle: Text(
            chatController.listMessage.last.text,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          trailing: Text(
            DateFormat.Hm()
                .format(chatController.listMessage.last.date),
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        );
      },
    );
  }
}
