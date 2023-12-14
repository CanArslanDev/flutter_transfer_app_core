import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_uploading_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

class FirebaseSendFileBloc extends Cubit<FirebaseSendFileModel> {
  FirebaseSendFileBloc()
      : super(
          FirebaseSendFileModel(
            receiverID: '',
            senderID: '',
            filesCount: 0,
            sendSpeed: '',
            filesList: {},
            status: FirebaseSendFileRequestEnum.stable,
            errorMessage: '',
            uploadingStatus: FirebaseSendFileUploadingEnum.stable,
            fileTotalSpaceAsKB: 0,
            fileNowSpaceAsKB: 0,
            userDetails: {},
          ),
        );

  bool checkUserID(String userID) {
    if (userID.isEmpty) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'User ID is empty',
        ),
      );
      return false;
    } else if (BlocProvider.of<FirebaseCoreBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).getStatus() ==
        FirebaseCoreStatus.loading) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'Loading services, please wait and try again',
        ),
      );
      return false;
    } else if (BlocProvider.of<UserBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).getDeviceID() ==
        userID) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'You cannot send files to yourself',
        ),
      );
      return false;
    }
    return true;
  }

  Future<bool> sendConnectRequest(
    String userID,
  ) async {
    if (checkUserID(userID) == false) {
      return false;
    }
    setStatus(FirebaseSendFileRequestEnum.connecting);
    if (await FirebaseCore().checkUserIDForIdsCollection(userID) == false) {
      emit(
        state.copyWith(
          status: FirebaseSendFileRequestEnum.error,
          errorMessage: 'User ID not found',
        ),
      );
      return false;
    }
    final userToken =
        await FirebaseCoreSystem().getUserTokenFromUsersCollection(userID);
    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(userToken)
        .get();
    final userConnectionList = user['connectionRequest'] as List<dynamic>
      ..add({
        'connectionID': BlocProvider.of<UserBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).getDeviceID(),
        'username': BlocProvider.of<UserBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).getUsername(),
        'requestUserDeviceToken': BlocProvider.of<UserBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).getToken(),
      });
    await FirebaseFirestore.instance.collection('users').doc(userToken).update({
      'connectionRequest': userConnectionList,
    });
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
