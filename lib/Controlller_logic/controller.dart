import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {

  // private chat room
  void showBottomSheet({required BuildContext context,
    required void Function() choseImageFunction,
    required void Function() cameraImageFunction,
    required void Function() videoFunction,
    required void Function() pickVideoFunction,
  }) {
    showModalBottomSheet(
      context: context,
      constraints:  BoxConstraints(maxHeight: 200.h),
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
      showDragHandle: true,
      builder: (context) =>
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shareIcon(onPressed: cameraImageFunction,
                      context: context,
                      text: 'Camera',
                      icon: Icons.camera),
                  shareIcon(onPressed: choseImageFunction,
                    context: context,
                    text: 'pick Image',
                    icon: Icons.image_outlined,),
                ],),
               SizedBox(height: 30.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  shareIcon(onPressed: videoFunction,
                    context: context,
                    text: 'Video',
                    icon: Icons.video_camera_back_outlined,),
                  shareIcon(onPressed: pickVideoFunction,
                    context: context,
                    text: 'pickMedia',
                    icon: Icons.video_collection_outlined,)
                ],)
            ],
          ),
    );
  }


  // updates.dart
  var showSendIcon = false.obs;

//final messageController = TextEditingController();
  ifOnChanged(String value) {
    // noText.value=value.isEmpty;
    if (value.isNotEmpty) {
      showSendIcon.value = true;
    } else {
      showSendIcon.value = false;
    }
  }

  Widget shareIcon(
      {required void Function() onPressed, required BuildContext context, required String text, required IconData icon}) {
    return MaterialButton(
      elevation: 20.dm,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.circular(20.r)),
      onPressed: onPressed,
      child: Row(children: [
        Icon(icon, color: Theme
            .of(context)
            .primaryColor,),
        Text(text, style: TextStyle(color: Theme
            .of(context)
            .primaryColor),),
      ],),
    );
  }
}
