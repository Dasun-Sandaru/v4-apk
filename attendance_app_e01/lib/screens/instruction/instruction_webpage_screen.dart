import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/config.dart';
import '../../services/sharedPref.dart';
import 'package:http/http.dart' as http;

class InstructionWebPage extends StatefulWidget {
  const InstructionWebPage({Key? key}) : super(key: key);

  @override
  State<InstructionWebPage> createState() => _InstructionWebPageState();
}

class _InstructionWebPageState extends State<InstructionWebPage> {
  
  String web = '';
  String token = '';
  bool isOk = true;

  @override
  void initState() {
    super.initState();
    // get token
    getToken();
  }

  // methods
  // get token
  getToken() async {
    SharedPref sharedPref = SharedPref();
    token = (await sharedPref.readToken())!;
    print('in web --> $token');

    // get InstructionWebPage link
    getInstructionWebPageLink(token);
  }

  void getInstructionWebPageLink(String token) async {
    print("token   --------------------------- $token");
    final response = await http
        .get(Uri.parse("${Config.BACKEND_URL}instruction-url"), headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    try {
      if (response.statusCode == 200) {
        Map decodedMap = jsonDecode(response.body);
        web = decodedMap['url'];

        print(web);

        print('Request failed with status: ${response.statusCode}');
        print(response.body);

        setState(() {
          isOk = false;
        });
      } else {
        print('In else - Request failed with status: ${response.statusCode}');
        print(response.body);
        Fluttertoast.showToast(
          msg: 'Request failed with status: ${response.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(" web in build  $web");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff043776),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text("Instructions"),
      ),
      body: isOk ?
      const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
      :
      WebView(
        initialUrl: web, // "https://cyberconceptslk.com"
        javascriptMode: JavascriptMode.unrestricted,
      )
    );
  }

}
