import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';

class FirebaseSendFileModel {
  FirebaseSendFileModel({
    required this.userID,
    required this.status,
    required this.errorMessage,
  });
  String userID;
  String errorMessage;
  FirebaseSendFileRequestEnum status;

  FirebaseSendFileModel copyWith({
    String? userID,
    FirebaseSendFileRequestEnum? status,
    String? errorMessage,
  }) {
    return FirebaseSendFileModel(
      userID: userID ?? this.userID,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
