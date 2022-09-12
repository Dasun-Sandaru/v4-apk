import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../helper/convertAddress.dart';
import '../../helper/sqldb.dart';
import '../../models/drop down/drowdowntypes.dart';
import '../../models/offlineData.dart';
import '../../models/market execution/market_execution.dart';
import '../../services/config.dart';
import '../../services/sharedPref.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' as pathpackage;

class MarketExecution extends StatefulWidget {
  const MarketExecution({Key? key}) : super(key: key);

  @override
  State<MarketExecution> createState() => _MarketExecutionState();
}

class _MarketExecutionState extends State<MarketExecution> {
  SharedPref sharedPref = SharedPref();
  SqlDb sqlDbObj = SqlDb();

  //----------------------------------------------------------
  String picPath =
      '/data/user/0/com.example.attendance_app_e01/cache/8c1b1eba-7ee2-4b13-bce1-9e968b815c132491224018646625388.jpg';

  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // txt feild controller
  TextEditingController outletController = TextEditingController();
  TextEditingController remarkdController = TextEditingController();

  // get image
  File? image;
  // variables
  File? image1, image2, image3, image4, image5;

  String? empNo;
  //String empNo = "100";
  String? empName;
  int? rowcount;

  var _latitude = 'current location';
  var _longittude = 'current location';
  var _altitude = 'current location';
  var _address = 'current location';
  //late String image1 = "logo.png";

  late String responseMsg;

  late String outletName;
  late String remarks;

  late String token;

  bool isLoading = false;
  bool isUploading = false;
  bool _200isOk = true;
  late bool hasofflineInfo;

  List<DropDownTypes> listOfDrofDownValues = [];
  List<dynamic> marketExecutionTypesInlocalDb = [];
  // List BB = [];
  var dropdownvalue;
  late String IdOfSelectedDropDownItem;
  String? IndexOfSelectedDropDownItem;

  bool activeInternet = true;

  late StreamSubscription _streamSubscriptionInternetActiviteInMarketScreen;

  @override
  void initState() {
    checkingInternetConnection();
    super.initState();

    // sharedPref.readToken();
    // token = (await sharedPref.readToken())!;

    // read offline state
    //readofflineStatus();

    // get empNo
    getEmpNo();

    //getOfflineDataInfo();

    // get row count
    getRowCount();

    // get Market execution types from local db
    //getMarketExecutiontypesFromlocalDb();

    // read token
    getToken();

    getCurrentPosition();
    getCurrentAddress();
  }

  // readofflineStatus() async {

  // }

  Future<void> checkingInternetConnection() async {
    /// call ckeck internet active
    _streamSubscriptionInternetActiviteInMarketScreen =
        InternetConnectionChecker().onStatusChange.listen((status) {
      // final activeInternet = status == InternetConnectionStatus.connected;
      // print('online status ---------------- $activeInternet');
      // setState(() {
      //   this.activeInternet = activeInternet;
      //   //text = activeInternet ? 'Online' : 'Offline';
      // });

      switch (status) {
        case InternetConnectionStatus.connected:
          activeInternet = true;
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
          activeInternet = false;
          print('You are disconnected from the internet.');
          break;

        default:
          print('in defalut $activeInternet');
      }

      SharedPref sharedPref = SharedPref();
      sharedPref.saveDataOnOff(activeInternet);
    });

    print('in await $activeInternet');
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionInternetActiviteInMarketScreen.cancel();
  }

  // methods

  getRowCount() async {
    try {
      // checking local db row count
      rowcount = await sqlDbObj.getRowCount();
      setState(() {
        rowcount = rowcount;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // pick img
  pickImage(int index) async {
    try {
      final commonImg = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 30);

      switch (index) {
        case 1:
          if (commonImg == null) {
            print('imgage 1 --> $image1');
          } else {
            //image1 = File(commonImg.path);

            // print('imgage 1 --> $image1');

            // String dir = pathpackage.dirname(commonImg.path);
            // String newName = pathpackage.join(
            //     dir, '$empNo-index-$index-${DateTime.now()}.png');
            // File(commonImg.path).renameSync(newName);

            // print(newName);
            // GallerySaver.saveImage(newName, albumName: "AttendanceApp");
            // image1 = File(newName);

            image1 = File(renameFilePath(commonImg));
            setState(() {});
          }
          break;

        case 2:
          if (commonImg == null) {
            print('imgage2 --> $commonImg');
          } else {
            // image2 = File(commonImg.path);
            print('imgage20 --> $image2');
            image2 = File(renameFilePath(commonImg));
            print('imgage21 --> $image2');
            setState(() {});
          }
          break;

        case 3:
          if (commonImg == null) {
            print('imgage 3 --> $image3');
          } else {
            //image3 = File(commonImg.path);
            print('imgage 3 --> $image3');
            image3 = File(renameFilePath(commonImg));
            setState(() {});
          }
          break;

        case 4:
          if (commonImg == null) {
            print('imgage 4 --> $image4');
          } else {
            //image4 = File(commonImg.path);
            print('imgage 4 --> $image4');
            image4 = File(renameFilePath(commonImg));
            setState(() {});
          }
          break;

        case 5:
          if (commonImg == null) {
            print('imgage 5 --> $image5');
          } else {
            //image5 = File(commonImg.path);
            image5 = File(renameFilePath(commonImg));
            setState(() {});
          }
          break;

        default:
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');

      //show toast
      Fluttertoast.showToast(
        msg: 'Camera Access Denied! Please Allow access to the camera',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // rename file name
  String renameFilePath(var commonImg) {
    print('imgage  <--> $image');

    String dir = pathpackage.dirname(commonImg.path);
    print('dir galley $dir');
    String newName = pathpackage.join(dir, '$empNo-${DateTime.now()}.png');
    File(commonImg.path).renameSync(newName);

    print('New File Name ---> $newName');
    GallerySaver.saveImage(newName, albumName: "VBL SWAT");

    return newName;
  }

  // get emp no
  getEmpNo() async {
    // get emp no & name
    empNo = (await sharedPref.readEmpId())!;
    empName = (await sharedPref.readEmpName())!;

    setState(() {});
  }

  // get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      try {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        Fluttertoast.showToast(
          msg: 'Turn on location',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
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
            toastLength: Toast.LENGTH_LONG,
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
      Fluttertoast.showToast(
        msg: 'Turn on location',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('-----------------------------');
    print(await Geolocator.getCurrentPosition());
    print('-----------------------------');
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  // get current address
  Future<void> getCurrentAddress() async {
    try {
      Position pos = await getCurrentPosition();
      _latitude = pos.latitude.toString();
      _longittude = pos.longitude.toString();
      _altitude = pos.altitude.toString();

      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      List<Location> locations =
          await locationFromAddress(placemarks[0].toString());

      //
      //print(placemarks);
      Placemark place = placemarks[0];

      setState(() {
        // _address = '${place.street},${place.subLocality}${place.locality}${place.postalCode},${place.country}';
        // _address = '${place.street},${place.subLocality}${place.locality}';
        //_address = '${place.street} ${place.subLocality}';
        _address =
            '${place.street}${place.subLocality}${place.locality}${place.country}';
        //_address = 'japan';
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // get current address
  Future<String?> decodeAddressCodes(
      var local_longitude, var local_latitude) async {
    String decodeAddress;
    try {
      Position pos = await getCurrentPosition();
      _latitude = pos.latitude.toString();
      _longittude = pos.longitude.toString();
      _altitude = pos.altitude.toString();

      List<Placemark> placemarks =
          await placemarkFromCoordinates(local_latitude, local_longitude);
      List<Location> locations =
          await locationFromAddress(placemarks[0].toString());
          
      //print(placemarks);
      Placemark place = placemarks[0];
      decodeAddress =
          '${place.street}${place.subLocality}${place.locality}${place.country}';

      //print('decodeAddress  ---> $decodeAddress');

      return decodeAddress;
    } catch (e) {
      print(e.toString());
    }
  }

  // get token
  getToken() async {
    SharedPref sharedPref = SharedPref();

    activeInternet = (await sharedPref.readDataOnOff());
    print('in maekrt $activeInternet');

    print('token');

    token = (await sharedPref.readToken())!;

    //await getDropDownValues(token);

    await getMarketExecutiontypesFromlocalDb();

    //get offline drop down values
    //readData();
  }

  // get execution types form local db
  getMarketExecutiontypesFromlocalDb() async {
    print('good');
    try {
      String sql = 'SELECT * FROM ExecutionTypes WHERE id = 1';
      marketExecutionTypesInlocalDb = await sqlDbObj.readExecutionTypes(sql);
      int uu = marketExecutionTypesInlocalDb.length;
      // print(
      //     'AA >>>>>>>>>>>>>$uu>>>>>>>>>>>>>>>>>>>$marketExecutionTypesInlocalDb');
      getDropDownValues(token);
    } catch (e) {
      print(e.toString());
    }
  }

  readData() async {
    String sql = 'SELECT * FROM ExecutionTypes';
    List<Map<String, dynamic>> response = await sqlDbObj.readData(sql);
    //listOfDrofDownValues = response;
    print(response[0]);
    print('$response');
  }

  // img selection part
  Widget _buildImgsSelect() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(3.0),
        child: Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: [
            //1st img
            GestureDetector(
              onTap: () {
                pickImage(1);
              },
              child: Container(
                //color: Colors.white,
                child: image1 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image1!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/1_Selfie.png',
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            //2nd img
            GestureDetector(
              onTap: () {
                pickImage(2);
              },
              child: Container(
                //color: Colors.white,
                child: image2 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image2!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/2_Store outside.png',
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            //3rd img
            GestureDetector(
              onTap: () {
                pickImage(3);
              },
              child: Container(
                //color: Colors.white,
                child: image3 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image3!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/3_Store inside.png',
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            //4th img
            GestureDetector(
              onTap: () {
                pickImage(4);
              },
              child: Container(
                //color: Colors.white,
                child: image4 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image4!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/4_Cooler.png',
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            //5th img
            GestureDetector(
              onTap: () {
                pickImage(5);
              },
              child: Container(
                //color: Colors.white,
                child: image5 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          image5!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/5_Competitor analysis.png',
                        width: 100,
                        height: 100,
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getDropDownValues(String token) async {
    // BB = [
    //   {"val_id": "GM", "val_des": "Gate Meeting"},
    //   {"val_id": "WW", "val_des": "Work with"},
    //   {"val_id": "CA", "val_des": "Competetor Activities"},
    //   {"val_id": "NAC", "val_des": "New Account Crack"}
    // ];

    try {
      // print(
      //     'types <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< $marketExecutionTypesInlocalDb');
      if (marketExecutionTypesInlocalDb.isNotEmpty) {
        for (var element in marketExecutionTypesInlocalDb) {
          var val_id = element['val_id'];
          var val_des = element['val_des'];

          DropDownTypes dropDownTypesObj =
              DropDownTypes(val_id: val_id, val_des: val_des);
          listOfDrofDownValues.add(dropDownTypesObj);
          //print(listOfDrofDownValues[0].val_des);
          //print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> $element');
          // print(element);
        }

        setState(() {});
      } else {
        print(marketExecutionTypesInlocalDb);
      }
    } catch (e) {
      print(e.toString());
    }

    // try {
    //   final responseType = await http.get(
    //       Uri.parse("${Config.BACKEND_URL}market-execution/types"),
    //       headers: {
    //         'Authorization': 'Bearer $token',
    //       });

    //   if (responseType.statusCode == 200) {
    //     Map decodedMap = jsonDecode(responseType.body);

    //     List<dynamic> responseListPart = decodedMap['data'];

    //     print('responseListPart ----> $responseListPart');

    //     if (responseListPart.isNotEmpty) {
    //       for (var element in responseListPart) {
    //         var val_id = element['val_id'];
    //         var val_des = element['val_des'];

    //         DropDownTypes dropDownTypesObj =
    //             DropDownTypes(val_id: val_id, val_des: val_des);
    //         listOfDrofDownValues.add(dropDownTypesObj);
    //         print(listOfDrofDownValues[0].val_des);
    //       }
    //     } else {
    //       // drow down values has
    //       Fluttertoast.showToast(
    //         msg: 'Sorry ! Execution Types currnently not available',
    //         toastLength: Toast.LENGTH_LONG,
    //         gravity: ToastGravity.BOTTOM,
    //       );
    //     }

    //     print(listOfDrofDownValues[0].val_des);

    //     // // this set State need to refesh drop down
    //     setState(() {});
    //   } else {
    //     print('Request failed with status: ${responseType..statusCode}');

    //     Fluttertoast.showToast(
    //       msg: 'Request failed with status: ${responseType.statusCode}',
    //       toastLength: Toast.LENGTH_LONG,
    //       gravity: ToastGravity.BOTTOM,
    //     );
    //   }
    // } catch (e) {
    //   print(e.toString());
    // }
  }

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
            controller: remarkdController,
            //obscureText: isPassword,
            maxLines: 3,
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),

            validator: (text) {
              // validate
              if (text!.isEmpty) {
                return "Remarks Required !";
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

  Widget _buildOutletField(String title) {
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
            controller: outletController,
            //obscureText: isPassword,
            maxLines: 1,
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),

            validator: (text) {
              // validate
              if (text!.isEmpty) {
                return "Outlet Name Required !";
              }

              return null;
            },

            onSaved: (value) {
              outletName = value!.trim();
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
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // execution type
              if (dropdownvalue == null) {
                // user not selected
                // show toast
                Fluttertoast.showToast(
                  msg: 'Please Select Execution Type',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              } else {
                // user selected
                // submit

                // enable location
                OnLocation onLocation = OnLocation();
                bool isReturnOn = await onLocation.enableLocation();

                if (isReturnOn) {
                  await getCurrentPosition();
                  await getCurrentAddress();
                  setState(() {});
                  if (_address == 'current location' && _latitude == 'current location') {
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
                    punch();
                  }
                }
              }
            } else {
              print("Error in validation state");
            }

            //deleteSumittedDataRow(1);
            //punch();
            //pickImage();
            //uploadImage();

            // saveMarketExecutionData1();
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

  // Sized Box
  Widget _buildSizedBox(double h) {
    return SizedBox(
      height: h,
    );
  }

  // // drop down punch status
  Widget _buildDropDownExecutionType(String title) {
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
                    // Initial Value
                    value: dropdownvalue,
                    isExpanded: true,

                    hint: const Text(
                      'Select Punch Status',
                      style: TextStyle(fontSize: 20.0, color: Colors.grey),
                    ),

                    // Down Arrow Icon
                    icon: const Icon(Icons.arrow_downward, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,

                    // Array list of items
                    items: listOfDrofDownValues.map(
                      (DropDownModelClzObj) {
                        var dropdownMenuItem = DropdownMenuItem<DropDownTypes>(
                          value: DropDownModelClzObj,
                          child: Text(
                            DropDownModelClzObj.val_des,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                        return dropdownMenuItem;
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
                              listOfDrofDownValues[indexOfSelectedItem].val_id.toString();

                          IndexOfSelectedDropDownItem =
                              indexOfSelectedItem.toString();

                          print(
                              'Id of selected item --> $IdOfSelectedDropDownItem');
                          print(
                              'Index of selected item --> $IndexOfSelectedDropDownItem');

                          // to
                          //pickImage();
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
        // floatingActionButton: FloatingActionButton(onPressed: () async {
        //   //deleteSumittedDataRow(5);
        //   readMarketExecutionData();
        //   // String sql = 'DELETE FROM markettbl WHERE id = 2';
        //   //   var res = await sqlDbObj.deleteData(sql);
        //   //   print(res);

        //   //deleteImgFromGallery('s');
        // }),
        backgroundColor: const Color(0xff043776),
        appBar: AppBar(
          backgroundColor: const Color(0xff043776),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 17, 0, 10),
              child: Text(
                '$rowcount',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (rowcount! > 0) {
                  // show arlet box
                  buildCustomDialog();
                } else {
                  Fluttertoast.showToast(
                    msg: 'Currently you haven\'t offline data',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              icon: isUploading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
            ),
          ],
          title: const Text("Selfie Punch"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: _buildImgsSelect(),
                    //child: _buildSingleImageView(),
                  ),
                ],
              ),
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
                      //_buildDropDownType('Punch Status *'),
                      _buildSizedBox(5),
                      _buildDropDownExecutionType("Execution Type *"),
                      _buildSizedBox(5),
                      _buildOutletField('Outlet Name'),
                      _buildSizedBox(5),
                      _buildEntryField('Remarks *'),
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

  // internet alert dialog
  Future buildCustomDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (newNotification) {
          return AlertDialog(
            title: const Text('Offline Data'),
            content: const Text('Do you need submit offline data ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  //reloadData();
                  isUploading = true;
                  readMarketExecutionData();
                },
                child: const Text('Submit Data'),
              )
            ],
          );
        });
  }

  punch() async {
    print('activeInternet --> $activeInternet');
    if (activeInternet) {
      // imgs upload
      SelfieImg selfieImg = SelfieImg();
      bool isDone = await selfieImg.Punch(
        token,
        empNo!,
        _address,
        _longittude,
        _latitude,
        outletName,
        IndexOfSelectedDropDownItem.toString(),
        remarks,
        image1: image1,
        image2: image2,
        image3: image3,
        image4: image4,
        image5: image5,
      );

      // if done
      if (isDone) {
        IndexOfSelectedDropDownItem = null;

        // romove shared ref ---------------------------------------------------------------------------------------------------------------------

        setState(() {
          IndexOfSelectedDropDownItem = null;
          // reset drop down
          dropdownvalue = null;
          // clear txt feilds
          remarkdController.text = '';
          outletController.text = '';
          //clear imgs
          image1 = null;
          image2 = null;
          image3 = null;
          image4 = null;
          image5 = null;

          isLoading = false;
        });
      } else {
        saveMarketExecutionData1();
        // not done
        setState(() {
          IndexOfSelectedDropDownItem = null;
          // reset drop down
          dropdownvalue = null;
          // clear txt feilds
          remarkdController.text = '';
          outletController.text = '';
          //clear imgs
          image1 = null;
          image2 = null;
          image3 = null;
          image4 = null;
          image5 = null;

          isLoading = false;
        });
      }
    } else {
      // add shared ref ---------------------------------------------------------------------------------------------------------------------
      //saveMarketExecutionData();
      // add local db -----------------------------------------------------------------------------------------------------------------
      saveMarketExecutionData1();
      //when internet not available
      print('you are offline');
      setState(() {
        IndexOfSelectedDropDownItem = null;
        isLoading = false;
        remarkdController.text = '';
        outletController.text = '';
        dropdownvalue = null;
        //clear imgs
        image1 = null;
        image2 = null;
        image3 = null;
        image4 = null;
        image5 = null;
      });
      Fluttertoast.showToast(
        msg: 'You are Offline',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // insert data
  Future<void> saveMarketExecutionData1() async {
    print('longitude -: ' + '$_longittude');
    print('latitude -: ' + '$_latitude');
    try {
      String table = 'markettbl';
      Map<String, dynamic> userData = {
        "userid": "$empNo",
        "geo_location": _address,
        "longitude": _longittude,
        "latitude": _latitude,
        "outlet_name": outletName,
        "execution_type": IndexOfSelectedDropDownItem,
        "remarks": remarks,
        "image1": image1?.path,
        "image2": image2?.path,
        "image3": image3?.path,
        "image4": image4?.path,
        "image5": image5?.path,
      };

      int responselocalDb = await sqlDbObj.insertData(table, userData);
      print('$responselocalDb');

      getRowCount();

      Fluttertoast.showToast(
        msg: 'Your submitted data has saved as offline data',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  // read data
  readMarketExecutionData() async {
    try {
      String sql = 'SELECT * FROM markettbl';
      //String sql = 'SELECT * FROM markettbl WHERE id = 10';
      List<Map> responselocalDb = await sqlDbObj.readData(sql);
      print('$responselocalDb');
      preparing(responselocalDb);
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print(e.toString());
    }
  }

  deleteSumittedDataRow(int rowId) async {
    try {
      // try delete img from gallery
      // String deleteImgeFromFallery = 'SELECT image2 FROM markettbl WHERE id = $rowId';

      // for (var i = 1; i < 6; i++) {
      //   String deleteImgFromGallery_Id =
      //       'SELECT image$i FROM markettbl WHERE id = $rowId';

      //   var response = await sqlDbObj.readData(deleteImgFromGallery_Id);
      //   print(response);
      //   print(response[0]['image$i']);

      //   if (response[0]['image$i'] != null) {
      //     deleteImgFromGallery(response[0]['image$i']);
      //   }
      // }

      String sql = 'DELETE FROM markettbl WHERE id = $rowId';
      int response = await sqlDbObj.deleteData(sql);
      print('$response');
      getRowCount();

      setState(() {
        isUploading = false;
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {});
  }

  // delete img from gallery
  // deleteImgFromGallery(String deleteImgFromGalleryImgPath) {
  //   try {
  //     final dir = Directory('100-2022-08-28 11_06_44.975211.png');
  //     // dir.deleteSync(recursive: true);
  //     //File('/Internal storage/Pictures/AttendanceApp/100-2022-08-26 17:09:10.627951.png').deleteSync();
  //     dir.deleteSync(recursive: true);
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Preparing

  Future<void> preparing(List responselocalDb) async {
    for (var element in responselocalDb) {
      print(element);

      if (_200isOk) {
        if (activeInternet) {
          print(activeInternet);
          // methods run
          // pass offline clz and decode map
          OfflineData offlineDataObj = OfflineData.fromJson(element);
          // pass prepare data to punchofflineData method

          print(element);

          var local_longitude = double.parse(offlineDataObj.longitude);
          var local_latitude = double.parse(offlineDataObj.latitude);

          String? decodeaddress =
              await decodeAddressCodes(local_longitude, local_latitude);

          if (decodeaddress == null) {
            setState(() {
              isUploading = false;
            });

            Fluttertoast.showToast(
              msg: "Please try again",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
          print('local_longitude  ------> $local_longitude');
          print('local_latitude  ------> $local_latitude');
          print('decodeaddress  ------> $decodeaddress');

          Future.delayed(Duration(seconds: 5), () {
            punchOfflineData(
              offlineDataObj.id,
              offlineDataObj.userid,
              // offlineDataObj.geo_location,
              decodeaddress!,
              offlineDataObj.longitude,
              offlineDataObj.latitude,
              offlineDataObj.outlet_name,
              offlineDataObj.execution_type,
              offlineDataObj.remarks,
              offlineDataObj.image1,
              offlineDataObj.image2,
              offlineDataObj.image3,
              offlineDataObj.image4,
              offlineDataObj.image5,
            );
          });
        } else {
          setState(() {
            isUploading = false;
          });
          Fluttertoast.showToast(
            msg: "Your are offline",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          break;
        }
      } else {
        setState(() {
          isUploading = false;
        });
        Fluttertoast.showToast(
          msg: "Please try again later",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool?> punchOfflineData(
    int rowId,
    String userid,
    String geo_location,
    String longitude,
    String latitude,
    String outlet_name,
    String execution_type,
    String remarks,
    String? image1,
    String? image2,
    String? image3,
    String? image4,
    String? image5,
  ) async {
    // imgs upload
    SelfieImg selfieImg = SelfieImg();
    bool isOfflineDone = await selfieImg.PunchOfflineData(
      token,
      userid,
      geo_location,
      longitude,
      latitude,
      outlet_name,
      execution_type,
      remarks,
      image1: image1,
      image2: image2,
      image3: image3,
      image4: image4,
      image5: image5,
    );
    //if done
    if (isOfflineDone) {
      // done // ------------------------------------------------------------
      // ---------------------------------------------------------------------

      _200isOk = true;
      // delete row data in local db
      deleteSumittedDataRow(rowId);
      // toast data one data sumbitted

      // Fluttertoast.showToast(
      //   msg: 'Punch offline row id -> $rowId',
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.BOTTOM,
      // );
    } else {
      // not done // ------------------------------------------------------------
      setState(() {
        isUploading = false;
      });

      _200isOk = false;
    }
  }
}
