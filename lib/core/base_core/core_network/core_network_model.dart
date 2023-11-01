class FirebaseCoreNetworkModel {
  FirebaseCoreNetworkModel({
    required this.defaultCloudStorageMB,
  });
  double defaultCloudStorageMB;

  FirebaseCoreNetworkModel copyWith({
    double? defaultCloudStorageMB,
  }) {
    return FirebaseCoreNetworkModel(
      defaultCloudStorageMB:
          defaultCloudStorageMB ?? this.defaultCloudStorageMB,
    );
  }
}
