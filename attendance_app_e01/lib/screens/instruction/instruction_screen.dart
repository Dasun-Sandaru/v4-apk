import 'dart:io';
import 'package:attendance_app_e01/services/sharedPref.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({Key? key}) : super(key: key);

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {

  String? userName;

  SharedPref sharedPref = SharedPref();

  @override
  void initState() {

    // get user name
    getUserName();

    super.initState();
  }

  // get user name
  Future<void> getUserName() async {
    userName = await sharedPref.readEmpName();
  }

  int slideIndex = 0;
  // late PageController controller;
  PageController? controller = PageController();

  // widget

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xff3C8CE7), Color(0xff00EAFF)]),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff043776),
        body: Container(
          height: MediaQuery.of(context).size.height - 100,
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                slideIndex = index;
              });
            },
            children: <Widget>[
              SlideTile01(),
              SlideTile02(),
              SlideTile03(),
            ],
          ),
        ),
        bottomSheet: slideIndex != 2
            ? Container(
                height: Platform.isIOS ? 70 : 60, // ---------------------------------------------------------------------------
                //height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        controller!.animateToPage(2,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.linear);
                      },
                      splashColor: Colors.white70,
                      child: const Text(
                        'SKIP',
                        style: TextStyle(
                            color: Color(0xff043776),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            i == slideIndex
                                ? _buildPageIndicator(true)
                                : _buildPageIndicator(false),
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        print("this is slideIndex: $slideIndex");
                        controller!.animateToPage(slideIndex + 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear);
                      },
                      splashColor: Colors.white70,
                      child: const Text(
                        "NEXT",
                        style: TextStyle(
                            color: Color(0xff043776),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                onTap: (() {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => HomePage(
                                userName: userName!, // ---------------------------------------------------------------------------
                              )),
                      (route) => false);
                }),
                child: Container(
                  height: Platform.isIOS ? 70 : 60, // ---------------------------------------------------------------------------
                  //height: 70,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Text(
                    "GET STARTED NOW",
                    style: TextStyle(
                        color: Color(0xff043776),
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
                  ),
                ),
              ),
      ),
    );
  }
}

// 1st
class SlideTile01 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Image.asset("assets/image/selfiescreen.png",
              height: 320, fit: BoxFit.fill),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Selfie Punch\n",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Visiting to a Outlet",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Photo 1 : Selfie \nPhoto 2 : Front view of the outlet *\nPhoto 3 : Inside of the Outlet * \nPhoto 4 : Cooler * \nPhoto 5 : Competitor/Promotions/Marketing \nRemarks : Outlet Name *\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Gate Meeting",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Photo 1 : Selfie*\nRemarks : DB/DO Area Name*\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Distributor Opening",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Photo 1 : Selfie*\nRemarks : DB/DO Area Name*\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Special Event",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Photo 1 : Selfie\nPhoto 5 : Competitor/Promotions/Marketing* \nRemarks : Area – Name/Nature of the Event\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}

// 2nd
class SlideTile02 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Image.asset("assets/image/leavescreen.png",
              height: 330, fit: BoxFit.fill),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Leave Form\n",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Full Day",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Date From + 00:00 To Date To + 23:59\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Half Day",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "First Half        : DateFrom + 00:00 To DateTo + 12:30\nSecond Half   : DateFrom + 12:30 To DateTo + 23:59\n",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}

// 3rd
class SlideTile03 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          Image.asset("assets/image/lastscreen.png", fit: BoxFit.fill),
          const SizedBox(
            height: 30,
          ),
          const Text(
            "Let's GO\n",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 34, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
