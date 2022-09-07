import 'package:location/location.dart';

class OnLocation {
  Location location = Location();

  // enable location
  Future<bool> enableLocation() async {
    late bool isOn;

    try {
      isOn = await location.serviceEnabled();

      if (!isOn) {
        //if defvice is off
        bool isturnedon = await location.requestService();

        return isOn;

        // if (isturnedon) {
        //   print("GPS device is turned ON");
        // } else {
        //   print("GPS Device is still OFF");
        //   //isOn = false;
        // }
      }
    } catch (e) {
      print(e.toString());
    }

    return isOn;
  }
}
