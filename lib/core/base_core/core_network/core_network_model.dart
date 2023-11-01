class FirebaseCoreNetworkModel {
  FirebaseCoreNetworkModel({
    required this.defaultCloudStorageMB,
  });
  int defaultCloudStorageMB;

  FirebaseCoreNetworkModel copyWith({
    int? defaultCloudStorageMB,
  }) {
    return FirebaseCoreNetworkModel(
      defaultCloudStorageMB:
          defaultCloudStorageMB ?? this.defaultCloudStorageMB,
    );
  }
}
