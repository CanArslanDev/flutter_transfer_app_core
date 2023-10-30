import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';

class UserBloc extends Cubit<UserModel> {
  UserBloc()
      : super(
          UserModel(
            deviceID: '',
            userPlatformDetails: {},
            expiration: Timestamp.now(),
            availableCloudStorageMB: 0,
          ),
        );

  void setID(String deviceID) {
    emit(state.copyWith(deviceID: deviceID));
  }

  void setModel(
    String? deviceID,
    Timestamp expiration,
    Map<String, dynamic> userPlatformDetails,
    int availableCloudStorageMB,
  ) {
    emit(
      state.copyWith(
        deviceID: deviceID,
        expiration: expiration,
        userPlatformDetails: userPlatformDetails,
        availableCloudStorageMB: availableCloudStorageMB,
      ),
    );
  }

  void getModel() {
    emit(state);
  }

  String getID() {
    return state.deviceID;
  }
}
