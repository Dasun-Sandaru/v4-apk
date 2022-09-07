class AttendanceData {
  late String userid;
  late String punchstatus;
  late String geo_location;
  late String longitude;
  late String latitude;

  AttendanceData({
    required this.userid,
    required this.punchstatus,
    required this.geo_location,
    required this.longitude,
    required this.latitude,
  });

  Map<String,dynamic> tojson(){
    final Map<String,dynamic> attendanceData = Map <String,dynamic>();
    attendanceData['userid'] = userid;
    attendanceData['punchstatus'] = punchstatus;
    attendanceData['geo_location'] = geo_location;
    attendanceData['longitude'] = longitude;
    attendanceData['latitude'] = latitude;

    return attendanceData;
  }

}


class AttendanceResponse{

    late final String message;
    late final bool success;

    AttendanceResponse({
      required this.message,
      required this.success,
    });

    factory AttendanceResponse.fromJson(Map<String,dynamic> loginData){
      return AttendanceResponse(
        message: loginData['message'], 
        success: loginData['success'],
      );
    }

}
