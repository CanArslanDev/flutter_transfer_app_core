import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/service/file_picker_service.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

class CoreFirebaseStorage {
  final storageRef = FirebaseStorage.instance;
  List<FirebaseFileModel> filesListRoot = [];

  Future<void> sendFirebaseFilesListRoot() async {
    await BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setFilesListAndPushFirebase(filesListRoot);
  }

  String get getConnectionCollectionFirebaseDocumentName =>
      BlocProvider.of<FirebaseSendFileBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).getConnectionCollectionFirebaseDocumentName();

  /*void addFileFilesList(
    String fileName,
    String fileSize,
  ) {
    filesListRoot[fileName] = {
      'file': {
        'name': fileName,
        'size': fileSize,
        'bytesTransferred': '',
        'totalBytes': '',
        'fileSize': fileSize,
        'percentage': '0',
        'url': '',
      }
    };
  }*/

  /*void setFileFilesList({
    String? bytesTransferred,
    String? totalBytes,
    String? fileName,
    String? fileSize,
    String? url,
  }) {
    final originalfilesListRoot =
        filesListRoot[fileName] as Map<dynamic, dynamic>;
    final originalfilesListRootFile =
        originalfilesListRoot['file'] as Map<dynamic, dynamic>;
    final percentageCalculation = ((int.parse(
                  bytesTransferred ??
                      originalfilesListRootFile['bytesTransferred'] as String,
                ) /
                int.parse(
                  totalBytes ??
                      originalfilesListRootFile['totalBytes'] as String,
                )) *
            100)
        .toStringAsFixed(0);
    filesListRoot[fileName] = {
      'file': {
        'name': fileName ?? originalfilesListRootFile['name'] as String,
        'size': fileSize ?? originalfilesListRootFile['size'],
        'bytesTransferred': bytesTransferred,
        'totalBytes': totalBytes,
        'fileSize': fileSize ?? originalfilesListRootFile['fileSize'],
        'percentage': percentageCalculation,
        'url': '',
      }
    };
  }*/

  void uploadFilesFromList(List<File> fileList) {
    filesListRoot = BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getFilesList() as List<FirebaseFileModel>;
    fileList.map((file) async {
      convertAndSendFileModel(
        file,
        'files/',
      );
    }).toList();
  }

  void convertAndSendFileModel(File file, String destination) {
    final fileModel = FirebaseFileModel(
      name: file.path.split('/').last,
      bytesTransferred: '0',
      totalBytes: '0',
      size: (file.lengthSync() / 1024).toString(),
      percentage: '0',
      url: '',
      downloadStatus: FirebaseFileModelDownloadStatus.notDownloaded,
      path: file.path,
    );
    filesListRoot.add(fileModel);
    uploadFile(
      file,
      'files/$getConnectionCollectionFirebaseDocumentName/sender/',
      file.path.split('/').last,
      urlCallback: (url) {
        fileModel.url = url;
        changeFileInFilesListRoot(fileModel);
        sendFirebaseFilesListRoot();
      },
      listenUploadTaskCallback: (bytesTransferred, totalBytes) {
        fileModel
          ..bytesTransferred = bytesTransferred
          ..totalBytes = totalBytes
          ..percentage =
              ((int.parse(bytesTransferred) / int.parse(totalBytes)) * 100)
                  .toStringAsFixed(0);
        changeFileInFilesListRoot(fileModel);
        sendFirebaseFilesListRoot();
      },
      uploadSuccessCallback: () {},
    );
  }

  void changeFileInFilesListRoot(FirebaseFileModel file) {
    final index = filesListRoot.indexWhere((item) => item.path == file.path);
    filesListRoot[index] = file;
  }

  void uploadFile(
    File file,
    String destination,
    String? fileName, {
    void Function(String bytesTransferred, String totalBytes)?
        listenUploadTaskCallback,
    void Function(String url)? urlCallback,
    void Function()? uploadSuccessCallback,
  }) {
    final fileNameChild =
        (fileName == null) ? file.path.split('/').last : fileName;
    try {
      final ref = storageRef.ref(destination).child(fileNameChild);
      final uploadTask = ref.putFile(file);
      listenUploadTask(uploadTask, (bytesTransferred, totalBytes) {
        listenUploadTaskCallback?.call(bytesTransferred, totalBytes);
        uploadSuccessCallback?.call();
      });
      getUrlWhenCompleteTask(uploadTask, urlCallback);
    } catch (e) {
      print('error occured $e');
    }
  }

  void listenUploadTask(
    UploadTask uploadTask,
    void Function(String bytesTransferred, String totalBytes)?
        listenUploadTaskCallback,
  ) {
    uploadTask.snapshotEvents.listen((event) {
      if (event.bytesTransferred != 0 || event.totalBytes != 0) {
        listenUploadTaskCallback?.call(
          event.bytesTransferred.toString(),
          event.totalBytes.toString(),
        );
      }
    });
  }

  void getUrlWhenCompleteTask(
    UploadTask uploadTask,
    void Function(String url)? urlCallback,
  ) {
    uploadTask.whenComplete(() async {
      urlCallback?.call(await uploadTask.snapshot.ref.getDownloadURL());
    });
  }
}
