import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.deviceID,
    required this.userPlatformDetails,
    required this.expiration,
    required this.availableCloudStorageMB,
  });
  String deviceID;
  Map<String, dynamic> userPlatformDetails;
  Timestamp expiration;
  int availableCloudStorageMB;

  UserModel copyWith({
    String? deviceID,
    Map<String, dynamic>? userPlatformDetails,
    Timestamp? expiration,
    int? availableCloudStorageMB,
  }) {
    return UserModel(
      deviceID: deviceID ?? this.deviceID,
      userPlatformDetails: userPlatformDetails ?? this.userPlatformDetails,
      expiration: expiration ?? this.expiration,
      availableCloudStorageMB:
          availableCloudStorageMB ?? this.availableCloudStorageMB,
    );
  }
}
