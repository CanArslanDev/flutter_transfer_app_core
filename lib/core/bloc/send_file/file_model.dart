import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/download_status_enum.dart';

class FirebaseFileModel {
  FirebaseFileModel({
    required this.name,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.size,
    required this.percentage,
    required this.url,
    required this.downloadStatus,
    required this.downloadPath,
    required this.path,
  });
  String name;
  String bytesTransferred;
  String totalBytes;
  String size;
  String percentage;
  String url;
  FirebaseFileModelDownloadStatus downloadStatus;
  String downloadPath;
  String path;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bytesTransferred': bytesTransferred,
      'totalBytes': totalBytes,
      'size': size,
      'percentage': percentage,
      'downloadStatus': downloadStatus.index,
      'url': url,
      'downloadPath': downloadPath,
      'path': path,
    };
  }
}

FirebaseFileModel firebaseFileModelFromMap(Map<dynamic, dynamic> map) {
  return FirebaseFileModel(
    name: map['name'] as String,
    bytesTransferred: map['bytesTransferred'] as String,
    totalBytes: map['totalBytes'] as String,
    size: map['size'] as String,
    percentage: map['percentage'] as String,
    downloadStatus:
        FirebaseFileModelDownloadStatus.values[map['downloadStatus'] as int],
    downloadPath: map['downloadPath'] as String,
    url: map['url'] as String,
    path: map['path'] as String,
  );
}

List<Map<dynamic, dynamic>> firebaseFileModelListToMap(
  List<FirebaseFileModel> filesList,
) {
  final filesListMap = <Map<dynamic, dynamic>>[];
  for (final file in filesList) {
    filesListMap.add(file.toMap());
  }
  return filesListMap;
}

List<FirebaseFileModel> firebaseFileModelListFromMap(
  List<dynamic> filesListMap,
) {
  final filesList = <FirebaseFileModel>[];
  for (final file in filesListMap) {
    filesList.add(firebaseFileModelFromMap(file as Map<dynamic, dynamic>));
  }
  return filesList;
}
