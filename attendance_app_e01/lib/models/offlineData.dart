class OfflineData {
  late int id;
  late String userid;
  late String geo_location;
  late String longitude;
  late String latitude;
  late String outlet_name;
  late String execution_type;
  late String remarks;
  String? image1;
  String? image2;
  String? image3;
  String? image4;
  String? image5;

  OfflineData({
    required this.id,
    required this.userid,
    required this.geo_location,
    required this.longitude,
    required this.latitude,
    required this.outlet_name,
    required this.execution_type,
    required this.remarks,
    this.image1,
    this.image2,
    this.image3,
    this.image4,
    this.image5,
  });

  // factory OfflineData.fromJson(Map<String,dynamic> json){
  //   userid
  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> offlineData = Map<String, dynamic>();

    offlineData['id'] = id;
    offlineData['userid'] = userid;
    offlineData['geo_location'] = geo_location;
    offlineData['longitude'] = longitude;
    offlineData['latitude'] = latitude;
    offlineData['outlet_name'] = outlet_name;
    offlineData['execution_type'] = execution_type;
    offlineData['remarks'] = remarks;
    offlineData['image1'] = image1;
    offlineData['image2'] = image2;
    offlineData['image3'] = image3;
    offlineData['image4'] = image4;
    offlineData['image5'] = image5;

    return offlineData;
  }

  factory OfflineData.fromJson(Map<String, dynamic> offlinedata) {
    return OfflineData(
      //token : offlinedata['token'],
      id: offlinedata['id'],
      userid: offlinedata['userid'],
      geo_location: offlinedata['geo_location'],
      longitude: offlinedata['longitude'],
      latitude: offlinedata['latitude'],
      outlet_name: offlinedata['outlet_name'],
      execution_type: offlinedata['execution_type'],
      remarks: offlinedata['remarks'],
      image1: offlinedata['image1'],
      image2: offlinedata['image2'],
      image3: offlinedata['image3'],
      image4: offlinedata['image4'],
      image5: offlinedata['image5'],
    );
  }
}
