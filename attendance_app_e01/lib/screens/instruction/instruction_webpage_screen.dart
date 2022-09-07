import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../services/config.dart';

class InstructionWebPage extends StatefulWidget {
  const InstructionWebPage({Key? key}) : super(key: key);

  @override
  State<InstructionWebPage> createState() => _InstructionWebPageState();
}

class _InstructionWebPageState extends State<InstructionWebPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff043776),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: const Text("Instructions"),
      ),
      body: const WebView(
        initialUrl: Config.InstructionWebPage,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
