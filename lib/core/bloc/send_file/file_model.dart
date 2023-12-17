enum FirebaseFileModelDownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}

class FirebaseFileModel {
  FirebaseFileModel({
    required this.name,
    required this.bytesTransferred,
    required this.totalBytes,
    required this.size,
    required this.percentage,
    required this.url,
    required this.downloadStatus,
    this.path,
  });
  String name;
  String bytesTransferred;
  String totalBytes;
  String size;
  String percentage;
  String url;
  FirebaseFileModelDownloadStatus downloadStatus;
  String? path;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bytesTransferred': bytesTransferred,
      'totalBytes': totalBytes,
      'size': size,
      'percentage': percentage,
      'downloadStatus': downloadStatus.index,
      'url': url,
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
    url: map['url'] as String,
  );
}
