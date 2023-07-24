import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_task_app/resources/notification_services.dart';
import 'package:flutter_task_app/provider/userProvider.dart';
import 'package:flutter_task_app/router.dart';
import 'package:flutter_task_app/screens/auth/auth_screen.dart';
import 'package:flutter_task_app/screens/chat/user_list_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> initializeAppAndGetFCMToken() async {
  // Get the FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();

  // Check if the user is logged in
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null && fcmToken != null) {
    // Update FCM token in user profile data
    String uid = user.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': fcmToken,
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeAppAndGetFCMToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationServices _notificationServices = NotificationServices();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Cloud Messaging
    _notificationServices.requestNotificationPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        // Handle navigation here when the user clicks on the notification
        // For example, if the notification contains a 'chatId' data field:
        String? chatId = message.data['chatId'];
        if (chatId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserListScreen(),
            ),
          );
        }
      }
    });

    _initLocalNotifications();
    initializeAppAndGetFCMToken();
  }

  void showNotification() {
    flutterLocalNotificationsPlugin.show(
      0,
      "Testing",
      "How you doin ?",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> initializeAppAndGetFCMToken() async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && fcmToken != null) {
      String uid = user.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': fcmToken,
      });
    }
  }

  void _initLocalNotifications() {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(useMaterial3: true, primaryColor: Colors.deepPurple),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            // User is logged in, navigate to ChatScreen
            return UserListScreen();
          } else {
            // User not logged in, navigate to AuthScreen
            return AuthenticationScreen();
          }
        },
      ),
    );
  }
}
