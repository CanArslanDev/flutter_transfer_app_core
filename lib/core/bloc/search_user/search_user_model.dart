import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';

class FirebaseSearchUserModel {
  FirebaseSearchUserModel({
    required this.findUserName,
  });
  String findUserName;

  FirebaseSearchUserModel copyWith({
    String? findUserName,
  }) {
    return FirebaseSearchUserModel(
      findUserName:
          findUserName ?? this.findUserName,
    );
  }
}
