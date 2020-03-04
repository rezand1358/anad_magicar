
import 'dart:async';
import 'package:anad_magicar/Routes.dart';
import 'package:anad_magicar/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


abstract class FireBaseMessageHandler<T> {

  showMessage(Map<String, dynamic> message);
  onLaunch(Map<String, dynamic> message);
  onResume (Map<String, dynamic> message);
  hasToken(bool hasToken, String token);

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;



  Future _showNotificationWithDefaultSound(String title, String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'anad_60', 'anad_channel', 'channel_description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '$title',
      '$message',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future<String> getClientToken() async {
    String fcmToken = await _fcm.getToken();
    hasToken((fcmToken!=null && fcmToken.isNotEmpty), fcmToken);
    return fcmToken;
  }

  void initMessageHandler() {
    getClientToken();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }


    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        showMessage(message);
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
       onLaunch(message);


      },
      onResume: (Map<String, dynamic> message) async {
        onResume(message);

      },
    );
  }
}
