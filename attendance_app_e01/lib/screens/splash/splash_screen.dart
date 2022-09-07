import 'package:attendance_app_e01/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sharedPref.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPref sharedPref = SharedPref();

  //
  @override
  void initState() {
    super.initState();
    //checkLoginStatus();
    checkIn();
  }

  String? token;
  String? userName;

  // widget
  Widget _buildLogo() {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            child: const Image(
              image: AssetImage('assets/image/logo_bgremove.png'),
              width: 200.0,
              height: 160.0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.center,
                    image: AssetImage('assets/image/white.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            _buildLogo(),
          ],
        ),
      ),
    );
  }

  // methods 1at clz
  void checkLoginStatus() async {
    sharedPref.readToken();
    token = (await sharedPref.readToken())!;

    if (token == 'logout') {
      print('navigate to login');

      Future.delayed(Duration(seconds: 3), (() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }));
    } else {
      print('navigate to home');

      Future.delayed(Duration(seconds: 3), (() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              userName: 'uuu',
            ),
          ),
        );
      }));
    }
  }

  Future<void> checkIn() async {
    sharedPref.readTokenForLoginStatus();
    token = (await sharedPref.readToken());

    if (token == null) {
      print('login');

      Future.delayed(
        Duration(seconds: 5),
        (() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }),
      );
    } else {
      print('home');
      //get user name
      userName = await sharedPref.readEmpName();

      Future.delayed(
        const Duration(seconds: 5),
        (() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(
                userName: userName!,
              ),
            ),
          );
        }),
      );
    }
  }
}

