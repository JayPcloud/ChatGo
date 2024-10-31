import 'package:flutter/material.dart';

class Themes {
  static final lightTheme = ThemeData(
    //colorScheme: const ColorScheme.light(),
    //scaffoldBackgroundColor: Colors.deepPurple.shade100,
     // Theme.of(context).colorScheme.onSecondary
      scaffoldBackgroundColor: Colors.deepPurple.shade100,
    primaryColor: Colors.black87,
    secondaryHeaderColor: Colors.deepPurple.shade200,
    splashColor: Colors.grey.shade400,
      canvasColor:Colors.deepPurple.shade200,
    cardColor: Colors.deepPurple,
      indicatorColor: Colors.black38,
    focusColor: Colors.deepPurple.shade100,
      bottomAppBarTheme:  BottomAppBarTheme(color: Colors.deepPurple.shade200,
          surfaceTintColor: Colors.transparent,)


  );
  static final darkTheme = ThemeData(
    //colorScheme: const ColorScheme.dark(),
    scaffoldBackgroundColor: Colors.black45,
    primaryColor: Colors.white,
      secondaryHeaderColor: Colors.black26,
      splashColor:Colors.black,
    canvasColor:Colors.white10,
      indicatorColor: Colors.white38,
    cardColor: Colors.black45,
      focusColor:Colors.black,
      bottomAppBarTheme: const BottomAppBarTheme(color:Colors.white12 , surfaceTintColor: Colors.black)
  );
}