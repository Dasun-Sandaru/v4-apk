class LoginData {

  late final String badgenumber;
  late final String password;
  late final String ip;
  late final String imei_no;

  LoginData({
    required this.badgenumber,
    required this.password,
    required this.ip,
    required this.imei_no,
  });

  factory LoginData.fromJson(Map<String,dynamic> logindata){
    return LoginData(
      badgenumber: logindata['badgenumber'], 
      password: logindata['password'], 
      ip: logindata['ip'], 
      imei_no: logindata['imei_no'],
    );
  }


  Map<String,dynamic> toJson(){
    final Map<String,dynamic> loginData = Map <String,dynamic>();
    loginData['badgenumber'] = badgenumber;
    loginData['password'] = password;
    loginData['ip'] = ip;
    loginData['imei_no'] = imei_no;

    return loginData;
  }
}

class LoginResponse{

    //Data data;
    late final String message;
    late final bool success;
    var token;
    String userName;

    LoginResponse({
      required this.message,
      required this.success,
      required this.userName,
      this.token,
    });

    factory LoginResponse.fromJson(Map<String,dynamic> loginData){
      return LoginResponse(
        
        token : loginData['data']['token'],
        userName : loginData['data']['name'],
        message: loginData['message'], 
        success: loginData['success'],
      );
    }

}
