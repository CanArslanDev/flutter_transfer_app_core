import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';

class FirebaseCoreModel {
  FirebaseCoreModel({
    required this.defaultCloudStorageMB,
    required this.status,
  });
  double defaultCloudStorageMB;
  FirebaseCoreStatus status = FirebaseCoreStatus.stable;

  FirebaseCoreModel copyWith({
    double? defaultCloudStorageMB,
    FirebaseCoreStatus? status,
  }) {
    return FirebaseCoreModel(
      defaultCloudStorageMB:
          defaultCloudStorageMB ?? this.defaultCloudStorageMB,
      status: status ?? this.status,
    );
  }
}
