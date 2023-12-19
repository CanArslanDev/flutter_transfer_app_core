import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_uploading_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
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
          ),
        );

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
    final filesList = state.filesList;
    for (final file in filesList) {
      if (file.url == '') {
        return;
      }
      final index = state.downloadFilesList.indexWhere(
        (item) => item.path == file.path && item.name == file.name,
      );
      if (index == -1) {
        final fileModel = FirebaseDownloadFileModel(
          path: file.path,
          name: file.name,
          downloadStatus: FirebaseFileModelDownloadStatus.downloading,
        );
        state.downloadFilesList.add(fileModel);
        downloadFile(file.name, file.path, file.url, (downloadStatus) {
          fileModel.downloadStatus = downloadStatus;
          changeDownloadFileInDownloadFilesList(fileModel);
          unawaited(updateFirebaseDownloadFilesList());
        });
      }
    }
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
    void Function(FirebaseFileModelDownloadStatus downloadStatus)
        downloadStatus,
  ) async {
    downloadStatus.call(FirebaseFileModelDownloadStatus.downloading);
    await HttpService().downloadFile(fileUrl, fileName);
    downloadStatus.call(FirebaseFileModelDownloadStatus.downloaded);
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
    });
  }

  Future<void> updateFirebaseConnectionsCollection() async {
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
    });
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
    final connection = querySnapshot.data()! as Map<dynamic, dynamic>;
    emit(
      state.copyWith(
        receiverID: connection['receiverID'] as String,
        receiverUsername: connection['receiverUsername'] as String,
        senderID: connection['senderID'] as String,
        senderUsename: connection['senderUsename'] as String,
        filesCount: connection['filesCount'] as int,
        sendSpeed: connection['sendSpeed'] as String,
        filesList: firebaseFileModelListFromMap(
          connection['filesList'] as List<dynamic>,
        ),
        downloadFilesList: firebaseDownloadFileModelListFromMap(
          connection['downloadFilesList'] as List<dynamic>,
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

  void changeFilesListFilesDownloadEnumAndUpdateFirebaseFilesList() {
    final filesList = state.filesList;
    var changedValue = false;
    for (final file in state.downloadFilesList) {
      final index = filesList.indexWhere(
        (item) => item.path == file.path && item.name == file.name,
      );
      if (filesList[index].downloadStatus != file.downloadStatus) {
        final changedFile = filesList[index]
          ..downloadStatus = file.downloadStatus;
        filesList[index] = changedFile;
        changedValue = true;
      }
    }
    if (changedValue) {
      updateFirebaseFilesList();
    }
    emit(state.copyWith(filesList: filesList));
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

  void calculateTotalAndNowSpacesInFileList() {
    var totalSpace = state.fileTotalSpaceAsKB;
    var nowSpace = state.fileNowSpaceAsKB;
    for (final file in state.filesList) {
      totalSpace += double.parse(file.totalBytes);
      nowSpace += double.parse(file.bytesTransferred);
    }
    emit(
      state.copyWith(
        fileTotalSpaceAsKB:
            double.parse((totalSpace / 1024).toStringAsFixed(0)),
        fileNowSpaceAsKB: double.parse((nowSpace / 1024).toStringAsFixed(0)),
      ),
    );
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
