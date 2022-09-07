import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/drop down/drowdowntypes.dart';


class SharedPref {

  List<List<DropDownTypes>> list = [];
  
  // store emp Name,No in phone Db
  Future<void> saveEmpIdName(String empNo, String empName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('EmpId', empNo);
    pref.setString('EmpName', empName);

    print('Emp ID & Emp Name Store In Local Db');
  }


  // store token in phone Db
  Future<void> saveToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('Token', token);
    print('Token Store In Local Db');
  }

  // up token in phone Db
  Future<void> upToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('Token','logout');
    print('Token Store In Local Db');
  }


  // read emp No in phone Db
  Future<String?> readEmpId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? empNo = pref.getString('EmpId');
    print('Emp ID In Local Db : ${empNo}');
    return empNo;

  }


  // read token
  Future <String?> readToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('Token');
    print('Token ID In Local Db : ${token}');
    return token;
  }

  // read token
  Future <String?> readTokenForLoginStatus() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('Token') ?? '';
    print('Token ID In Local Db : ${token}');
    return token;
  }

  // read emp Name in phone Db
  Future<String?> readEmpName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? empName = pref.getString('EmpName');
    print('Emp Name Read In Local Db : ${empName}');
    return empName;
    
  }

  // remove saved token
  Future<void> removeToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('Token') != null) {
      pref.remove('Token');
    }

    print('Token Removed');
  }

  // helper for offline img upload

  // read has user offline info in phone Db
  Future<bool?> readOfflineInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? hasInfo = pref.getBool('offlineData');
    print('User has offline info : ${hasInfo}');
    return hasInfo;
  }

//   // store market execution types in phone Db
//   Future<void> saveMarketExecutionTypes(List<DropDownTypes> exeList) async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     //pref.set('MarketExecutionTypes',exeList);
//     pref.setString('MarketExecutionTypes',jsonEncode(exeList));
//     print('MarketExecutionTypes Store In Local Db');
//   }

// // read execution types in phone Db
//   Future<Map> readMarketExecutionTypes() async {
//     SharedPreferences pref = await SharedPreferences.getInstance();
//     //print('MarketExecutionTypes Read In Local Db :');

//     print('wedsa');
//     print(json.decode(pref.getString('MarketExecutionTypes')!));
//     return json.decode(pref.getString('MarketExecutionTypes')!);
//   }

  
}