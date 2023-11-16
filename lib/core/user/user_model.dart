import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.deviceID,
    required this.userPlatformDetails,
    required this.expiration,
    required this.availableCloudStorageMB,
    required this.token,
    required this.connectionRequest,
  });
  String deviceID;
  Map<String, dynamic> userPlatformDetails;
  Timestamp expiration;
  double availableCloudStorageMB;
  String token;
  List<dynamic> connectionRequest;

  UserModel copyWith(
      {String? deviceID,
      Map<String, dynamic>? userPlatformDetails,
      Timestamp? expiration,
      double? availableCloudStorageMB,
      String? token,
      List<dynamic>? connectionRequest}) {
    return UserModel(
      deviceID: deviceID ?? this.deviceID,
      userPlatformDetails: userPlatformDetails ?? this.userPlatformDetails,
      expiration: expiration ?? this.expiration,
      availableCloudStorageMB:
          availableCloudStorageMB ?? this.availableCloudStorageMB,
      token: token ?? this.token,
      connectionRequest: connectionRequest ?? this.connectionRequest,
    );
  }
}
