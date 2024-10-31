import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_compress/video_compress.dart';

class Utils {

  void loadingCircle (context){
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context){
          return const Center(child: CircularProgressIndicator(
            strokeCap:StrokeCap.butt ,
          ));
        });
  }
  void scaffoldMessenger (context,text, double? bottom, double padHorizontal, int sec, icon){
    ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10.r)),
          //width: width,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 60.h, horizontal: padHorizontal),
          content: icon==null?Center(
            child:  Text(text, style:const TextStyle(color: Colors.white),))
          : Padding(
            padding:  EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(text, style:const TextStyle(color: Colors.white),)),
                icon
              ],
            ),
          ),
          duration:  Duration(seconds: sec),
          backgroundColor: Colors.white10,
         // margin: EdgeInsets.only(bottom: bottom),
        )
    );
  }

  void confirmDialog (context, info,  void Function()? function, saveContact){
    showDialog(context: context,
              barrierDismissible: true,
              builder:(context) {
                return Center(
                  child: SizedBox( width:230.w, height:100.h,
                    child: Container(
                      decoration: BoxDecoration( color: Colors.deepPurple[200],borderRadius: BorderRadiusDirectional.circular(20.r) ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: saveContact==false?10.h:5.h,),
                          saveContact==false?Text(info, style: TextStyle(color: Colors.white, fontSize: 15.sp),):
                          info,
                          SizedBox(height:saveContact==false?20.h: 0.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            MaterialButton(
                              shape:  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.r))),
                              onPressed: function,
                              child: Text(saveContact==true?'save': 'Yes', style:const TextStyle(color: Colors.deepPurple),),
                            ),
                            MaterialButton(
                              shape:  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.r))),
                              onPressed:()=>Navigator.of(context).pop(),
                              child: const Text('cancel',style: TextStyle(color: Colors.deepPurple)),
                            ),
                          ],)
                        ],
                      ),
                    ),
                  ),
                );
              },);
  }
  Future compressVideo (String filePath) async {
   final compressedVid = await VideoCompress.compressVideo(

     includeAudio: true,
     duration:const Duration(seconds: 1 ).inSeconds,
       filePath,
       quality: VideoQuality.Res960x540Quality);
   return compressedVid;

  }

  Color convertToColor (String colorString){
    print(colorString);
    final colorValue = colorString.replaceAll('Color(','').replaceAll(')', '');
    Color color = Color(int.parse(colorValue));
    return color;
  }

  String timeConverter (Timestamp date){
    final storyTimestamp = date.toDate();
    final now = DateTime.now();
    final timeDifference = now.difference(storyTimestamp);
    if(timeDifference.inSeconds<60){
      return 'now';
    }else if (timeDifference.inMinutes<60&&timeDifference.inSeconds>60){
      return '${timeDifference.inMinutes.toString()}min ago';
    }else {
      return '${timeDifference.inHours.toString()}hr ago';
    }

  }
}