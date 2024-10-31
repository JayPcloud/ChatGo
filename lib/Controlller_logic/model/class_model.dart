
class Story {
  dynamic text;
  Map? file;
  DateTime? timeStamp ;


  Story({ this.text, this.file, this.timeStamp,});


  Map <String, dynamic> toMap() {
    return {
      'text': text,
      'file': file,
      'timeStamp':timeStamp,
    };
  }
}