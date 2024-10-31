import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';


class ConnectivityController {

  final connectivity = Connectivity();

  final fireStore = FirebaseFirestore.instance;

  final firebaseAuth = FirebaseAuth.instance;

  late StreamSubscription connSub;

  void hasInternetConn (
      {void Function()? connectedFunction, void Function()? disconnectedFunction}){
    connSub= Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      print('it is $connectivityResult');
      if (connectivityResult.contains(ConnectivityResult.mobile)||connectivityResult.contains(ConnectivityResult.wifi)){
        final isDeviceConnected =await  InternetConnectionCheckerPlus().connectionStatus;
        if( isDeviceConnected==InternetConnectionStatus.connected){
          connectedFunction;
        }else{
          disconnectedFunction;
        }
      }else{
        disconnectedFunction;
      }
    });
  }

  void  checkConnectivity(BuildContext context,void Function()? connectedFunction, void Function()? disconnectedFunction) {
    final network =  connectivity.checkConnectivity();
    print(network.toString());
    connSub=Connectivity().onConnectivityChanged.listen((connectivityResult) async {
      if (connectivityResult.contains(ConnectivityResult.mobile)||connectivityResult.contains(ConnectivityResult.wifi)){
        final isDeviceConnected =await  InternetConnectionCheckerPlus().connectionStatus;
        if( isDeviceConnected==InternetConnectionStatus.connected){updateOnlineStatus(true);
          print(isDeviceConnected);
        print('connected');
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        connectedFunction;
        }else{ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('No internet Access!'),
          duration: Duration(seconds: 12),showCloseIcon: true,),);
        disconnectedFunction;}

      }else{ print('none');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('No Wifi / Mobile data connectivity'),
        duration: Duration(seconds: 12),showCloseIcon: true,),);
      updateOnlineStatus(false);
      disconnectedFunction;}
    },);
  }




  void updateOnlineStatus (bool bool)async{
    await fireStore.collection('users').doc(firebaseAuth.currentUser!.email).update({
      'isOnline':bool
    }
    );
  }

  Widget convertLastActiveTime(Timestamp dateTime, bool isOnline){
    final lastActive = dateTime.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    if (difference.inMinutes < 3 && isOnline == true){
      return const Text('online',style: TextStyle(color: Colors.blue),);
    }else if (difference.inMinutes >3 || isOnline == false){return
      Row(children: [
        Expanded(child: Text("last Active: ${DateFormat().add_jm().format(lastActive)},",style:  TextStyle(color: Colors.white, fontSize: 12.sp), )),
        SizedBox(width: 70,
          child: Text(timeConverter(lastActive),
            textAlign: TextAlign.left,
            style:  TextStyle(fontSize: 12.sp, color: Colors.white),
            overflow:TextOverflow.ellipsis ,
          maxLines: 1,),
        ),
      ],
    );}else {return const Text('');}
  }

 String timeConverter (DateTime date){
    final currentDate = DateTime.now();
    if (DateFormat('dd/MM/yyyy').format(currentDate)==DateFormat('dd/MM/yyyy').format(date)){
      return 'Today';
    }else if(DateFormat('dd').format(currentDate)==DateFormat('dd').format(date.add(const Duration(days: 1)))){
      return 'Yesterday';
    }else {
      return ' ${DateFormat('EEE,dd/M').format(date)}';
    }
}
}
