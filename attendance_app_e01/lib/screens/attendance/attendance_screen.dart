import 'dart:async';
import 'dart:convert';

import 'package:attendance_app_e01/models/attendance/attendancedata.dart';
import 'package:attendance_app_e01/services/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../helper/convertAddress.dart';
import '../../models/drop down/drowdowntypes.dart';
import '../../services/sharedPref.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // txt field controller
  TextEditingController remarkController = TextEditingController();

  SharedPref sharedPref = SharedPref();
  List<DropDownTypes> listOfDrofDownValues = [];

  String? empNo;
  String? empName;

  bool activeInternet = true;
  // internet avative
  late StreamSubscription _streamSubscriptionInternetActiviteInAttendanceScreen;

  late String remarks;
  late String responseMsg;

  var _latitude = 'current location';
  var _longittude = 'current location';
  var _altitude = 'current location';
  var _address = 'current location';

  late String token;

  // Initial Selected Value
  //String dropdownvalue = 'Select Punch Status';
  var dropdownvalue;
  late String IdOfSelectedDropDownItem;
  String? IndexOfSelectedDropDownItem;

  bool isLoading = false;

  @override
  initState() {
    super.initState();
    // get empNo
    getEmpNo();

    // // read token
    getToken();

    // call ckeck internet active
    _streamSubscriptionInternetActiviteInAttendanceScreen =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final activeInternet = event == InternetConnectionStatus.connected;
      print('event1 ---------------- $activeInternet');
      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });

    getCurrentPositionCodes();
    getCurrentAddress();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionInternetActiviteInAttendanceScreen.cancel();
  }

  // get emp no
  getEmpNo() async {
    // get emp no & name
    empNo = (await sharedPref.readEmpId())!;
    empName = (await sharedPref.readEmpName())!;

    setState(() {});
  }

  // get token
  getToken() async {
    SharedPref sharedPref = SharedPref();
    token = (await sharedPref.readToken())!;

    getDropDownValues(token);
  }

  // get current position
  Future<Position> getCurrentPositionCodes() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      try {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        // Fluttertoast.showToast(
        //   msg: 'Turn on location',
        //   toastLength: Toast.LENGTH_LONG,
        //   gravity: ToastGravity.BOTTOM,
        // );
        return Future.error('Location services are disabled.');
      } catch (e) {
        print(e.toString());
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      try {
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          Fluttertoast.showToast(
            msg: 'Turn on location',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          return Future.error('Location permissions are denied');
        }
      } catch (e) {
        print(e.toString());
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print(await Geolocator.getCurrentPosition());
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  // get current address
  Future<void> getCurrentAddress() async {
    try {
      Position pos = await getCurrentPositionCodes();
      _latitude = pos.latitude.toString();
      _longittude = pos.longitude.toString();
      _altitude = pos.altitude.toString();
      print(_latitude);
      print(_longittude);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      List<Location> locations =
          await locationFromAddress(placemarks[0].toString());
      //print(placemarks);
      Placemark place = placemarks[0];

      setState(() {
        //_address = '${place.street},${place.subLocality}${place.locality}${place.postalCode},${place.country}';
        _address = '${place.street},${place.subLocality}${place.locality}';
        //_address = '${place.street} ${place.subLocality}';

        print(_address);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  late String value;

  void getDropDownValues(String token) async {
    //List<Types> ddtypes = [];

    try {
      final responseType = await http.get(
          Uri.parse("${Config.BACKEND_URL}attendance/punchstatus"),
          headers: {
            'Authorization': 'Bearer $token',
          });

      if (responseType.statusCode == 200) {
        Map decodedMap = jsonDecode(responseType.body);

        List<dynamic> responseListPart = decodedMap['data'];

        // checking drop down values has
        if (responseListPart.isNotEmpty) {
          for (var element in responseListPart) {
            var val_id = element['val_id'];
            var val_des = element['val_des'];

            DropDownTypes dropDownTypesObj =
                DropDownTypes(val_id: val_id, val_des: val_des);
            listOfDrofDownValues.add(dropDownTypesObj);
            // print(listOfDrofDownValues[0].val_des);
          }
        } else {
          // drow down values has
          Fluttertoast.showToast(
            msg: 'Sorry ! punch status currnently not available',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }

        print(listOfDrofDownValues[0].val_des);

        // // this set State need to refesh drop down
        setState(() {});
      } else {
        print('Request failed with status: ${responseType..statusCode}');

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

  // Widgets

  // entry feild
  Widget _buildEntryField(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 2,
          ),
          TextFormField(
            controller: remarkController,
            //obscureText: isPassword,
            maxLines: 3,
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),

            validator: (text) {
              // validate
              if (text!.isEmpty) {
                return "Confirm Password Required !";
              }

              return null;
            },

            onSaved: (value) {
              remarks = value!.trim();
            },
          ),
        ],
      ),
    );
  }

  // submit button
  Widget _buildSubmitBtn(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        buttonColor: const Color(0xFFee3a43), //  <-- dark color
        textTheme: ButtonTextTheme.primary,
        child: RaisedButton(
          onPressed: () async {
            //getCurrentPosition();

            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              if (IndexOfSelectedDropDownItem == null) {
                // user not selected
                // show toast
                Fluttertoast.showToast(
                  msg: 'Please Select Punch Status',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              } else {
                // enable location
                OnLocation onLocation = OnLocation();
                bool isReturnOn = await onLocation.enableLocation();

                if (isReturnOn) {
                  await getCurrentPositionCodes();
                  //await getCurrentAddress();
                  setState(() {});
                  if (_latitude == 'current location') {
                    Fluttertoast.showToast(
                      msg: 'Please wait',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  } else {
                    // // panch data
                    setState(() {
                      isLoading = true;
                    });
                    panch();
                  }
                }
              }
            } else {
              print("Error in validation state");
            }
          },
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  'Submit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  // grid view
  Widget _buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: [],
    );
  }

  // Sized Box
  Widget _buildSizedBox(double h) {
    return SizedBox(
      height: h,
    );
  }

  // drop down punch status
  Widget _buildDropDownPunchStatusType(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    hint: const Text(
                      'Select Punch Status',
                      style: TextStyle(fontSize: 20.0, color: Colors.grey),
                    ),

                    // Initial Value
                    value: dropdownvalue,
                    isExpanded: true,

                    // Down Arrow Icon
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,

                    // Array list of items
                    items: listOfDrofDownValues.map(
                      (DropDownModelClzObj) {
                        return DropdownMenuItem<DropDownTypes>(
                          value: DropDownModelClzObj,
                          child: Text(
                            DropDownModelClzObj.val_des,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ).toList(),

                    // After selecting the desired option,it will
                    // change button value to selected value

                    onChanged: (val) {
                      setState(
                        () {
                          dropdownvalue = val;

                          //remarkController.text = listOfDrofDownValues.indexOf(dropdownvalue).toString();

                          int indexOfSelectedItem =
                              listOfDrofDownValues.indexOf(dropdownvalue);
                          //print(ddtypes[l].val_id);
                          IdOfSelectedDropDownItem =
                              listOfDrofDownValues[indexOfSelectedItem].val_id;
                          IndexOfSelectedDropDownItem =
                              indexOfSelectedItem.toString();

                          print(
                              'Id of selected item --> $IdOfSelectedDropDownItem');
                          print(
                              'Index of selected item --> $IndexOfSelectedDropDownItem');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xff043776),
        appBar: AppBar(
          backgroundColor: const Color(0xff043776),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: const Text("Field Attendance"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildSizedBox(20),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 15.0),
                    child: Text(
                      "Emp No : " " $empNo,$empName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              _buildSizedBox(5),
              Row(
                children: [
                  // Container(
                  //   margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                      child: Text(
                        //"Bus Stop,Embulgama,Sri Lanka",
                        _address,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
              _buildSizedBox(5),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0, top: 10.0),
                    child: Text(
                      // set now time and date
                      //"Date and time : " " 2020-07-24 12:47:02",
                      DateFormat('yyyy-MM-dd  kk:mm:ss a')
                          .format(DateTime.now()),

                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              Container(
                margin:
                    const EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildSizedBox(5),
                      _buildDropDownPunchStatusType("Punch Status *"),
                      _buildSizedBox(5),
                      _buildSizedBox(10),
                      _buildSubmitBtn('Punch'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // panch data
  Future<void> panch() async {
    // check internet
    if (activeInternet) {
      //when internet available
      try {
        AttendanceData attendanceData = AttendanceData(
          userid: empNo.toString(),
          punchstatus: IndexOfSelectedDropDownItem.toString(),
          geo_location: _address,
          longitude: _longittude,
          latitude: _latitude,
        );

        //String token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiY2EwMTYwYTUxNDU0MzU1NzA4YTRjNzBhOWQxNzA5NjM1YjFhN2ZhY2Y2MjkzZmUyOTRkNTUwMDU5ZjZlYmFhY2Q4ZWQwYTAzMDQyYzViOTkiLCJpYXQiOjE2NTg4Mzc0NjQsIm5iZiI6MTY1ODgzNzQ2NCwiZXhwIjoxNjkwMzczNDY0LCJzdWIiOiIyIiwic2NvcGVzIjpbXX0.P5IGTVcBkivsY7bSVkbSsOapJ0cqWtx498n70lmr5WTC38-CyeO3IGG2A5xc1WgxA-294gAxrreeTxH9kMroHjFpwO3aLE1adop8Qs2Uao7dsmNzG1bLaIGv3CEFnpa8qDTLsweDPTba68VYCG1A1pHo2IIrC-6aGv6G4CLXNJPrsbTRGPsg4g4BX5AZtMPQq43cspyqSbVDfcKW3XWIgBR_5w9HQOi-HTar2Rj-C12NvbYPJELaI3Jsve7HsNYP8TpCSeF96aSapOYseDCL-vzsi-aWP3sMyoq7ZqbY2tIGzgg_CSMQFOG4c6dEUxcCTP5XGULsYxE96UhLPcehLaY1wxD4UGtF-t1FFMRsxgpr6e28UN3OsKvBtTo1J8WoWdGtQrKPDMtNz5ybIta1fJrPrgcl1yN5_c_MDJh3q7JHJ0qm5HZHZebIpTbRESHH1psdRnl4llzgbbjeNzh8elKNAcf5QpDyX9EX9pjBJizQ9J3-bYEOn_kJYQj1C6vJK7-Q17auzpPOL-dWGdAcHqKc2jUCXcrflQTM2cr0cdGLzw_XSg7rr0qtw7yLvq4eJGzOHoJNYzWG4dzGZ_8jkGCJtj4k7IRxOcW0cK5yQFzQpM_7zX4MoPcSfOmpeYyUUXzjOQzPO7qOkO18TyGRh9EEujA2GmN6zVkPYJyI6Y8';
        //getToken();

        final response = await http.post(
            Uri.parse("${Config.BACKEND_URL}attendance"),
            body: attendanceData.tojson(),
            headers: {
              // 'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Time has run out, do what you wanted to do.
            print(http.Response('Error', 408));
            return http.Response(
                'Error', 408); // Request Timeout response status code
          },
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          AttendanceResponse attendanceResponse =
              AttendanceResponse.fromJson(data);

          if (attendanceResponse.success) {
            print(attendanceResponse.message);

            responseMsg = attendanceResponse.message;

            IndexOfSelectedDropDownItem = null;

            setState(() {
              IndexOfSelectedDropDownItem = null;
              // reset drop down
              dropdownvalue = null;
              isLoading = false;
            });

            Fluttertoast.showToast(
              msg: responseMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          } else {
            setState(() {
              isLoading = false;
              IndexOfSelectedDropDownItem == null;
            });
            responseMsg = attendanceResponse.message;
            // show toast
            Fluttertoast.showToast(
              msg: responseMsg,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          setState(() {
            isLoading = false;
          });

          Fluttertoast.showToast(
            msg: 'Request failed with status: ${response.statusCode}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (e) {
        print(e.toString());
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'failed : ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } else {
      // when internet not available
      print('you are offline');
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'You are Offline',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
