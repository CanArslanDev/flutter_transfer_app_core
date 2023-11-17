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
            connectionRequest: [],
            previousConnectionRequest: [],
          ),
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
      final connectionRequest = <Map<dynamic, dynamic>>[];
      final previousConnectionRequest = <Map<dynamic, dynamic>>[];
      for (final connectionData
          in userFirebaseData['connectionRequest'] as List<dynamic>) {
        print(connectionData);
        connectionRequest.add(connectionData as Map<dynamic, dynamic>);
      }
      for (final previousConnectionData
          in userFirebaseData['previousConnectionRequest'] as List<dynamic>) {
        previousConnectionRequest
            .add(previousConnectionData as Map<dynamic, dynamic>);
      }
      emit(
        state.copyWith(
          connectionRequest: connectionRequest,
          previousConnectionRequest: previousConnectionRequest,
        ),
      );
    });
  }

  UserModel getModel() {
    return state;
  }

  List<Map<dynamic, dynamic>> getConnectionRequest() {
    return state.connectionRequest;
  }

  void setConnectionRequest(List<Map<dynamic, dynamic>> connectionRequest) {
    emit(state.copyWith(connectionRequest: connectionRequest));
  }

  List<Map<dynamic, dynamic>> getPreviousConnectionRequest() {
    return state.previousConnectionRequest;
  }

  void setPreviousConnectionRequest(
      List<Map<dynamic, dynamic>> previousConnectionRequest) {
    emit(state.copyWith(previousConnectionRequest: previousConnectionRequest));
  }

  String getDeviceID() {
    return state.deviceID;
  }

  String getToken() {
    return state.token;
  }
}
