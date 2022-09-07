import 'dart:async';
import 'dart:convert';

import 'package:attendance_app_e01/models/leave/leaveData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../models/drop down/drowdowntypes.dart';
import '../../services/config.dart';
import '../../services/sharedPref.dart';

enum HalfTypeEnum { FirstHalf, SecondHalf }

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({Key? key}) : super(key: key);

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  // form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // txt filed controller
  TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();

    which = 'Date From*';

    pickedDateTo = DateTime.now(); // select to date filed
    pickedDateFrom = DateTime.now(); // select From date filed
    pickedTimeTo =
        const TimeOfDay(hour: 00, minute: 00); // // select to date filed
    pickedTimeFrom =
        const TimeOfDay(hour: 00, minute: 00); // select from date filed

    // call ckeck internet active
    _streamSubscriptionInternetActiviteInLeaveScreen =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final activeInternet = event == InternetConnectionStatus.connected;

      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });

    // get empNo
    getEmpNo();

    // // read token
    getToken();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionInternetActiviteInLeaveScreen.cancel();
  }

  int WhichLeavetype = 0;
  late String which;

  // full day - date from + 00.00 To date to + 23.59
  // half 1st - date from + 00.00 To date to + 12.30
  // half 2nd - date from + 12.30 To date to + 00.00

  late String value;
  // internet avative
  late StreamSubscription _streamSubscriptionInternetActiviteInLeaveScreen;
  bool activeInternet = true;
  late String token;
  late String responseMsg;

  String userid = '';
  String startdate = '';
  String enddate = '';
  String leavetype = '';
  String reason = '';
  String date = '';
  String half_or_full = '';
  String half_time = '';

  SharedPref sharedPref = SharedPref();

  late String empNo;
  String? empName;

  bool isLoading = false;
  // bool isHalfDayOnFromDate = false; // check box --- half day - true
  // bool isHalfDayOnToDate = false; // check box --- half day - true
  // bool isVisibleOnFromDate = false;
  // bool isVisibleOnToDate = false;
  HalfTypeEnum? _halfTypeEnum; // radio
  // int selectedRadioForFromDate = 0;
  // int selectedRadioForToDate = 0;

  bool isHalfDay = false; // check box --- half day - true
  bool isVisibleOnForRadioBtns = false;
  bool isVisibleOnForFromDate = true;
  int selectedRadio = 0;

  List<DropDownTypes> listOfDrofDownValues = [];
  var dropdownvalue;
  late String IdOfSelectedDropDownItem;
  String? IndexOfSelectedDropDownItem;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // select to date filed
  late DateTime pickedDateTo;
  // select From date filed
  late DateTime pickedDateFrom;
  // select to time
  late TimeOfDay pickedTimeTo;
  // select From time
  late TimeOfDay pickedTimeFrom;

  // methods

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

  // submit data
  Future<void> submit(String half_or_full, String half_time) async {
    // check internet
    if (activeInternet) {
      //when internet available
      if (isHalfDay) {
        if (WhichLeavetype == 0) {
          print('plz select half time');
          // show toast
          Fluttertoast.showToast(
            msg: 'Please select half time',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          setState(() {
            isLoading = false;
          });
        } else if (WhichLeavetype == 1) {
          // 1st half
          // half_time ---> M
          print('half_time ---> M');
          half_or_full = 'H';
          half_time = 'M';
          startdate = DateFormat('yyyy-MM-dd').format(pickedDateFrom);
          enddate = startdate;
          date = DateFormat('yyy-MM-dd').format(DateTime.now());

          submitAll(empNo, half_or_full, half_time, startdate, enddate,
              IndexOfSelectedDropDownItem, reason, date);
        } else if (WhichLeavetype == 2) {
          // 2nd half
          // half_time ---> A
          print('half_time ---> A');
          half_or_full = 'H';
          half_time = 'A';
          startdate = DateFormat('yyyy-MM-dd').format(pickedDateFrom);
          enddate = startdate;
          date = DateFormat('yyy-MM-dd').format(DateTime.now());

          submitAll(empNo, half_or_full, half_time, startdate, enddate,
              IndexOfSelectedDropDownItem, reason, date);
        }
      } else {
        WhichLeavetype = 0;
        // nomal
        /// half_or_full ---> F
        print('half_or_full ---> F');
        // pickedDateTo = DateTime.now(); // select to date filed
        // pickedDateFrom = DateTime.now(); // select From date filed
        half_or_full = 'F';
        half_time = 'M';
        startdate = DateFormat('yyyy-MM-dd').format(pickedDateFrom);
        enddate = DateFormat('yyyy-MM-dd').format(pickedDateTo);
        date = DateFormat('yyy-MM-dd').format(DateTime.now());

        submitAll(empNo, half_or_full, half_time, startdate, enddate,
            IndexOfSelectedDropDownItem, reason, date);
      }

      // print(
      //     "-------------------------" + IndexOfSelectedDropDownItem.toString());

    } else {
      //when internet not available
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

  // use for get to date
  _toDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickedDateFrom,
      // firstDate: DateTime.now().subtract(const Duration(days: 0)),
      // firstDate: DateTime(pickedDateTo.year),
      //firstDate: DateTime(pickedDateTo.year).subtract(const Duration(days: 1)),
      firstDate: DateTime(
          pickedDateFrom.year, pickedDateFrom.month, pickedDateFrom.day),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(
        () {
          pickedDateTo = picked;
          enddate = pickedDateTo.toString();
        },
      );
    }
  }

  // use for get from date
  _fromDate() async {
    final DateTime? pickeddate = await showDatePicker(
        context: context,
        initialDate: pickedDateFrom,
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(DateTime.now().year + 5));

    if (pickeddate != null) {
      setState(
        () {
          pickedDateFrom = pickeddate;
          startdate = pickeddate.toString();
          print(startdate);
        },
      );
    }
  }

  // get drop down values
  void getDropDownValues(String token) async {
    try {
      final responseType = await http
          .get(Uri.parse("${Config.BACKEND_URL}leave/types"), headers: {
        'Authorization': 'Bearer $token',
      });

      if (responseType.statusCode == 200) {
        Map decodedMap = jsonDecode(responseType.body);

        List<dynamic> responseListPartofleavetype = decodedMap['data'];

        // checking drop down values has
        if (responseListPartofleavetype.isNotEmpty) {
          for (var element in responseListPartofleavetype) {
            var valId = element['val_id'];
            var valDes = element['val_des'];

            DropDownTypes dropDownTypesObj =
                DropDownTypes(val_id: valId, val_des: valDes);
            listOfDrofDownValues.add(dropDownTypesObj);
            // print(listOfDrofDownValues[0].val_des);
          }
        } else {
          // drow down values has
          Fluttertoast.showToast(
            msg: 'Sorry ! Leave Types currnently not available',
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

  // select leave half   half - true, first - 1 , second - 2 / null - 0
  Widget _buildLeaveDayType() {
    // check box for select Full day or Half day -----> true = half day
    return Container(
      // check box for select Full day or Half day -----> true = half day
      child: Column(
        children: [
          // check box
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.white70,
                width: 30,
                height: 30,
                child: Checkbox(
                  //tristate: true,
                  checkColor: Colors.red,
                  //activeColor: Colors.deepPurple,
                  activeColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  value: isHalfDay,
                  onChanged: (val) {
                    setState(() {
                      isHalfDay = val!;
                    });

                    if (isHalfDay) {
                      setState(() {
                        which = 'Date';
                        isVisibleOnForRadioBtns = true;
                        isVisibleOnForFromDate = false;
                      });
                    } else {
                      setState(() {
                        which = 'Date From*';
                        // pickedDateTo = DateTime.now();
                        // pickedDateFrom = DateTime.now();
                        isVisibleOnForRadioBtns = false;
                        isVisibleOnForFromDate = true;
                        WhichLeavetype = 0;
                        half_time = '';
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Half Day',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
            ],
          ),
          _buildSizedBox(10),
          // radio button
          Visibility(
            visible: isVisibleOnForRadioBtns,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: RadioListTile(
                    // visualDensity: const VisualDensity(horizontal: 0.0),
                    dense: true,
                    title: const Text(
                      'First Half',
                      textAlign: TextAlign.left,
                    ),
                    contentPadding: const EdgeInsets.all(0.0),
                    activeColor: Colors.red,
                    tileColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    value: 1,
                    groupValue: WhichLeavetype,
                    onChanged: (val) {
                      setState(() {
                        print('Radio 1 --> $val');

                        WhichLeavetype = int.parse(val.toString());
                        print(WhichLeavetype);
                      });

                      //setSelectedRadio(selectedRadio);
                    },
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: RadioListTile(
                    dense: true,
                    title: const Text('Second Half'),
                    contentPadding: const EdgeInsets.all(0.0),
                    activeColor: Colors.red,
                    tileColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    value: 2,
                    groupValue: WhichLeavetype,
                    onChanged: (val) {
                      setState(() {
                        print('Radio 2 --> $val');

                        WhichLeavetype = int.parse(val.toString());
                        print(WhichLeavetype);
                      });

                      //setSelectedRadio(selectedRadio);
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

  // drop down leave type
  Widget _buildbuildDropDownLeaveType(String title) {
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
                      'Select Leave Type',
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

  // from date
  Widget _buildFromDate(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // title,
            which,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(width: 1.0, color: Colors.white),
                  left: BorderSide(width: 1.0, color: Colors.white),
                  right: BorderSide(width: 1.0, color: Colors.white),
                  bottom: BorderSide(width: 1.0, color: Colors.white),
                ),
                borderRadius: BorderRadius.all(Radius.circular(0))),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                          // '${pickedDateFrom.day}/${pickedDateFrom.month}/${pickedDateFrom.year}/ - ${pickedTimeFrom.hour}:${pickedTimeFrom.minute}',
                          //'${pickedDateFrom.day}/${pickedDateFrom.month}/${pickedDateFrom.year}',
                          '${pickedDateFrom.year} / ${pickedDateFrom.month} / ${pickedDateFrom.day}',
                          /////////////////////////////////////////////////////////////////////////////
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15)),
                    ),
                    onTap: () {
                      _fromDate();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    tooltip: 'Tap to open date picker',
                    onPressed: () {
                      _fromDate();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // to date
  Widget _buildToDate(String title) {
    return Visibility(
      visible: isVisibleOnForFromDate,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Colors.white),
                    left: BorderSide(width: 1.0, color: Colors.white),
                    right: BorderSide(width: 1.0, color: Colors.white),
                    bottom: BorderSide(width: 1.0, color: Colors.white),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(0))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        child: Text(
                            //pickedDateTo.toString() + pickedTimeTo.hour.toString(), // -------------------------------------------------------------
                            //'${pickedDateTo.day}/${pickedDateTo.month}/${pickedDateTo.year}/ - ${pickedTimeTo.hour}:${pickedTimeTo.minute}',
                            // '${pickedDateTo.day}/${pickedDateTo.month}/${pickedDateTo.year}',
                            '${pickedDateTo.year} / ${pickedDateTo.month} / ${pickedDateTo.day}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15)),
                        onTap: () {
                          //__toDate(context);
                          //print('to date');
                        },
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.white),
                      tooltip: 'Tap to open date picker',
                      onPressed: () {
                        _toDate();
                        print('to date');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResonField(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                return "Reason Required !";
              }

              return null;
            },

            onSaved: (value) {
              reason = value!.trim();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    //final f = new DateFormat('yyyy-MM-dd hh:mm');
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ButtonTheme(
        minWidth: MediaQuery.of(context).size.width,
        buttonColor: const Color(0xFFee3a43), //  <-- dark color
        textTheme: ButtonTextTheme.primary,
        child: RaisedButton(
          onPressed: () {
            try {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // check user select leave type
                if (IndexOfSelectedDropDownItem == null) {
                  // user not selected
                  // show toast
                  Fluttertoast.showToast(
                    msg: 'Please Select Leave Type',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                } else {
                  // user selected
                  if (isHalfDay) {
                    if (WhichLeavetype == 0) {
                      print('plz select half time');
                    } else if (WhichLeavetype == 1) {
                      // 1st half
                      // half_time ---> M
                      print('half_time ---> M');
                      half_or_full = 'H';
                      half_time = 'M';
                    } else if (WhichLeavetype == 2) {
                      // 2nd half
                      // half_time ---> A
                      print('half_time ---> A');
                      half_or_full = 'H';
                      half_time = 'A';
                    }
                  } else {
                    WhichLeavetype = 0;
                    // nomal
                    /// half_or_full ---> F
                    print('half_or_full ---> F');
                    half_or_full = 'F';
                  }
                  // submit
                  setState(() {
                    isLoading = true;
                    //IndexOfSelectedDropDownItem = null;
                  });
                  submit(half_or_full, half_time);
                }
              } else {
                print("Error in validation state");
              }
            } catch (e) {
              print(e.toString());
            }
          },
          textColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFFee3a43),
                  Color(0xFFee3a43),
                  Color(0xFFee3a43),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            // child: const Text('Submit',
            //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

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
      ),
    );
  }

  // Sized Box
  Widget _buildSizedBox(double h) {
    return SizedBox(
      height: h,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff043776),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //helpPrint();
      //     //validateAndgetWhichtypeOnFromDate();
      //     // validateAndgetWhichtypeOFleave();

      //     helpPrint();
      //   },
      //   child: const Icon(Icons.add),
      // ),
      appBar: AppBar(
        backgroundColor: const Color(0xff043776),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text("Leave Application"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildSizedBox(15),
                    // _buildLeaveDayType(),
                    // _buildSizedBox(5),
                    _buildbuildDropDownLeaveType('Leave Type *'),
                    _buildSizedBox(5),
                    _buildLeaveDayType(),
                    _buildSizedBox(5),
                    _buildFromDate('Date From *'),
                    // _buildLeaveDayTypeForFromDate(),
                    _buildSizedBox(5),
                    _buildToDate('Date To *'),
                    // _buildLeaveDayTypeForTodate(),
                    _buildSizedBox(5),
                    //_datepickertoField(),
                    _buildResonField('Reason *'),
                    _buildSizedBox(10),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// for helper

  // int WhichLeavetype = 0;
  // bool isHalfDay = false; // check box --- half day - true
  // bool isVisibleOn = false;

  submitAll(
      String empNo,
      String half_or_full,
      String half_time,
      String startdate,
      String enddate,
      String? IndexOfSelectedDropDownItem,
      String reason,
      String date) async {
    try {
      print('userid :- $empNo');
      print('startdate :- $startdate');
      print('enddate :- $enddate');
      print('leavetype :- $IndexOfSelectedDropDownItem');
      print('reason :- $reason');
      print('date :- $date');
      print('half_or_full :- $half_or_full');
      print('half_time :- $half_time');

      LeaveData leaveData = LeaveData(
        userid: empNo,
        half_or_full: half_or_full,
        half_time: half_time,
        startdate: startdate,
        enddate: enddate,
        // IdOfSelectedDropDownItem
        leavetype: IndexOfSelectedDropDownItem.toString(),
        reason: reason,
        date: date,
      );

      //getToken();

      final response = await http.post(Uri.parse("${Config.BACKEND_URL}leave"),
          body: leaveData.toJson(),
          headers: {
            // 'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        LeaveResponse leaveResponse = LeaveResponse.fromJson(data);

        if (leaveResponse.success) {
          print(leaveResponse.message);
          responseMsg = leaveResponse.message;
          IndexOfSelectedDropDownItem == null;

          setState(() {
            // clear reason txt feild / reset drop down values / reset date from & to date
            dropdownvalue = null;
            remarkController.text = '';
            pickedDateFrom = DateTime.now(); // select From date filed
            pickedDateTo = DateTime.now(); // select to date filed
            isLoading = false;
            half_or_full = '';
            half_time = '';
            isHalfDay = false;
            WhichLeavetype = 0;
            IndexOfSelectedDropDownItem = null;
          });

          // show toast
          Fluttertoast.showToast(
            msg: responseMsg,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          setState(() {
            isLoading = false;
            IndexOfSelectedDropDownItem = null;
            dropdownvalue = null;
          });
          responseMsg = leaveResponse.message;
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
  }

  helpPrint() {
    startdate = DateFormat('yyyy-MM-dd').format(pickedDateFrom);
    enddate = DateFormat('yyyy-MM-dd').format(pickedDateTo);
    date = DateFormat('yyy-MM-dd').format(DateTime.now());
    // print check box value
    // print('check box val ---> $isHalfDay');
    // // print radio value
    // print('radio val ---> $selectedRadio');

    // // clear check box
    // isHalfDay = false;
    // // clear radio btns
    // selectedRadio = 0;
    // _halfTypeEnum = null;

    if (isHalfDay) {
      if (WhichLeavetype == 0) {
        print('plz select half time');
      } else if (WhichLeavetype == 1) {
        // 1st half
        // half_time ---> M
        print('half_time ---> M');
        half_or_full = 'H';
        half_time = 'M';
      } else if (WhichLeavetype == 2) {
        // 2nd half
        // half_time ---> A
        print('half_time ---> A');
        half_or_full = 'H';
        half_time = 'A';
      }
    } else {
      WhichLeavetype = 0;
      // nomal
      /// half_or_full ---> F
      print('half_or_full ---> F');
      half_or_full = 'F';
      half_time = 'F';
    }

    //   if (WhichLeavetype == 0) {
    //     print('plz select half time');
    //   } else {
    //     if (WhichLeavetype == 1) {
    //       // 1st half
    //       // half_time ---> M
    //       print('half_time ---> M');
    //       half_or_full = 'H';
    //       half_time = 'M';

    //       // --------------------------------------------
    //       print('userid :- $empNo');
    //       print('startdate :- $startdate');
    //       print('enddate :- $enddate');
    //       print('leavetype :- $IndexOfSelectedDropDownItem');
    //       print('reason :- $reason');
    //       print('date :- $date');
    //       print('half_or_full :- $half_or_full');
    //       print('half_time :- $half_time');
    //       // --------------------------------------------
    //     } else if (WhichLeavetype == 2) {
    //       // 2nd half
    //       // half_time ---> A
    //       print('half_time ---> A');
    //       half_or_full = 'H';
    //       half_time = 'A';

    //       // --------------------------------------------
    //       print('userid :- $empNo');
    //       print('startdate :- $startdate');
    //       print('enddate :- $enddate');
    //       print('leavetype :- $IndexOfSelectedDropDownItem');
    //       print('reason :- $reason');
    //       print('date :- $date');
    //       print('half_or_full :- $half_or_full');
    //       print('half_time :- $half_time');
    //       // --------------------------------------------
    //     }
    //   }
    // } else {
    //   WhichLeavetype = 0;
    //   // nomal
    //   /// half_or_full ---> F
    //   print('half_or_full ---> F');
    //   half_or_full = 'F';

    //   // --------------------------------------------
    //   print('userid :- $empNo');
    //   print('startdate :- $startdate');
    //   print('enddate :- $enddate');
    //   print('leavetype :- $IndexOfSelectedDropDownItem');
    //   print('reason :- $reason');
    //   print('date :- $date');
    //   print('half_or_full :- $half_or_full');
    //   print('half_time :- $half_time');
    //   // --------------------------------------------
    // }

    print('userid :- $empNo');
    print('startdate :- $startdate');
    print('enddate :- $enddate');
    print('leavetype :- $IndexOfSelectedDropDownItem');
    print('reason :- $reason');
    print('date :- $date');
    print('half_or_full :- $half_or_full');
    print('half_time :- $half_time');
  }
}



  // helpPrint() {
  //   // print check box value
  //   // print('check box val ---> $isHalfDay');
  //   // // print radio value
  //   // print('radio val ---> $selectedRadio');

  //   // // clear check box
  //   // isHalfDay = false;
  //   // // clear radio btns
  //   // selectedRadio = 0;
  //   // _halfTypeEnum = null;

  //   // full day - date from + 00.00 To date to + 23.59  ---------------------- leaveDetails = '$startdate + 00.00 To $enddate + 23.59'; ${pickedDateFrom.year} / ${pickedDateFrom.month} / ${pickedDateFrom.day}
  //   // half 1st - date from + 00.00 To date to + 12.30  ---------------------- leaveDetails = '$startdate + 00.00 To $enddate + 12.30';
  //   // half 2nd - date from + 12.30 To date to + 00.00  ---------------------- leaveDetails = '$startdate + 12.30 To $enddate + 00.00'; ${pickedDateTo.year} / ${pickedDateTo.month} / ${pickedDateTo.day}

  //   if (isHalfDay) {
  //     if (selectedRadio == 1) {
  //       //leaveDetails = '$startdate + 00.00 To $enddate + 12.30';
  //       leaveDetails =
  //           '${pickedDateFrom.year}-${pickedDateFrom.month}-${pickedDateFrom.day} + 00.00 To ${pickedDateTo.year}-${pickedDateTo.month}-${pickedDateTo.day} + 12.30';
  //     } else if (selectedRadio == 2) {
  //       //leaveDetails = ' + 12.30 To $enddate + 00.00';
  //       leaveDetails =
  //           '${pickedDateFrom.year}-${pickedDateFrom.month}-${pickedDateFrom.day} + 12.30 To ${pickedDateTo.year}-${pickedDateTo.month}-${pickedDateTo.day} + 23.59';
  //     }
  //   } else {
  //     //leaveDetails = '$startdate + 00.00 To $enddate + 23.59';
  //     leaveDetails =
  //         '${pickedDateFrom.year}-${pickedDateFrom.month}-${pickedDateFrom.day} + 00.00 To ${pickedDateTo.year}-${pickedDateTo.month}-${pickedDateTo.day} + 23.59';
  //   }

  //   print(leaveDetails);

  //   setState(() {});
  // }
  

