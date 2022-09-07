import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

import '../../services/config.dart';
import 'package:http/http.dart' as http;

class MarketResponse {
  late final String message;
  late final bool success;

  MarketResponse({
    required this.message,
    required this.success,
  });

  factory MarketResponse.fromJson(Map<String, dynamic> loginData) {
    return MarketResponse(
      message: loginData['message'],
      success: loginData['success'],
    );
  }
}

class SelfieImg {
  // empNo,_address,_longittude,_latitude,outletName,IndexOfSelectedDropDownItem,remarks

  bool isDone = false;

  Future<bool> Punch(String token,String userid,String geo_location,String longitude,String latitude,String outlet_name,String execution_type,String remarks,
      {File? image1,
      File? image2,
      File? image3,
      File? image4,
      File? image5
      }) async {
    print('Start FiveImaHelper clz - fiveImgUpload method'); //
    var requestimg = http.MultipartRequest(
        "POST", Uri.parse("${Config.BACKEND_URL}market-execution"));

    Map<String, String> headers = {
      'Content-type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };

    requestimg.headers.addAll(headers);
    requestimg.fields['userid'] = userid;
    requestimg.fields['geo_location'] = geo_location;
    requestimg.fields['longitude'] = longitude;
    requestimg.fields['latitude'] = latitude;
    requestimg.fields['outlet_name'] = outlet_name;
    requestimg.fields['execution_type'] = execution_type;
    requestimg.fields['remarks'] = remarks;
    // requestimg.fields['id'] = '1';

    // img add
    // 1 img
    if (image1?.path != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image1', image1!.path));
    }

    // 2 img
    if (image2?.path != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image2', image2!.path));
    }

    // 3 img
    if (image3?.path != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image3', image3!.path));
    }

    // 4 img
    if (image4?.path != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image4', image4!.path));
    }

    // 5 img
    if (image5?.path != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image5', image5!.path));
    }

    var res = await requestimg.send();
    print('Start FiveImaHelper clz - fiveImgUpload method -- send request');

    // String fileName0 = image1!.path;
    // print(fileName0);

    if (res.statusCode == 200) {
      final res_ = await http.Response.fromStream(res);
      final parsed = json.decode(res_.body);
      final imgresponse = MarketResponse.fromJson(parsed);
      if (imgresponse.success) {
        print('work'); // market data submit
        
        Fluttertoast.showToast(
          msg: imgresponse.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        return isDone = true;
      } else {
        print('erorr: Not Work'); // market data not submit
        Fluttertoast.showToast(
          msg: imgresponse.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return isDone = false;
      }
    } else {
      print(res.statusCode.toString());
      Fluttertoast.showToast(
          msg: res.statusCode.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return isDone = false;
    }
  }



  // --------------------------------------- offline snyc part ------------------------------------------

  bool offlineDataDone = false;


  Future<bool> PunchOfflineData(String token,String userid,String geo_location,String longitude,String latitude,String outlet_name,String execution_type,String remarks,
      {String? image1,
      String? image2,
      String? image3,
      String? image4,
      String? image5
      }) async {
    print('Start FiveImaHelper clz - fiveImgUpload method'); //
    var requestimg = http.MultipartRequest(
        "POST", Uri.parse("${Config.BACKEND_URL}market-execution"));

    Map<String, String> headers = {
      'Content-type': 'multipart/form-data',
      'Authorization': 'Bearer $token',
    };

    requestimg.headers.addAll(headers);
    requestimg.fields['userid'] = userid;
    requestimg.fields['geo_location'] = geo_location;
    requestimg.fields['longitude'] = longitude;
    requestimg.fields['latitude'] = latitude;
    requestimg.fields['outlet_name'] = outlet_name;
    requestimg.fields['execution_type'] = execution_type;
    requestimg.fields['remarks'] = remarks;
    // requestimg.fields['id'] = '1';

    // img add
    // 1 img
    if (image1 != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image1', image1));
    }

    // 2 img
    if (image2 != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image2', image2));
    }

    // 3 img
    if (image3 != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image3', image3));
    }

    // 4 img
    if (image4 != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image4', image4));
    }

    // 5 img
    if (image5 != null) {
      requestimg.files
          .add(await http.MultipartFile.fromPath('image5', image5));
    }

    var res = await requestimg.send();
    print('Start FiveImaHelper clz - fiveImgUpload method -- send request');

    // String fileName0 = image1!.path;
    // print(fileName0);

    if (res.statusCode == 200) {
      final res_ = await http.Response.fromStream(res);
      final parsed = json.decode(res_.body);
      final imgresponse = MarketResponse.fromJson(parsed);
      if (imgresponse.success) {
        print('submitted offline data'); // market data submit
        
        Fluttertoast.showToast(
          msg: imgresponse.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        return offlineDataDone = true;
      } else {
        print('erorr: Not submitted offline data'); // market data not submit
        Fluttertoast.showToast(
          msg: imgresponse.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return offlineDataDone = false;
      }
    } else {
      print(res.statusCode.toString());
      Fluttertoast.showToast(
          msg: res.statusCode.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        return offlineDataDone = false;
    }
  }

}
