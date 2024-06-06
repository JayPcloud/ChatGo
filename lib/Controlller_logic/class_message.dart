
class Message {
  String text;
  DateTime date;
  bool isSentByMe;

  Message({required this.date, required this.text, required this.isSentByMe});
}
class MyContact {
  void Function(dynamic)? tap;
  String image;
  String title;

  MyContact({required this.image, required this.title, this.tap});
}