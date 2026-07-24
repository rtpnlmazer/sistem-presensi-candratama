import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String _baseUrl = ApiConfig.apiUrl;

  Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging
        .requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Izin notifikasi diberikan oleh pengguna!');

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notifikasi Penting',
        description: 'Channel ini digunakan untuk notifikasi penting aplikasi.',
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'ic_notification',
                color: const Color(0xFFDA2128),
                styleInformation: BigTextStyleInformation(
                  notification.body ?? '',
                  contentTitle: notification.title,
                ),
              ),
            ),
          );
        }
      });

      try {
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          print('Token FCM Perangkat: $fcmToken');

          await sendTokenToServer(fcmToken);
        }

        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          sendTokenToServer(newToken);
        });
      } catch (e) {
        print('Gagal mengambil token FCM: $e');
      }
    }
  }

  Future<void> sendTokenToServer(String fcmToken) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authToken = prefs.getString('token') ?? '';

      final response = await http.post(
        Uri.parse('$_baseUrl/save-fcm-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Sukses: Token FCM berhasil ditanam di database Laravel!');
      } else {
        print('Gagal menanam token: ${response.body}');
      }
    } catch (e) {
      print('Error jaringan saat kirim token: $e');
    }
  }
}
