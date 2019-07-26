import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mychat1/modules/auth.dart';

class Notification extends Object {

  static final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  static void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance.collection('users').document(Auth.currentUser.uid).updateData({'pushToken': token});
    }).catchError((err) {
      print(err.toString());
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  static void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('chat1');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.company.mychat1': 'com.company.mychat1',
      'MyChat1',
      'MyChat1',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
    new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }


}