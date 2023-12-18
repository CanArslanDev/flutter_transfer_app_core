import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  UserModel({
    required this.deviceID,
    required this.userPlatformDetails,
    required this.expiration,
    required this.availableCloudStorageMB,
    required this.token,
    required this.connectionRequest,
    required this.previousConnectionRequest,
    required this.latestSendedFilesList,
    required this.connectedUser,
    required this.username,
  });
  String deviceID;
  Map<String, dynamic> userPlatformDetails;
  Timestamp expiration;
  double availableCloudStorageMB;
  String token;
  List<Map<dynamic, dynamic>> connectionRequest;
  List<Map<dynamic, dynamic>> previousConnectionRequest;
  List<Map<dynamic, dynamic>> latestSendedFilesList;
  Map<dynamic, dynamic> connectedUser;
  String username;

  UserModel copyWith({
    String? deviceID,
    Map<String, dynamic>? userPlatformDetails,
    Timestamp? expiration,
    double? availableCloudStorageMB,
    String? token,
    List<Map<dynamic, dynamic>>? connectionRequest,
    List<Map<dynamic, dynamic>>? previousConnectionRequest,
    List<Map<dynamic, dynamic>>? latestSendedFilesList,
    Map<dynamic, dynamic>? connectedUser,
    String? username,
  }) {
    return UserModel(
      deviceID: deviceID ?? this.deviceID,
      userPlatformDetails: userPlatformDetails ?? this.userPlatformDetails,
      expiration: expiration ?? this.expiration,
      availableCloudStorageMB:
          availableCloudStorageMB ?? this.availableCloudStorageMB,
      token: token ?? this.token,
      connectionRequest: connectionRequest ?? this.connectionRequest,
      previousConnectionRequest:
          previousConnectionRequest ?? this.previousConnectionRequest,
      latestSendedFilesList:
          latestSendedFilesList ?? this.latestSendedFilesList,
      connectedUser: connectedUser ?? this.connectedUser,
      username: username ?? this.username,
    );
  }
}
