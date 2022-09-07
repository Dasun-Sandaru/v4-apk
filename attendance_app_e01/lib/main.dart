import 'package:attendance_app_e01/screens/attendance/attendance_screen.dart';
import 'package:attendance_app_e01/screens/leave/leave_screen.dart';
import 'package:attendance_app_e01/screens/splash/splash_screen.dart';
import '/screens/home/home_screen.dart';
import '/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'screens/instruction/instruction_screen.dart';
import 'screens/market execution/market_execution.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:SplashScreen(),
    );
  }
}