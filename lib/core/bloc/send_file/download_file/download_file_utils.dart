import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_file/download_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/download_status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/file_model.dart';

class FirebaseDownloadFileUtils {
  void downloadFilesInFilesList(
    List<FirebaseFileModel> filesList,
    List<FirebaseDownloadFileModel> downloadFilesList,
    void Function(
      FirebaseDownloadFileModel downloadModel,
      FirebaseFileModel fileModel,
    ) ifNotFoundedList,
  ) {
    for (final file in filesList) {
      if (file.url != '') {
        final index = downloadFilesList.indexWhere(
          (item) => item.path == file.path && item.name == file.name,
        );
        if (index == -1) {
          ifNotFoundedList.call(
            FirebaseDownloadFileModel(
              path: file.path,
              name: file.name,
              downloadPath: '',
              downloadStatus: FirebaseFileModelDownloadStatus.downloading,
            ),
            file,
          );
        }
      }
    }
  }
}
