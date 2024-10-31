import 'package:chatgo/Controlller_logic/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}
class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,iconTheme: IconThemeData(color: Theme.of(context).primaryColor)),
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 40.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.dark_mode, color: Theme.of(context).primaryColor,),
                    Text('  Dark mode', style:
                    TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500, fontSize: 15.sp)),
                  ],
                ),
              //
                Switch(
                  value: ThemeController().isSavedDarkMode(),
                    onChanged: (value) {
                    ThemeController().changeThemeMode();
                    },)
            ],)
          ],
        ),
      ),
    );
  }
}
