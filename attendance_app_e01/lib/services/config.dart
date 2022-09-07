class Config{
  static const BACKEND_URL = String.fromEnvironment('BACKEND_URL',
    defaultValue: 'http://app.vblsl.com/api.mobile/api/');

  static const InstructionWebPage = 'http://app.vblsl.com/api.mobile/app_instructions.html';

  // static const InstructionWebPage = 'http://sfitcrm.cyberdev.tk/';

  // static Map<String,dynamic> header(){
  //   final Map<String,dynamic> header = Map <String,dynamic>();
  //   header['Content-Type'] = "application//json";
  //   header['Accept'] = application/json;
  //   header['Authorization'] = 'Bearer $token';
  //   return header;
  // }

}
