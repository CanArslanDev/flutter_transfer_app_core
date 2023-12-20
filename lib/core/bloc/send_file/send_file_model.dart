import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file/download_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_uploading_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';

class FirebaseSendFileModel {
  FirebaseSendFileModel({
    required this.receiverID,
    required this.receiverUsername,
    required this.senderID,
    required this.senderUsename,
    required this.firebaseDocumentName,
    required this.filesCount,
    required this.sendSpeed,
    required this.filesList,
    required this.downloadFilesList,
    required this.status,
    required this.errorMessage,
    required this.uploadingStatus,
    required this.fileTotalSpaceAsKB,
    required this.fileNowSpaceAsKB,
    required this.dateTime,
  });
  String receiverID;
  String receiverUsername;
  String senderID;
  String senderUsename;
  String firebaseDocumentName;
  int filesCount;
  String sendSpeed;
  List<FirebaseFileModel> filesList;
  List<FirebaseDownloadFileModel> downloadFilesList;
  String errorMessage;
  FirebaseSendFileRequestEnum status;
  FirebaseSendFileUploadingEnum uploadingStatus;
  double fileTotalSpaceAsKB;
  double fileNowSpaceAsKB;
  Timestamp dateTime;

  FirebaseSendFileModel copyWith({
    String? receiverID,
    String? receiverUsername,
    String? senderID,
    String? senderUsename,
    String? firebaseDocumentName,
    int? filesCount,
    String? sendSpeed,
    List<FirebaseFileModel>? filesList,
    List<FirebaseDownloadFileModel>? downloadFilesList,
    FirebaseSendFileRequestEnum? status,
    String? errorMessage,
    FirebaseSendFileUploadingEnum? uploadingStatus,
    double? fileTotalSpaceAsKB,
    double? fileNowSpaceAsKB,
    Timestamp? dateTime,
  }) {
    return FirebaseSendFileModel(
      receiverID: receiverID ?? this.receiverID,
      receiverUsername: receiverUsername ?? this.receiverUsername,
      senderID: senderID ?? this.senderID,
      senderUsename: senderUsename ?? this.senderUsename,
      firebaseDocumentName: firebaseDocumentName ?? this.firebaseDocumentName,
      filesCount: filesCount ?? this.filesCount,
      sendSpeed: sendSpeed ?? this.sendSpeed,
      filesList: filesList ?? this.filesList,
      downloadFilesList: downloadFilesList ?? this.downloadFilesList,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadingStatus: uploadingStatus ?? this.uploadingStatus,
      fileTotalSpaceAsKB: fileTotalSpaceAsKB ?? this.fileTotalSpaceAsKB,
      fileNowSpaceAsKB: fileNowSpaceAsKB ?? this.fileNowSpaceAsKB,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}

FirebaseSendFileModel firebaseSendFileModelFromMap(
  Map<dynamic, dynamic> model,
) {
  return FirebaseSendFileModel(
    receiverID: model['receiverID'] as String,
    receiverUsername: model['receiverUsername'] as String,
    senderID: model['senderID'] as String,
    senderUsename: model['senderUsename'] as String,
    firebaseDocumentName: model['firebaseDocumentName'] as String,
    filesCount: model['filesCount'] as int,
    sendSpeed: model['sendSpeed'] as String,
    filesList: firebaseFileModelListFromMap(
      model['filesList'] as List<dynamic>,
    ),
    downloadFilesList: firebaseDownloadFileModelListFromMap(
      model['downloadFilesList'] as List<dynamic>,
    ),
    status: FirebaseSendFileRequestEnum.values[model['status'] as int],
    errorMessage: model['errorMessage'] as String,
    uploadingStatus:
        FirebaseSendFileUploadingEnum.values[model['uploadingStatus'] as int],
    fileTotalSpaceAsKB: double.parse(model['fileTotalSpaceAsKB'].toString()),
    fileNowSpaceAsKB: double.parse(model['fileNowSpaceAsKB'].toString()),
    dateTime: model['dateTime'] as Timestamp,
  );
}
