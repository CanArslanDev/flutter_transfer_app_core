import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/download_status_enum.dart';

class FirebaseDownloadFileModel {
  FirebaseDownloadFileModel({
    required this.name,
    required this.path,
    required this.downloadStatus,
  });
  String name;
  String path;
  FirebaseFileModelDownloadStatus downloadStatus;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'path': path,
      'downloadStatus': downloadStatus.index,
    };
  }
}

FirebaseDownloadFileModel firebaseDownloadFileModelFromMap(
  Map<dynamic, dynamic> map,
) {
  return FirebaseDownloadFileModel(
    name: map['name'] as String,
    path: map['path'] as String,
    downloadStatus:
        FirebaseFileModelDownloadStatus.values[map['downloadStatus'] as int],
  );
}

List<Map<dynamic, dynamic>> firebaseDownloadFileModelListToMap(
  List<FirebaseDownloadFileModel> filesList,
) {
  final filesListMap = <Map<dynamic, dynamic>>[];
  for (final file in filesList) {
    filesListMap.add(file.toMap());
  }
  return filesListMap;
}

List<FirebaseDownloadFileModel> firebaseDownloadFileModelListFromMap(
  List<dynamic> filesListMap,
) {
  final filesList = <FirebaseDownloadFileModel>[];
  for (final file in filesListMap) {
    filesList
        .add(firebaseDownloadFileModelFromMap(file as Map<dynamic, dynamic>));
  }
  return filesList;
}
