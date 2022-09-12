import 'package:device_information/device_information.dart';
import 'package:flutter/services.dart';

class DeviceInfo {
  late String platformVersion,
      imeiNo = '',
      modelName = '',
      manufacturer = '',
      deviceName = '',
      productName = '',
      cpuType = '',
      hardware = '';
  var apiLevel;

  getDeviceInfo() async {
    try {
      //platformVersion = await DeviceInformation.platformVersion;
      imeiNo = await DeviceInformation.deviceIMEINumber;
    } on PlatformException catch (e) {
      platformVersion = '${e.message}';
    }
    
  }


    Future<String?> getImeiNumber() async {
    try {
      imeiNo = await DeviceInformation.deviceIMEINumber;

      print('imi -----? $imeiNo');
      return imeiNo;
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
