import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding JSON payloads

class FCMService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize(String id, String authToken) async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.notification?.title}');
      _showNotification(message);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      _handleNotificationTapFromBackground(message);
    });

    String? token = await messaging.getToken();
    print("FCM Token: $token");
    await sendFCMTokenToBackend(token, id, authToken);
  }

  Future<void> sendFCMTokenToBackend(
      String? token, String id, String? authToken) async {
    if (token != null) {
      final response = await http.post(
        Uri.parse(
            'https://logicgate99.pythonanywhere.com/api/driver/set-fcm-token/'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
        body: {
          'driver_id': id.toString(),
          'fcm_token': token,
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("FCM Token sent successfully");
      } else {
        print("Failed to send FCM Token");
      }
    }
  }

  void _showNotification(RemoteMessage message) async {
    var androidDetails = const AndroidNotificationDetails(
      'my_channel_id',
      'My Channel',
      channelDescription: 'This channel handles important notifications',
      priority: Priority.high,
      importance: Importance.high,
    );

    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final Map<String, dynamic> data = jsonDecode(payload);
      print('Notification tapped with data: $data');
      if (data['screen'] == 'home') {
        navigatorKey.currentState?.pushNamed(
          '/home',
        );
      }
    }
  }

  void _handleNotificationTapFromBackground(RemoteMessage message) {
    print('Notification tapped (background): ${message.data}');
    final data = message.data;
    if (data['screen'] == 'home') {
      navigatorKey.currentState?.pushNamed(
        '/home',
      );
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.notification?.title}');
}
