import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_firebase_push_notification/new_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? mtoken = '';
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    requestPermission();
    // getToken();
    initInfo();
  }

  initInfo() {
    var androidInitilize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitilize = const IOSInitializationSettings();
    var initilizationsSettings =
        InitializationSettings(android: androidInitilize, iOS: iosInitilize);
    flutterLocalNotificationsPlugin.initialize(initilizationsSettings,
        onSelectNotification: (String? payload) async {
      try {
        if (payload != null && payload.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return NewScreen(info: payload.toString());
            },
          ));
        } else {}
      } catch (e) {}
      return;
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("......onMessage........");
      print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}");

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidPaltformChannelSpecitics =
          AndroidNotificationDetails(
        "dbfood",
        "dbfood",
        importance: Importance.high,
        styleInformation: bigTextStyleInformation,
        priority: Priority.high,
        playSound: true,
        // sound: RowResoucreAndroidNotificationSound('notification'),
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPaltformChannelSpecitics,
          iOS: const IOSNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
          message.notification?.body, platformChannelSpecifics,
          payload: message.data['body']);
    });
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print(" My token is $mtoken ");
      });
      saveToken(token!);
    }).catchError((error) {
      print(error);
    });
  }

  void saveToken(String token) async {
    String name = username.text.trim();
    await FirebaseFirestore.instance.collection("UserTokens").doc(name).set({
      'token': token,
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print(' User granted permission ');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print(' User granted provisional permission ');
    } else {
      print(' User declined or has not accepted permission ');
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAv3HOrQg:APA91bFDqU282AI-Q9n-ySkhMjVv4CkTg1m55yNJwLLsMfu_AehTjSLEklIk99_1AZBJFsBt2pMjTqoHqOj9secnvu9qG4x3DVyQ4JgzqsYIB9LRKcwIarxzcsEPvlKLOkQXVJc96Pk5',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': ' FLUTTER_NOTIFICATION_CLICK ',
              'status': 'done',
              'body': body,
              'title': title,
            },
            "notification": <String, dynamic>{
              "title": title,
              "body": body,
              "android_channel_id": "dbfood"
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: username,
              ),
              TextFormField(
                controller: title,
              ),
              TextFormField(
                controller: body,
              ),
              GestureDetector(
                onTap: () async {
                  String name = username.text.trim();
                  String titleText = title.text;
                  String bodyText = body.text;
                  // throw Exception();
                  if (name != "") {
                    getToken();

                    DocumentSnapshot snap = await FirebaseFirestore.instance
                        .collection("UserTokens")
                        .doc(name)
                        .get();
                    String token = snap['token'];
                    print(token);
                    //throw Exception();
                    sendPushMessage(token, bodyText, titleText);
                    //FirebaseCrashlytics.instance.crash();
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text("Button"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
