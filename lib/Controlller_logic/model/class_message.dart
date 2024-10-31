class Message {
  final String senderID;
  final String receiverID;
  final String? message;
  final Map? storyReply;
  final DateTime timeStamp;
  final String? imageUrl;
  final Map? videoUrl;
  final bool received;
  final bool unread;
  final bool showUnreadMsgIndicator;
  final Map? localPath;

  //final bool isSentByMe;

  Message( {
    required this.senderID,
    required this.receiverID,
    this.message,
    required this.storyReply,
    required this.timeStamp,
    this.imageUrl,
    this.videoUrl,
    required this.received,
    required this.unread,
    required this.showUnreadMsgIndicator,
    this.localPath
  });

  //convert to a amp
  Map <String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'storyReply': storyReply,
      'timeStamp': timeStamp,
      'imageUrl': imageUrl,
      'received':received,
      'unread': unread,
      'showUnreadMsgIndicator':showUnreadMsgIndicator,
      'videoUrl': videoUrl,
      'localPath':localPath
    };
  }
}

