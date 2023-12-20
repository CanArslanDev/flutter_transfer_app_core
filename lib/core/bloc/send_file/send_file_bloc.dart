import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file/download_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file/download_file_utils.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/download_status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_uploading_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_utils.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/latest_connections_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/http_service.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

class FirebaseSendFileBloc extends Cubit<FirebaseSendFileModel> {
  FirebaseSendFileBloc()
      : super(
          FirebaseSendFileModel(
            receiverID: '',
            receiverUsername: '',
            senderID: '',
            senderUsename: '',
            firebaseDocumentName: '',
            filesCount: 0,
            sendSpeed: '0',
            filesList: [],
            downloadFilesList: [],
            status: FirebaseSendFileRequestEnum.stable,
            errorMessage: '',
            uploadingStatus: FirebaseSendFileUploadingEnum.stable,
            fileTotalSpaceAsKB: 0,
            fileNowSpaceAsKB: 0,
            dateTime: Timestamp.fromDate(DateTime.now()), //for a tenporary
          ),
        );

  final sendFileUtils = FirebaseSendFileUtils();

  void setConnection(
    String receiverID,
    String receiverUsername,
    String senderID,
    String senderUsename,
  ) {
    emit(
      state.copyWith(
        receiverID: receiverID,
        receiverUsername: receiverUsername,
        senderID: senderID,
        senderUsename: senderUsename,
        firebaseDocumentName: '$senderID-$receiverID',
      ),
    );
  }

  bool ifConnectionExist() {
    return state.senderID != '' && state.receiverID != '';
  }

  void downloadFilesInFilesList() {
    FirebaseDownloadFileUtils().downloadFilesInFilesList(
        state.filesList, state.downloadFilesList, (downloadModel, fileModel) {
      state.downloadFilesList.add(downloadModel);
      downloadFile(fileModel.name, fileModel.path, fileModel.url,
          (downloadStatus, downloadPath) {
        if (downloadStatus != fileModel.downloadStatus) {
          downloadModel
            ..downloadStatus = downloadStatus
            ..downloadPath = downloadPath;
          changeDownloadFileInDownloadFilesList(downloadModel);
          unawaited(updateFirebaseDownloadFilesList());
        }
      });
    });
  }

  Future<void> updateDownloadFilesListAndFilesListInFirebase() async {
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .update({
      'downloadFilesList': firebaseDownloadFileModelListToMap(
        state.downloadFilesList,
      ),
      'filesList': firebaseFileModelListToMap(state.filesList),
    });
  }

  void changeDownloadFileInDownloadFilesList(FirebaseDownloadFileModel file) {
    final index = state.downloadFilesList
        .indexWhere((item) => item.path == file.path && item.name == file.name);
    state.downloadFilesList[index] = file;
  }

  Future<void> downloadFile(
    String fileName,
    String filePath,
    String fileUrl,
    void Function(
      FirebaseFileModelDownloadStatus downloadStatus,
      String downloadPath,
    ) downloadStatus,
  ) async {
    var downloadPathLocation = '';
    downloadStatus.call(
      FirebaseFileModelDownloadStatus.downloading,
      downloadPathLocation,
    );
    await HttpService().downloadFile(
      fileUrl,
      fileName,
      downloadPath: (downloadPath) => downloadPathLocation = downloadPath,
    );
    downloadStatus.call(
      FirebaseFileModelDownloadStatus.downloaded,
      downloadPathLocation,
    );
  }

  Future<void> listenConnection() async {
    final DocumentReference reference = FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName);
    reference.snapshots().listen(
      (querySnapshot) async {
        getFirebaseConnectionsCollection(querySnapshot);
        if (ifSenderIDEqualUserID) {
          changeFilesListFilesDownloadEnumAndUpdateFirebaseFilesList();
        } else {
          downloadFilesInFilesList();
        }
      },
    );
  }

  bool get ifSenderIDEqualUserID =>
      state.senderID ==
      BlocProvider.of<UserBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).getDeviceID();

  Future<void> setFirebaseConnectionsCollection() async {
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .set({
      'receiverID': state.receiverID,
      'receiverUsername': state.receiverUsername,
      'senderID': state.senderID,
      'senderUsename': state.senderUsename,
      'filesCount': 0,
      'sendSpeed': '0',
      'filesList': <Map<dynamic, dynamic>>{},
      'downloadFilesList': <Map<dynamic, dynamic>>{},
      'status': FirebaseSendFileRequestEnum.stable.index,
      'errorMessage': '',
      'uploadingStatus': FirebaseSendFileUploadingEnum.stable.index,
      'fileTotalSpaceAsKB': 0.0,
      'fileNowSpaceAsKB': 0.0,
      'dateTime': await FirebaseCore().getServerTimestamp(),
    });
  }

  Future<void> updateFirebaseConnectionsCollection() async {
    unawaited(sendLatestConnectionsToUserBloc());
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .update({
      'receiverID': state.receiverID,
      'receiverUsername': state.receiverUsername,
      'senderID': state.senderID,
      'senderUsename': state.senderUsename,
      'filesCount': state.filesList.length,
      'sendSpeed': '0',
      'filesList': firebaseFileModelListToMap(state.filesList),
      'downloadFilesList': firebaseDownloadFileModelListToMap(
        state.downloadFilesList,
      ),
      'status': FirebaseSendFileRequestEnum.stable.index,
      'errorMessage': '',
      'uploadingStatus': FirebaseSendFileUploadingEnum.stable.index,
      'fileTotalSpaceAsKB': state.fileTotalSpaceAsKB,
      'fileNowSpaceAsKB': state.fileNowSpaceAsKB,
      'dateTime': state.dateTime,
    });
  }

  Future<void> sendLatestConnectionsToUserBloc() async {
    BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).listUnionLatestConnectionsInState(
      UserLatestConnectionsModel(
        receiverID: state.receiverID,
        receiverUsername: state.receiverUsername,
        senderID: state.senderID,
        senderUsename: state.senderUsename,
        filesCount: state.filesList.length,
        filesList: state.filesList,
        fileTotalSpaceAsKB: state.fileTotalSpaceAsKB,
        dateTime: state.dateTime,
      ),
    );
    await BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).sendFirebaseLatestConnectionsList();
  }

  Future<void> updateFirebaseDownloadFilesList() async {
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .update({
      'downloadFilesList': firebaseDownloadFileModelListToMap(
        state.downloadFilesList,
      ),
    });
  }

  Future<void> updateFirebaseFilesList() async {
    // unawaited(sendLatestConnectionsToUserBloc());
    await FirebaseFirestore.instance
        .collection('connections')
        .doc(state.firebaseDocumentName)
        .update({
      'filesList': firebaseFileModelListToMap(state.filesList),
    });
  }

  void getFirebaseConnectionsCollection(
    DocumentSnapshot<Object?> querySnapshot,
  ) {
    final mapState = querySnapshot.data()! as Map<dynamic, dynamic>;
    mapState['firebaseDocumentName'] = state.firebaseDocumentName;
    final newState = firebaseSendFileModelFromMap(mapState);
    if (ifSenderIDEqualUserID) {
      newState.filesList = sendFileUtils.changeFilesDownloadStatusThePrevious(
        newState.filesList,
        state.filesList,
      );
    }
    emit(
      state.copyWith(
        receiverID: newState.receiverID,
        receiverUsername: newState.receiverUsername,
        senderID: newState.senderID,
        senderUsename: newState.senderUsename,
        firebaseDocumentName: newState.firebaseDocumentName,
        filesCount: newState.filesCount,
        sendSpeed: newState.sendSpeed,
        filesList: newState.filesList,
        downloadFilesList: newState.downloadFilesList,
        status: FirebaseSendFileRequestEnum.values[newState.status.index],
        errorMessage: newState.errorMessage,
        uploadingStatus: FirebaseSendFileUploadingEnum
            .values[newState.uploadingStatus.index],
        fileTotalSpaceAsKB: newState.fileTotalSpaceAsKB,
        fileNowSpaceAsKB: newState.fileNowSpaceAsKB,
        dateTime: newState.dateTime,
      ),
    );
  }

  void changeFilesListFilesDownloadEnumAndUpdateFirebaseFilesList() {
    sendFileUtils.changeFilesListFilesDownloadEnumAndUpdateFirebaseFilesList(
        state.filesList, state.downloadFilesList, updateFirebaseFilesList,
        (filesList) {
      emit(state.copyWith(filesList: filesList));
    });
  }

  Future<bool> sendConnectRequest(
    String userID,
  ) async {
    final checkUserIDBool =
        await sendFileUtils.checkUserID(userID, (requestEnum, errorMessage) {
      emit(
        state.copyWith(
          status: requestEnum,
          errorMessage: errorMessage,
        ),
      );
    });
    if (checkUserIDBool == false) {
      return false;
    }
    setStatus(FirebaseSendFileRequestEnum.connecting);
    await setUserSendFileRequest(userID);
    setStatus(FirebaseSendFileRequestEnum.sendedRequest);
    return true;
  }

  Future<void> setUserSendFileRequest(String userID) async {
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
  }

  void calculateTotalAndNowSpacesInFileList() {
    sendFileUtils.calculateTotalAndNowSpacesInFileList(
        state.fileTotalSpaceAsKB, state.fileNowSpaceAsKB, state.filesList,
        (fileTotalSpaceAsKB, fileNowSpaceAsKB) {
      emit(
        state.copyWith(
          fileTotalSpaceAsKB: fileTotalSpaceAsKB,
          fileNowSpaceAsKB: fileNowSpaceAsKB,
        ),
      );
    });
  }

  Future<void> setFilesListAndPushFirebase(
    List<FirebaseFileModel> filesList,
  ) async {
    final newFilesList = filesList;
    if (ifSenderIDEqualUserID) {
      state.filesList = sendFileUtils.changeFilesDownloadStatusThePrevious(
        newFilesList,
        state.filesList,
      );
    }
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
