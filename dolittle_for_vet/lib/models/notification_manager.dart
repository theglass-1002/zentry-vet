import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dolittle_for_vet/utility_function.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dolittle_for_vet/api/api.dart';
import 'package:dolittle_for_vet/models/models.dart';
import 'package:dolittle_for_vet/components/components.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class NotificationManager extends ChangeNotifier {
  final bool isAndroid = Platform.isAndroid;
  late AndroidNotificationChannel channel;
  FirebaseMessaging messaging = FirebaseMessaging.instance ;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings initialzationSettingsAndroid =
  const AndroidInitializationSettings('@mipmap/ic_launcher');
  BuildContext? context;
  MonitoringRoomManager monitoringRoomManager = MonitoringRoomManager();
  MonitoringDataManager monitoringDataManager = MonitoringDataManager();
  late AppCache? _appCache= AppCache();
  int _count = 0;
  int get count => _count;


  NotificationManager(
      // this.channel,
      // this.messaging,
      // this.flutterLocalNotificationsPlugin,
      // this.initialzationSettingsAndroid,
      // this.context
      );




  Future<void> initializeApp() async {
    //iOS, macOS 및 웹에서 기기에서 FCM 페이로드를 수신하려면 먼저 사용자의 허가를 받아야 합니다. Android 애플리케이션은 권한을 요청할 필요가 없습니다.
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      print("유저 알림허용");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    };

    //iOS 구성
    var initialzationSettingsIOS = const DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await getFcmToken();

  }

  Future<void> getFcmToken() async {
    final String? token = await messaging.getToken();
    if (token != null) {
      await _appCache!.setFcmToken(token);
    }
    messaging.onTokenRefresh.listen((fcmToken) async {
      await _appCache!.setFcmToken(fcmToken);
    });

  }




  void notificationMsg(BuildContext buildContext){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if(notification?.titleLocKey.toString()=="MULTI_MONITORING_ALARM"){
        UtilityFunction.log.e('멀티알람울림');
        return;
      }else{
        if(isAndroid){
          flutterLocalNotificationsPlugin.show(
              message.hashCode,
              'DolittleVet',
              UtilityFunction.notifiBodyMsg(notification!),
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  importance: Importance.high,
                  priority: Priority.high,
                  channelDescription: channel.description,
                  icon: android?.smallIcon,
                  // other properties...
                ),
              ));

        }else{
          UtilityFunction.log.e('ios 알람 울림');
        }
      }
      try {
        UtilityFunction.log.e('fcm 알람 울림');
        UtilityFunction.pushReplacementNamed(buildContext, '/');
      } catch (e) {
        UtilityFunction.log.e(e);
      }

    });
  }
}
