import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartassistant/firebase_options.dart';
import 'package:smartassistant/login.dart';
// import 'package:smartassistant/homepage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inisialisasi Firebase
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Assistant',
      theme: ThemeData(
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromRGBO(239, 175, 12, 100))),
      home: LoginPage(),
      // kDebugMode ? HomePage() :
      debugShowCheckedModeBanner: false,
    );
  }
}
