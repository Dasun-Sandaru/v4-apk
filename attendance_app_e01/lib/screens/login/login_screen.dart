import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:attendance_app_e01/services/config.dart';
import 'package:attendance_app_e01/services/device_info.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get_ip_address/get_ip_address.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:http/http.dart' as http;

import '../../models/login/loginData.dart';
import '../../services/sharedPref.dart';
import '../home/home_screen.dart';

// import 'package:device_info/device_info.dart';



//To Do
// -> 01. get ip
// -> 02. get imei_no
// -> 03. post data

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    // not work
    //initPlatformState();

    // call ckeck internet active
    _streamSubscriptionInternetActiviteInLoginScreen =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final activeInternet = event == InternetConnectionStatus.connected;

      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionInternetActiviteInLoginScreen.cancel();
  }

  SharedPref sharedPref = SharedPref();

  // variables
  late String empNo;
  late String password;
  var imei_no;
  late String ip;
  late String responseMsg;
  bool activeInternet = true;

  String userName = 'Unknown';

  bool isLoading = false;

  String identifier= '';

  // internet avative
  late StreamSubscription _streamSubscriptionInternetActiviteInLoginScreen;

  double deviceHight = 0.0;
  double deviceWidth = 0.0;

  // get ip
  Future<String> getIp() async {
    try {
      /// Initialize Ip Address
      // var ipAddress = IpAddress(type: RequestType.json);
      var ipAddress = IpAddress(type: RequestType.text);

      /// Get the IpAddress based on requestType.
      ip = await ipAddress.getIpAddress();

      print("device ip :" + ip.toString());

      return ip;
    } on IpAddressException catch (e) {
      /// Handle the exception.
      print(e.message);
      return e.toString();
    }
  }

  // form kry
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // text editing controller
  final TextEditingController _registerNumberControler =
      TextEditingController();
  final TextEditingController _passwordControler = TextEditingController();

  //Widgets

  // Logo Img
  Widget _buildLogo() {
    return Container(
      height: 150,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/image/1.jpeg"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sized Box
  Widget _buildSizedBox(double h) {
    return SizedBox(
      height: h,
    );
  }

  // Employee Number
  Widget _buildEmployeeNoField() {
    return Container(
      child: TextFormField(
        controller: _registerNumberControler,
        decoration: const InputDecoration(
          hintText: "Employee Number",
          border: InputBorder.none,
          fillColor: Color(0xfff3f3f4),
          filled: true,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
        validator: (text) {
          // validate
          if (text!.isEmpty) {
            return "Employee Number Required !";
          }
          return null;
        },
        onSaved: (value) {
          empNo = value!;
        },
      ),
    );
  }

  // Password Field
  Widget _buildPasswordField() {
    return Container(
      child: TextFormField(
        obscureText: true,
        controller: _passwordControler,
        decoration: const InputDecoration(
          hintText: "Password",
          border: InputBorder.none,
          fillColor: Color(0xfff3f3f4),
          filled: true,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
        ),
        validator: (text) {
          // validate
          if (text!.isEmpty) {
            return "Password Required !";
          }
          return null;
        },
        onSaved: (value) {
          password = value!;
        },
      ),
    );
  }

  // Text
  Widget _buildText(String txt) {
    return Text(
      txt,
      textAlign: TextAlign.left,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
    );
  }

  // Login Btn
  Widget _buildLoginBtn() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () async {
          // print
          print('clicked login btn');

          // get ip addresss
          String pp = await getIp();
          print(pp);

          // get imeiNo
          DeviceInfo deviceInfo = DeviceInfo();
          imei_no = await deviceInfo.getDeviceInfo();
          print('imei_no ---> $imei_no');

          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            print("Emp Name -: ${empNo}");
            print("Password -: ${password}");

            setState(() {
              isLoading = true;
            });

            // login example
            login(empNo, password, ip);
          } else {}
        },
        color: const Color(0xff043776),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        // child: const Text(
        //   'Login',
        //   style: TextStyle(
        //     color: Colors.white,
        //   ),
        // ),

        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                'Login',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    print(deviceHight);
    print(deviceWidth);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff043776),
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 10),
                  Container(
                    width: deviceWidth,
                    height: deviceWidth / 3,
                    child: const Image(
                      image: AssetImage('assets/image/Login Screen banner.png'),
                      // width: double.infinity,
                      // height: 200,
                    ),
                  ),

                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.transparent,
                    ),
                    child: Form(
                      //state
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildText('Employee Number'),
                          _buildSizedBox(15),
                          _buildEmployeeNoField(),
                          _buildSizedBox(15),
                          _buildText('Password'),
                          _buildSizedBox(10),
                          _buildPasswordField(),
                        ],
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.only(top: 44.0),
                  ),

                  // login btn widget
                  _buildLoginBtn(),

                  _buildSizedBox(10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // login method
  Future<void> login(String empNo, String password, String ip) async {
    // chack internet available
    if (activeInternet) {
      // when internet available
      try {
        LoginData logindata = LoginData(
          badgenumber: empNo,
          password: password,
          ip: ip, // '127.0.0.1',
          imei_no: '000999888',
        );

        print('IP is --->   $ip');

        final response = await http.post(
          Uri.parse("${Config.BACKEND_URL}login"),
          body: logindata.toJson(),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          // print('account created successfully');

          var data = jsonDecode(response.body);

          LoginResponse loginResponse = LoginResponse.fromJson(data);

          if (loginResponse.success) {
            print(loginResponse.message);
            responseMsg = loginResponse.message;
            userName = loginResponse.userName;

            // save emp Id & emp Name in local DB
            sharedPref.saveEmpIdName(empNo, userName);
            // save token in local DB
            sharedPref.saveToken(loginResponse.token);

            setState(() {
              isLoading = false;
            });

            // show toast
            Fluttertoast.showToast(
              msg: responseMsg,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );

            //navigate to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(userName: userName),
              ),
            );
          } else {
            setState(() {
              isLoading = false;
            });

            responseMsg = loginResponse.message;
            // show toast
            Fluttertoast.showToast(
              msg: responseMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          // ------------------------------------------------------------------------------------------------------------------------------------------
          if (response.statusCode == 401) {
            setState(() {
              isLoading = false;
            });
            // show toast
            Fluttertoast.showToast(
              msg: 'Invalid credentials.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          } else {
            setState(() {
              isLoading = false;
            });
            print(
                'Request failed with status: ${response.statusCode}'); // -------------------------------------------------------------------------- need to show server error msg

            Fluttertoast.showToast(
              msg: 'Request failed with status: ${response.statusCode}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          }
          // ------------------------------------------------------------------------------------------------------------------------------------------

        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.toString());
        Fluttertoast.showToast(
          msg: 'failed : ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      // when internet not available
      setState(() {
        isLoading = false;
      });
      print('you are offline');
      Fluttertoast.showToast(
        msg: 'You are Offline',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }


}
