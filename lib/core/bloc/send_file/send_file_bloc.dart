import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';
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
        firebaseDocumentName: '$senderID-$receiverID',
      ),
    );
  }

  Future<void> listenConnection() async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName);
    reference.snapshots().listen(getFirebaseConnectionsCollection);
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
      'filesList': List,
      'status': FirebaseSendFileRequestEnum.stable.index,
      'errorMessage': '',
      'uploadingStatus': FirebaseSendFileUploadingEnum.stable.index,
      'fileTotalSpaceAsKB': 0.0,
      'fileNowSpaceAsKB': 0.0,
    });
  }

  Future<void> updateFirebaseConnectionsCollection() async {
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .update({
      'receiverID': state.receiverID,
      'senderID': state.senderID,
      'filesCount': 0,
      'sendSpeed': '0',
      'filesList': filesListToMap(state.filesList),
      'status': FirebaseSendFileRequestEnum.stable.index,
      'errorMessage': '',
      'uploadingStatus': FirebaseSendFileUploadingEnum.stable.index,
      'fileTotalSpaceAsKB': 0.0,
      'fileNowSpaceAsKB': 0.0,
    });
  }

  Future<void> getFirebaseConnectionsCollection(
    DocumentSnapshot<Object?> querySnapshot,
  ) async {
    final connection = querySnapshot.data()! as Map<dynamic, dynamic>;
    emit(
      state.copyWith(
        receiverID: connection['receiverID'] as String,
        senderID: connection['senderID'] as String,
        filesCount: connection['filesCount'] as int,
        sendSpeed: connection['sendSpeed'] as String,
        filesList: filesListFromMap(
          connection['filesList'] as List<dynamic>,
        ),
        status: FirebaseSendFileRequestEnum.values[connection['status'] as int],
        errorMessage: connection['errorMessage'] as String,
        uploadingStatus: FirebaseSendFileUploadingEnum
            .values[connection['uploadingStatus'] as int],
        fileTotalSpaceAsKB:
            double.parse(connection['fileTotalSpaceAsKB'].toString()),
        fileNowSpaceAsKB:
            double.parse(connection['fileNowSpaceAsKB'].toString()),
      ),
    );
  }

  List<Map<dynamic, dynamic>> filesListToMap(
      List<FirebaseFileModel> filesList) {
    final filesListMap = <Map<dynamic, dynamic>>[];
    for (final file in filesList) {
      filesListMap.add(file.toMap());
    }
    return filesListMap;
  }

  List<FirebaseFileModel> filesListFromMap(List<dynamic> filesListMap) {
    final filesList = <FirebaseFileModel>[];
    for (final file in filesListMap) {
      filesList.add(firebaseFileModelFromMap(file as Map<dynamic, dynamic>));
    }
    return filesList;
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

  Future<void> setFilesListAndPushFirebase(
    List<FirebaseFileModel> filesList,
  ) async {
    state.filesList = filesList;
    await updateFirebaseConnectionsCollection();
  }

  FirebaseSendFileModel getModel() {
    return state;
  }

  List<dynamic> getFilesList() {
    return state.filesList;
  }

  void setFilesList(List<FirebaseFileModel> filesList) {
    emit(state.copyWith(filesList: filesList));
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

  String getConnectionCollectionFirebaseDocumentName() {
    return state.firebaseDocumentName;
  }
}
