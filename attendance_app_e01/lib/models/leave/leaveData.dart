class LeaveData {
  late String userid;
  late String half_or_full; //----
  late String half_time; // ---
  late String startdate;
  late String enddate;
  late String leavetype;
  late String reason;
  late String date;

  LeaveData({
    required this.userid,
    required this.half_or_full,
    required this.half_time,
    required this.startdate,
    required this.enddate,
    required this.leavetype,
    required this.reason,
    required this.date,
  });

  factory LeaveData.fromJson(Map<String, dynamic> leavedata) {
    return LeaveData(
      userid: leavedata['userid'],
      half_or_full: leavedata['half_or_full'],
      half_time: leavedata['half_time'],
      startdate: leavedata['startdate'],
      enddate: leavedata['enddate'],
      leavetype: leavedata['leavetype'],
      reason: leavedata['reason'],
      date: leavedata['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> leaveData = Map<String, dynamic>();
    leaveData['userid'] = userid;
    leaveData['half_or_full'] = half_or_full;
    leaveData['half_time'] = half_time;
    leaveData['startdate'] = startdate;
    leaveData['enddate'] = enddate;
    leaveData['leavetype'] = leavetype;
    leaveData['reason'] = reason;
    leaveData['date'] = date;
    return leaveData;
  }
}

class LeaveResponse {
  late final String message;
  late final bool success;

  LeaveResponse({
    required this.message,
    required this.success,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> loginData) {
    return LeaveResponse(
      message: loginData['message'],
      success: loginData['success'],
    );
  }
}
