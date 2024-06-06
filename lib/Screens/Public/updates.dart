import 'package:chatgo/Controlller_logic/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PublicUpdates extends StatefulWidget {
  PublicUpdates({super.key});

  @override
  State<PublicUpdates> createState() => _PublicUpdatesState();
}

class _PublicUpdatesState extends State<PublicUpdates> {
  // final _horizontalScrollController = ScrollController();
  ChatController chatController = Get.put(ChatController());

  bool liked = false;

  var noOfLikes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: CircleBorder(),
        backgroundColor: Colors.purple[300],
      child:Icon(Icons.post_add_outlined,color:Theme.of(context).primaryColor ,),),
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  'Story',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                TextButton(
                  style: ButtonStyle(
                      //side: MaterialStatePropertyAll(BorderSide(color: Colors.blue,width:2)),
                      iconSize: const MaterialStatePropertyAll(15),
                      padding:
                          const MaterialStatePropertyAll(EdgeInsets.all(8)),
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.purple[300]),
                      shape: const MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadiusDirectional.all(
                                  Radius.circular(15))))),
                  onPressed: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        'Add Story',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                          width: 70,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadiusDirectional.circular(10))),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  itemCount: chatController.listOfContacts.length,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        size: 25,
                        Icons.search_rounded,
                        color: Colors.black54,
                      )),
                  Row(children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        size: 27,
                        Icons.notifications_none_sharp,
                        color: Colors.black54,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        size: 27,
                        Icons.contact_page_outlined,
                        color: Colors.black54,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {},
                        child: const CircleAvatar(
                          radius: 17,
                          backgroundImage: AssetImage(
                              'assets/Screenshot_20240224-144455.jpg'),
                        )),
                  ])
                ],
              ),
              const Divider(
                color: Colors.black,
                thickness: 0.1,
              ),
              ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 400,
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(color: Colors.black, width: 0.1)),
                      ),
                      child: Column(
                          verticalDirection: VerticalDirection.up,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                      padding: const MaterialStatePropertyAll(
                                          EdgeInsets.all(0)),
                                      fixedSize: const MaterialStatePropertyAll(
                                          Size(0, 0)),
                                      shape: MaterialStatePropertyAll(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                        side: const BorderSide(
                                            color: Colors.grey),
                                      ))),
                                  onPressed: () {
                                    if (liked == false) {
                                      setState(() {
                                        liked = true;
                                        noOfLikes++;
                                      });
                                    } else {
                                      setState(() {
                                        liked = false;
                                        noOfLikes--;
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: liked == false
                                                ? Icon(
                                                    color: Colors.grey[700],
                                                    Icons.thumb_up_alt_outlined,
                                                    size: 20,
                                                  )
                                                :const Icon(
                                                    Icons.thumb_up_alt,
                                                    color: Colors.purpleAccent,
                                                    size: 20,
                                                  )),
                                        Expanded(
                                            child: Text(noOfLikes == 0
                                                ? ''
                                                : noOfLikes.toString())),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.messenger_outline_rounded,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.ios_share,
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.share,
                                      size: 20,
                                    )),
                              ],
                            )
                          ]),
                    );
                  },
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics())
            ],
          ),
        ),
      ),
    );
  }
}
