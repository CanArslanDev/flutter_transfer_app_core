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
            firebaseDocumentName: '',
            filesCount: 0,
            sendSpeed: '0',
            filesList: [],
            status: FirebaseSendFileRequestEnum.stable,
            errorMessage: '',
            uploadingStatus: FirebaseSendFileUploadingEnum.stable,
            fileTotalSpaceAsKB: 0,
            fileNowSpaceAsKB: 0,
            userDetails: {},
          ),
        );

  void setConnection(
    String receiverID,
    String senderID,
    Map<String, String> userDetails,
  ) {
    emit(
      state.copyWith(
          receiverID: receiverID,
          senderID: senderID,
          userDetails: userDetails,
          firebaseDocumentName: '$senderID-$receiverID'),
    );
  }

  Future<void> listenConnection() async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName);
    reference.snapshots().listen((querySnapshot) {
      getFirebaseConnectionsCollection(querySnapshot);
    });
  }

  Future<void> setFirebaseConnectionsCollection() async {
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .set({
      'receiverID': state.receiverID,
      'senderID': state.senderID,
      'filesCount': 0,
      'sendSpeed': '0',
      'filesList': <Map<dynamic, dynamic>>{},
      'status': firebaseSendFileRequestEnumToInt(
        FirebaseSendFileRequestEnum.stable,
      ),
      'errorMessage': '',
      'uploadingStatus': firebaseSendFileUploadingEnumToInt(
        FirebaseSendFileUploadingEnum.stable,
      ),
      'fileTotalSpaceAsKB': 0.0,
      'fileNowSpaceAsKB': 0.0,
    });
  }

  Future<void> getFirebaseConnectionsCollection(
      DocumentSnapshot<Object?> querySnapshot) async {
    final connection = querySnapshot.data()! as Map<dynamic, dynamic>;
    print("1");
    emit(
      state.copyWith(
        receiverID: connection['receiverID'] as String,
        senderID: connection['senderID'] as String,
        filesCount: connection['filesCount'] as int,
        sendSpeed: connection['sendSpeed'] as String,
        filesList: connection['filesList'] as List<dynamic>,
        status: intToFirebaseSendFileRequestEnum(
          connection['status'] as int,
        ),
        errorMessage: connection['errorMessage'] as String,
        uploadingStatus: intToFirebaseSendFileUploadingEnum(
          connection['uploadingStatus'] as int,
        ),
        fileTotalSpaceAsKB:
            double.parse(connection['fileTotalSpaceAsKB'].toString()),
        fileNowSpaceAsKB:
            double.parse(connection['fileNowSpaceAsKB'].toString()),
      ),
    );
  }

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

  int firebaseSendFileUploadingEnumToInt(
    FirebaseSendFileUploadingEnum enumData,
  ) {
    switch (enumData) {
      case FirebaseSendFileUploadingEnum.uploading:
        return 0;
      case FirebaseSendFileUploadingEnum.uploadingSuccess:
        return 1;
      case FirebaseSendFileUploadingEnum.uploadingFailure:
        return 2;
      case FirebaseSendFileUploadingEnum.uploadingCanceled:
        return 3;
      case FirebaseSendFileUploadingEnum.error:
        return 4;
      case FirebaseSendFileUploadingEnum.stable:
        return 5;
    }
  }

  FirebaseSendFileUploadingEnum intToFirebaseSendFileUploadingEnum(
    int enumData,
  ) {
    switch (enumData) {
      case 0:
        return FirebaseSendFileUploadingEnum.uploading;
      case 1:
        return FirebaseSendFileUploadingEnum.uploadingSuccess;
      case 2:
        return FirebaseSendFileUploadingEnum.uploadingFailure;
      case 3:
        return FirebaseSendFileUploadingEnum.uploadingCanceled;
      case 4:
        return FirebaseSendFileUploadingEnum.error;
      case 5:
        return FirebaseSendFileUploadingEnum.stable;
    }
    return FirebaseSendFileUploadingEnum.stable;
  }

  int firebaseSendFileRequestEnumToInt(FirebaseSendFileRequestEnum enumData) {
    switch (enumData) {
      case FirebaseSendFileRequestEnum.stable:
        return 0;
      case FirebaseSendFileRequestEnum.connecting:
        return 1;
      case FirebaseSendFileRequestEnum.sendedRequest:
        return 2;
      case FirebaseSendFileRequestEnum.error:
        return 3;
      case FirebaseSendFileRequestEnum.connected:
        return 4;
    }
  }

  FirebaseSendFileRequestEnum intToFirebaseSendFileRequestEnum(int enumData) {
    switch (enumData) {
      case 0:
        return FirebaseSendFileRequestEnum.stable;
      case 1:
        return FirebaseSendFileRequestEnum.connecting;
      case 2:
        return FirebaseSendFileRequestEnum.sendedRequest;
      case 3:
        return FirebaseSendFileRequestEnum.error;
      case 4:
        return FirebaseSendFileRequestEnum.connected;
    }
    return FirebaseSendFileRequestEnum.stable;
  }
}
