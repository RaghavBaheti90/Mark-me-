import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendence_app/pages/ClassAttendanceSummaryPage.dart';
import 'package:qr_attendence_app/pages/GenerateQRScreen.dart';
import 'package:qr_attendence_app/pages/ProfilePage.dart';
import 'package:qr_attendence_app/pages/addclass_page.dart';
import 'package:qr_attendence_app/pages/home.dart';
import 'package:qr_attendence_app/pages/login_page.dart';
import 'package:qr_attendence_app/pages/qr_scanner_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qr_attendence_app/pages/signup_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? QRHomePage()
          : LoginPage(),
      routes: {
        '/home': (context) => QRHomePage(),
        '/generate': (context) => GenerateQRScreen(),
        '/scan': (context) => QRScannerPage(),
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignupPage(),
        '/newclass': (_) => CreateClassPage(),
        '/attan': (_) => AttendanceSessionsPage(),
        '/profile': (_) => ProfilePage(),
        // Add '/scan' later for scanning
      },
    );
  }
}
