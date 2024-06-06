import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'class_message.dart';

class ChatController extends GetxController {
  // updates.dart

  //chats
  List<Message> listMessage = [
    Message(
        text: 'Hi',
        isSentByMe: true,
        date: DateTime.timestamp().subtract(Duration(days: 50, hours: 1,minutes: 2))),
    Message(
        text: 'How are you doing',
        isSentByMe: false,
        date: DateTime.now().subtract(Duration(days: 50, hours: 0,minutes: 40))),
    Message(
        text: 'I am good thank you',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 20, hours: 5,minutes: 19))),
    Message(
        text: 'So how is your business going',
        isSentByMe: false,
        date: DateTime.now().subtract(Duration(days: 2,hours: 12,minutes: 21))),
    Message(
        text: 'Its going quite well',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 2, hours: 11))),
    Message(
        text: 've been making huge profits lately',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 2, hours: 10,minutes: 22))),
    Message(
        text: 'Wow! that\'s a very great news u know',
        isSentByMe: false,
        date: DateTime.now().subtract(Duration(
          days: 2,hours: 10,minutes: 5
        ))),
    Message(
        text: 'I know right',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 1,hours: 22,minutes: 37))),

    Message(
        text: 'Yh, i am very happy for you',
        isSentByMe: false,
        date: DateTime.now().subtract(Duration(
          days: 1,hours: 19,minutes: 21
        ))),
    Message(
        text: 'Thank you friend',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 1, hours: 10,minutes: 2))),
    Message(
        text: 'I thank God for his guidance and for seeing me through',
        isSentByMe: true,
        date: DateTime.now().subtract(Duration(days: 1,hours: 9,minutes: 20))),
    Message(text:'Thanks to God' , date:DateTime.now().subtract(const Duration(hours: 13,seconds:23)),
        isSentByMe: false),




  ].obs;
  var noText=true.obs;


final messageController = TextEditingController();

   ifOnChanged (value){
    noText.value=value.isEmpty;
}

  onSend(String text){
  final message =
  Message(
    text: text,
    date: DateTime.now(),
    isSentByMe: true,);
  messageController.text.isEmpty?null
      :listMessage.add(message);
  messageController.clear();
  noText=true.obs;

  }

  // ContactList

  List <MyContact>listOfContacts=[];
 ChatController(){listOfContacts=[
   MyContact(image: 'assets/Screenshot_20240208-060551.jpg', title: 'Jay-P',
       tap: onSend(messageController.text)),
   MyContact (image:'assets/Screenshot_20240224-144455.jpg' ,title:'Steph Curry',
   tap:onSend(messageController.text)),
   MyContact(image: "assets/Screenshot_20240224-144537.jpg", title: "Joseph",tap:onSend(messageController.text)),
   MyContact(image: 'assets/Screenshot_20240224-144606.jpg', title: 'Michelle',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231101-140148.jpg', title:'Thug',tap:onSend(messageController.text)),
   MyContact(image: 'assets/Screenshot_20231016-205011.jpg', title: 'Zeus',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231008-175121.jpg',title:'Xing-Chun',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231008-175033.jpg',title:'Mr.Zi',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20230910-124550.jpg',title:'Zeal',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20230805-202518_1.jpg',title:'Ayo',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20230813-192405.jpg',title:'Boss',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231005-223627.jpg',title:'Brainer',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231018-185709.jpg',title:'Drayco',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231008-175242.jpg',title:'Lin',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20230813-192405.jpg',title:'Boss',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20231013-120822.jpg',title:'yae yae',tap:onSend(messageController.text)),
   MyContact(image:'assets/Screenshot_20240120-001335.jpg',title:'Flutter',tap:onSend(messageController.text)),

 ];}


}

