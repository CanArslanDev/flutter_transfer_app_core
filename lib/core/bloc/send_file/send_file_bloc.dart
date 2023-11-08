import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_uploading_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';

class FirebaseSendFileBloc extends Cubit<FirebaseSendFileModel> {
  FirebaseSendFileBloc()
      : super(
          FirebaseSendFileModel(
            userID: '',
            status: FirebaseSendFileRequestEnum.stable,
            errorMessage: '',
            uploadingStatus: FirebaseSendFileUploadingEnum.stable,
            fileTotalSpaceAsKB: 0,
            fileNowSpaceAsKB: 0,
            userDetails: {},
          ),
        );

  Future<bool> sendConnectRequest(
    String userID,
  ) async {
    if (userID.isEmpty) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'User ID is empty',
        ),
      );
      return false;
    }
    setStatus(FirebaseSendFileRequestEnum.connecting);
    final checkUserID =
        await FirebaseCore().checkUserIDForIdsCollection(userID);
    if (checkUserID == false) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'User ID not found',
        ),
      );
      return false;
    }
    setStatus(FirebaseSendFileRequestEnum.sendedRequest);
    return true;
  }

  void getModel() {
    emit(state);
  }

  void setStatus(FirebaseSendFileRequestEnum status) {
    emit(state.copyWith(status: status));
  }

  void setErrorMessage(String errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }

  FirebaseSendFileRequestEnum getStatus() {
    return state.status;
  }
}
