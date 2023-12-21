import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';

class FirebaseCoreModel {
  FirebaseCoreModel({
    required this.defaultCloudStorageKB,
    required this.status,
  });
  double defaultCloudStorageKB;
  FirebaseCoreStatus status = FirebaseCoreStatus.stable;

  FirebaseCoreModel copyWith({
    double? defaultCloudStorageKB,
    FirebaseCoreStatus? status,
  }) {
    return FirebaseCoreModel(
      defaultCloudStorageKB:
          defaultCloudStorageKB ?? this.defaultCloudStorageKB,
      status: status ?? this.status,
    );
  }
}
