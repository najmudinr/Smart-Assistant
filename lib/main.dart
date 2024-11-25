import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smartassistant/firebase_options.dart';
import 'package:smartassistant/home.dart';
import 'package:smartassistant/login.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point') // Diperlukan untuk memastikan handler dapat diakses oleh VM
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notifikasi diterima di background: ${notificationResponse.payload}');
  // Tambahkan logika tambahan jika diperlukan
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Notifikasi Lokal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print("Notifikasi diterima di foreground: ${response.payload}");
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Mengecek status login
  final user = FirebaseAuth.instance.currentUser;
  final isLoggedIn = user != null;

  await FirebaseAuth.instance.signOut();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Assistant',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(239, 175, 12, 100),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Jika pengguna sudah login, arahkan ke HomePage, jika tidak, ke LoginPage
      home: isLoggedIn ? HomePage() : LoginPage(),
    );
  }
}