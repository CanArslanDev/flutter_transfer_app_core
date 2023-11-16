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
              token: '',
              connectionRequest: []),
        );

  void setID(String deviceID) {
    emit(state.copyWith(deviceID: deviceID));
  }

  void setModel(
    Map<String, dynamic>? modelMap,
  ) {
    emit(
      state.copyWith(
        deviceID: (modelMap!['deviceID'] != null)
            ? modelMap['deviceID'] as String
            : null,
        expiration: modelMap['expiration'] as Timestamp,
        userPlatformDetails:
            modelMap['userPlatformDetails'] as Map<String, dynamic>,
        availableCloudStorageMB:
            double.parse(modelMap['availableCloudStorageMB'].toString()),
        token: modelMap['token'] as String,
      ),
    );
  }

  void listenUserDataFromFirebase() {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('users').doc(state.token);
    reference.snapshots().listen((querySnapshot) {
      final userFirebaseData = querySnapshot.data()! as Map<dynamic, dynamic>;
      emit(
        state.copyWith(
          connectionRequest:
              userFirebaseData['connectionRequest'] as List<dynamic>,
        ),
      );
    });
  }

  void getModel() {
    emit(state);
  }

  String getID() {
    return state.deviceID;
  }

  String getToken() {
    return state.token;
  }
}
