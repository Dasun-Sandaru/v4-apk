import 'dart:async';
import 'dart:convert';
import 'package:attendance_app_e01/helper/sqldb.dart';
import 'package:attendance_app_e01/screens/instruction/instruction_webpage_screen.dart';
import 'package:attendance_app_e01/screens/login/login_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import '../../models/drop down/drowdowntypes.dart';
import '../../services/config.dart';
import '../../services/sharedPref.dart';
import '../attendance/attendance_screen.dart';
import '../instruction/instruction_screen.dart';
import '../leave/leave_screen.dart';
import '../market execution/market_execution.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  late String userName;
  HomePage({Key? key, required this.userName}) : super(key: key);

  //HomePage(this.userName);

  @override
  State<HomePage> createState() => _HomePageState(userName);
}

class _HomePageState extends State<HomePage> {
  String userName;

  bool activeInternet = true;
  // internet avative
  late StreamSubscription _streamSubscriptionInternetActiviteInHomeScreen;
  bool isOn = false;
  // location on
  late String token;
  List<DropDownTypes> listOfDrofDownValues = [];

  int? rowcount;

  _HomePageState(this.userName);

  Location location = Location();
  SqlDb sqlDbObj = SqlDb();

  // methods
  @override
  void initState() {
    super.initState();

    

    // enable location
    enableLocation();

    // get row count
    getRowCount();

    // // read token
    //getToken();

    SharedPref sharedPref = SharedPref();
    sharedPref.saveDataOnOff(activeInternet);

    //check user online
    // call ckeck internet active
    _streamSubscriptionInternetActiviteInHomeScreen =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final activeInternet = event == InternetConnectionStatus.connected;

      SharedPref sharedPref = SharedPref();
      sharedPref.saveDataOnOff(activeInternet);

      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });
  }

  @override
  void dispose() {
    _streamSubscriptionInternetActiviteInHomeScreen.cancel();
    super.dispose();
  }

  getRowCount() async {
    try {
      // checking local db row count
      rowcount = await sqlDbObj.getRowCountOFExecutionTypesTbl();
      print('row count ===> $rowcount');
      await getToken();
    } catch (e) {
      print(e.toString());
    }
  }

  // get token
  getToken() async {
    SharedPref sharedPref = SharedPref();
    token = (await sharedPref.readToken())!;

    print('row counting $rowcount');

    if (rowcount == null || rowcount == 0) {
      getDropDownValuesToLocalDb(token);
    } else if (rowcount! >= 1) {
      // by pass
      print('by passing');
    }
  }

  // get execurion drop types to shared pref
  // get drop down values
  void getDropDownValuesToLocalDb(String token) async {
    try {
      final responseType = await http.get(
          Uri.parse("${Config.BACKEND_URL}market-execution/types"),
          headers: {
            'Authorization': 'Bearer $token',
          });

      if (responseType.statusCode == 200) {
        var decodedMap = jsonDecode(responseType.body);

        List<dynamic> responseListPart = decodedMap['data'];

        print("----------------------- in home page >$responseListPart");

        if (responseListPart.isNotEmpty) {
          final localdata = {};
          localdata['data'] = responseListPart;

          final String dataAsJson = json.encode(localdata);

          await sqlDbObj.insertExecutionTypes(dataAsJson);
          print('market execution types add to local db');
        } else {
          // drow down values has
          Fluttertoast.showToast(
            msg: 'Sorry ! Execution Types currnently not available',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        print('Request failed with status: ${responseType.statusCode}');

        Fluttertoast.showToast(
          msg: 'Request failed with status: ${responseType.statusCode}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // enable location
  enableLocation() async {
    try {
      isOn = await location.serviceEnabled();

      if (!isOn) {
        //if defvice is off
        bool isturnedon = await location.requestService();

        if (isturnedon) {
          print("GPS device is turned ON");
        } else {
          print("GPS Device is still OFF");
          //isOn = false;
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // logout
  void logout() {
    SharedPref sharedPref = SharedPref();
    sharedPref.removeToken();

    // show toast
    Fluttertoast.showToast(
      msg: 'You have logged out successfully',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    //navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

// read data
  readData() async {
    try {
      //String sql = 'SELECT * FROM ExecutionTypes WHERE id = 2';
      String sql = 'SELECT * FROM ExecutionTypes';
      List<Map> response = await sqlDbObj.readData(sql);
      print(response[0]['types']);
      print('$response');
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     // read executions types fropm loacal db
      //     String sql = 'SELECT * FROM ExecutionTypes';
      //     List<dynamic> AA = await sqlDbObj.readData(sql);
      //     print(AA);

      //     // delete db rows
      //     // for (var i = 3; i < 6; i++) {
      //       // String sql = 'DELETE FROM ExecutionTypes WHERE id = 74';
      //       // var res = await sqlDbObj.deleteData(sql);
      //       // print(res);
      //     // }

      //     // String sql1 = 'SELECT * FROM ExecutionTypes';
      //     // var res1 = await sqlDbObj.readData(sql1);
      //     // print(res1);

      //   },
      // ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          // color: Colors.blue,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff043776), Color(0xff174378)],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              child: Column(
                children: <Widget>[
                  _buildwelcomeText(),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/fingerprint.png",
                              item: "Attendance",
                              nav: "attendance",
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/leave.png",
                              item: "Leave",
                              nav: "leave",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/market.png",
                              item: "Market Execution",
                              nav: "market",
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/manual.png",
                              item: "Instructions",
                              nav: "instructions",
                            ),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      padding: const EdgeInsets.all(5),
                      //color: Color(0xff043776),
                      // color: Colors.amberAccent,
                      color: const Color(0xFFee3a43),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () {
                        // logout
                        logout();
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widgets

  // internet alert dialog
  Future buildCustomDialog() {
    return showDialog(
        context: context,
        builder: (newNotification) {
          return AlertDialog(
            title: const Text('Network Alert'),
            content: const Text(
                'Your are currently offline.\nPlease check your internet connection'),
            actions: [
              TextButton(
                  onPressed: () {
                    //
                    if (activeInternet) {
                      Navigator.of(newNotification).pop();
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Check Connection'))
            ],
          );
        });
  }

  // welcome Part
  Widget _buildwelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 50,
        ),
        Text(
          'Hi,$userName',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const Text(
          "Attendance & Leave Management App",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  // custom card
  Widget _buildCustomCard({String? imageUrl, String? item, String? nav}) {
    return GestureDetector(
      onTap: () async {
        if (nav == "leave") {
          // if (activeInternet) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaveScreen()),
          );
          // } else {
          //   print(activeInternet);
          //   buildCustomDialog();
          // }
        } else if (nav == "attendance") {
          if (isOn) {
            print(activeInternet);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceScreen(),
              ),
            );
          } else {
            print(activeInternet);
            // buildCustomDialog();
            enableLocation();
          }
        } else if (nav == "instructions") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstructionWebPage(),
            ),
          );
        } else if (nav == "market") {
          if (isOn) {
            print(activeInternet);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketExecution(),
              ),
            );
          } else {
            print(activeInternet);
            // buildCustomDialog();
            enableLocation();
          }
        }
      },
      child: Container(
        height: 200,
        width: 250, // 150
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(imageUrl!),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      // FlatButton(
                      //   onPressed: () {},
                      //   child: Text(
                      //     item!,
                      //     textAlign: TextAlign.center,
                      //     style: const TextStyle(
                      //         fontSize: 17,
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.black),
                      //   ),
                      // ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // logout button
  Widget _buildLogoutBtn() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              padding: const EdgeInsets.all(5),
              //color: Color(0xff043776),
              // color: Colors.amberAccent,
              color: const Color(0xFFee3a43),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {
                // logout
                logout();
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
