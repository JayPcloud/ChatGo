import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController{

  final _getStorage =  GetStorage();
  final _key = 'isDarkMode';
  ThemeMode getThemeMode (){
    return isSavedDarkMode()? ThemeMode.dark : ThemeMode.light;
  }

  bool isSavedDarkMode ()  {
    return _getStorage.read(_key)??false;
  }
   void saveThemeMode (bool isDarkMode)  {
      _getStorage.write(_key, isDarkMode);
   }

   void changeThemeMode (){
     Get.changeThemeMode(isSavedDarkMode() ? ThemeMode.light : ThemeMode.dark);
     saveThemeMode(!isSavedDarkMode());
   }


}