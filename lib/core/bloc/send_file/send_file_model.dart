import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_uploading_enum.dart';

class FirebaseSendFileModel {
  FirebaseSendFileModel({
    required this.receiverID,
    required this.senderID,
    required this.filesCount,
    required this.sendSpeed,
    required this.filesList,
    required this.status,
    required this.errorMessage,
    required this.uploadingStatus,
    required this.fileTotalSpaceAsKB,
    required this.fileNowSpaceAsKB,
    required this.userDetails,
  });
  String receiverID;
  String senderID;
  int filesCount;
  String sendSpeed;
  Map<dynamic, dynamic> filesList;
  String errorMessage;
  FirebaseSendFileRequestEnum status;
  FirebaseSendFileUploadingEnum uploadingStatus;
  double fileTotalSpaceAsKB;
  double fileNowSpaceAsKB;
  Map<String, String> userDetails;

  FirebaseSendFileModel copyWith({
    String? receiverID,
    String? senderID,
    int? filesCount,
    String? sendSpeed,
    Map<dynamic, dynamic>? filesList,
    FirebaseSendFileRequestEnum? status,
    String? errorMessage,
    FirebaseSendFileUploadingEnum? uploadingStatus,
    double? fileTotalSpaceAsKB,
    double? fileNowSpaceAsKB,
    Map<String, String>? userDetails,
  }) {
    return FirebaseSendFileModel(
      receiverID: receiverID ?? this.receiverID,
      senderID: senderID ?? this.senderID,
      filesCount: filesCount ?? this.filesCount,
      sendSpeed: sendSpeed ?? this.sendSpeed,
      filesList: filesList ?? this.filesList,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadingStatus: uploadingStatus ?? this.uploadingStatus,
      fileTotalSpaceAsKB: fileTotalSpaceAsKB ?? this.fileTotalSpaceAsKB,
      fileNowSpaceAsKB: fileNowSpaceAsKB ?? this.fileNowSpaceAsKB,
      userDetails: userDetails ?? this.userDetails,
    );
  }
}
