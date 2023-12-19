import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_uploading_enum.dart';

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
    );
  }
}
