import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';

class UserLatestConnectionsModel {
  UserLatestConnectionsModel({
    required this.receiverID,
    required this.receiverUsername,
    required this.senderID,
    required this.senderUsename,
    required this.filesCount,
    required this.filesList,
    required this.fileTotalSpaceAsKB,
    required this.dateTime,
  });
  String receiverID;
  String receiverUsername;
  String senderID;
  String senderUsename;
  int filesCount;
  List<FirebaseFileModel> filesList;
  double fileTotalSpaceAsKB;
  Timestamp dateTime;

  Map<String, dynamic> toMap() {
    return {
      'receiverID': receiverID,
      'receiverUsername': receiverUsername,
      'senderID': senderID,
      'senderUsename': senderUsename,
      'filesCount': filesCount,
      'filesList': firebaseFileModelListToMap(filesList),
      'fileTotalSpaceAsKB': fileTotalSpaceAsKB,
      'dateTime': dateTime,
    };
  }
}

UserLatestConnectionsModel userLatestConnectionsModelFromMap(
  Map<dynamic, dynamic> map,
) {
  return UserLatestConnectionsModel(
    receiverID: map['receiverID'] as String,
    receiverUsername: map['receiverUsername'] as String,
    senderID: map['senderID'] as String,
    senderUsename: map['senderUsename'] as String,
    filesCount: map['filesCount'] as int,
    filesList: firebaseFileModelListFromMap(map['filesList'] as List<dynamic>),
    fileTotalSpaceAsKB: map['fileTotalSpaceAsKB'] as double,
    dateTime: map['dateTime'] as Timestamp,
  );
}
