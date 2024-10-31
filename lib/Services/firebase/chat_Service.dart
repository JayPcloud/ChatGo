import 'package:chatgo/Controlller_logic/model/class_message.dart';
import 'package:chatgo/Controlller_logic/model/class_model.dart';
import 'package:chatgo/Services/firebase/firebaseFirestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Controlller_logic/utils.dart';

class ChatService {
  final _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final usersCollectionRef = FirebaseFirestore.instance.collection('users');

  final _fireStoreService = FireStoreService();

  final batch = FirebaseFirestore.instance.batch();

  final _utils = Utils();
  // Get or Stream all list of users
  Stream<List<Map<String, dynamic>>> getAllUsersData() {
    return usersCollectionRef.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          // go through each individual map
          final userDoc = doc.data();

          return userDoc;
        }).toList();
      },
    );
  }
  // Get All User's Added Contacts
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersContactData(User? currentUser) {
    final contactsCollectionRef = FirebaseFirestore.instance.collection("User's Contacts").doc(currentUser!.email).collection('contacts');
    return contactsCollectionRef.orderBy('time',descending: true).snapshots();
  }

// send message

  Future<DocumentReference<Map<String, dynamic>>> sendMessage(String receiverID, message,Map? storyReply, imageUrl, videoUrl,thumbnail, sendersLocalPath,receiverLocalPath, senderThumbnailLP,receiverThumbnailLP) async {
    // get current user info
    final currentUserID = _auth.currentUser!.email!;
    final currentUSerEmail = _auth.currentUser!.email;
    final DateTime timeStamp = DateTime.now();

    // create a new message
    Message newMessage = Message(
        senderID: currentUserID,
        receiverID: receiverID,
        message: message,
        storyReply: storyReply,
        timeStamp: timeStamp,
        imageUrl: imageUrl,
      videoUrl: {'videoUrl':videoUrl,
        'thumbnail': thumbnail,
        // downloaded by the receiver
      'downloaded': false
      },
      received: false,
      unread: true,
      showUnreadMsgIndicator: false,
      localPath: {
          // if its just normal image
          'sender':sendersLocalPath,
        'receiver': receiverLocalPath,
        'stored': false,
        //included if its a video
        'senderThumbnailLP':senderThumbnailLP,
        'receiverThumbnailLP':receiverThumbnailLP,
      }
        );
    print(receiverID);

    // construct chat room ID
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    //add new message to database
    final doc = await _fireStore
          .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
    return doc;
  }

// get chats of user
  Stream<QuerySnapshot<Map<String, dynamic>>>?getMessages(
      String userID, otherUserID) {
    //construct a user ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy(
          'timeStamp',
          descending: false,
        )
        .snapshots();

  }
  // update new message's unread status to read when opened
  void getAndUpdateUnreadStatus ( String userID, otherUserID,String field,Object? object,Map<String, dynamic> data) async {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    final batch = FirebaseFirestore.instance.batch();
      await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages').where(field, isEqualTo: object).get().then((querySnapshot) {querySnapshot.docs.forEach((doc) {
          batch.update(doc.reference, data);
     });batch.commit();
        });
  }
  void updateMsgData ( otherUserID,Map<String, dynamic> data,docID) async {
    List<String> ids = [_auth.currentUser!.email!, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages').doc(docID).update(
      data
    );
  }

  // ADD STORY
Future  addStory ({userID, text, file, required BuildContext context, thumbnail, textInfo}) async {
    final timeStamp = DateTime.now();
    try {
      Story newStory = Story(
          text: text,
          file: file,
          timeStamp: timeStamp
      );
      final docRef =  _fireStore.collection('stories').doc(userID);
      await docRef.set({
        'Email': userID,
        'timeStamp': timeStamp,
         'lastStoryThumbnail': thumbnail,
        'text': textInfo
      }).then((value) async => await docRef.collection('userStory').add(newStory.toMap()));

    } catch (e){
      return _utils.scaffoldMessenger(context, 'upload failed!', 30.h, 100.w, 1, null);
    }

}
Stream <QuerySnapshot<Map<String, dynamic>>> streamContactStories ( list){
    return _fireStore.collection('stories').where('Email', whereIn:  list )
        .where('timeStamp',
        isGreaterThan: DateTime.now().subtract(const Duration(hours: 24))).orderBy('timeStamp', descending: true)
        .snapshots();
    //     .listen((storiesSnapshot) {
    //       storiesSnapshot.docs.forEach((storyDoc) {
    //         storyDoc.reference.collection('userStory').where('timeStamp',
    //             isLessThan: Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 24)))).snapshots();
    //       });
    // }).sna;
}

}
