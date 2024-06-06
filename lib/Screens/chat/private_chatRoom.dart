import 'profile_pic.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '../../Controlller_logic/class_message.dart';
import '../../Controlller_logic/controller.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.myContact, required this.pic, this.tap});

  final MyContact myContact;
  final MyContact pic;
  final void Function()? tap;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatController chatController = Get.put(ChatController());



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: AppBar(

          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            widget.myContact.title,
            style:const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.call,
                      color: Colors.white70,
                    )),
                const SizedBox(
                  width: 15,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white70,
                    )),
                const SizedBox(
                  width: 15,
                ),
                PopupMenuButton(
                  color: Theme.of(context).focusColor,
                  iconColor: Colors.white,
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
              ],
            )
          ],
          leading:  Padding(
            padding:const EdgeInsets.all(7.0),
            child: InkWell(
              onTap: ()=> Get.to(ShowProfilePicture(pic: MyContact(image:widget.pic.image, title:widget.pic.title))),
              child: CircleAvatar(
                backgroundImage:AssetImage(widget.myContact.image)
                ),
            ),
            ),
          elevation: 15,
          shadowColor: Colors.black, ),

        body: Column(
          children: [
            Container(

        ),
            Expanded(
              child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsetsDirectional.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                stickyHeaderBackgroundColor:Colors.transparent ,
                dragStartBehavior: DragStartBehavior.down,
                addAutomaticKeepAlives: true,
                elements: chatController.listMessage,
                groupBy: (message) => DateTime(
                  message.date.year,
                  message.date.month,
                  message.date.day,
                ),
                groupHeaderBuilder: (Message message) => Padding(
                  padding: const EdgeInsets.only(left: 130, right: 130),
                  child: SizedBox(
                    height: 30,
                    child: Card(
                      color: Colors.transparent,
                      elevation: 10,
                      child: Center(
                          child: Text(
                        DateFormat.yMMMd().format(message.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                    ),
                  ),
                ),
                itemBuilder: (context, Message message) => Align(
                  alignment: message.isSentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:message.isSentByMe
                              ?const BorderRadiusDirectional.only(
                            topStart: Radius.circular(15),
                            bottomEnd: Radius.circular(15),
                            bottomStart: Radius.circular(15),
                          )
                              : const BorderRadiusDirectional.only(
                        topEnd: Radius.circular(15),
                              bottomEnd: Radius.circular(15),
                            bottomStart: Radius.circular(15),
                      )),
                      elevation: 8,
                      color: message.isSentByMe
                          ? Colors.white
                          : Colors.deepPurple,
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 20,left: 10),
                                child: Text(message.text),
                              ),
                              Text(DateFormat.Hm().format(message.date),
                              style:const TextStyle(fontSize: 10,color: Colors.blue),),
                            ],
                          ))),
                ),
              ),
            ),
            Padding(
              padding:const  EdgeInsets.only(left: 3, right: 3, bottom: 5),
              child:   TextField(
                  onChanged: chatController.ifOnChanged,
                   //onChanged: chatController.ifOnChanged(),
                  // (value){
                  //   if (chatController.messageController.text == '') {
                  //     setState(() {
                  //       chatController.noText.value = true;
                  //     });
                  //   } else {
                  //     setState(() {
                  //       chatController.noText.value = false;
                  //     });
                  //   }},

                  style:  TextStyle(fontSize: 18,
                  color:Theme.of(context).primaryColor, ),
                  controller: chatController.messageController,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                        onPressed: () {},
                        icon:  Icon(Icons.emoji_emotions_outlined,
                        color:Theme.of(context).indicatorColor ,)),
                    contentPadding:
                        const EdgeInsetsDirectional.only(start: 5, end: 5),
                    fillColor: Colors.black12,
                    filled: true,
                    hintText: 'Enter_Message',
                    hintStyle:  TextStyle(
                      color: Theme.of(context).indicatorColor,
                      fontWeight: FontWeight.w500,
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    suffixIcon:
                        // ?  Row(
                        //       mainAxisAlignment: MainAxisAlignment.end,
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         IconButton(
                        //             onPressed: () {},
                        //             icon: const Icon(Icons.attach_file_outlined)),
                        //         IconButton(
                        //             onPressed: () {},
                        //             icon: const Icon(
                        //               Icons.keyboard_voice,
                        //               color: Colors.deepPurple,
                        //             )),
                        //       ],
                        //
                        // )
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon:  Icon(Icons.attach_file_outlined,
                                    color: Theme.of(context).indicatorColor,)),
                                IconButton(
                                    onPressed:()=>
                                       setState(() {
                                         chatController.onSend(chatController.messageController.text);

                                       }),
                                    icon:  Obx(
                                      () =>  Icon( chatController.noText.value?
                                          Icons.keyboard_voice:Icons.send,
                                          color: Colors.deepPurple,
                                      ),
                                    )),
                              ],

                        ),
                  ),
                ),
              ),

          ],
        ));
  }
}
