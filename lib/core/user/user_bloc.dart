import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/connection_page.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

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
            latestSendedFilesList: [],
            connectedUser: {},
            username: '',
          ),
        );

  void setID(String deviceID) {
    emit(state.copyWith(deviceID: deviceID));
  }

  void setModel(
    Map<String, dynamic>? modelMap,
  ) {
    try {
      final latestSendedFilesList = <Map<dynamic, dynamic>>[];
      for (final latestSendedFilesListData
          in modelMap!['latestSendedFilesList'] as List<dynamic>) {
        latestSendedFilesList
            .add(latestSendedFilesListData as Map<dynamic, dynamic>);
      }
      emit(
        state.copyWith(
          deviceID: (modelMap['deviceID'] != null)
              ? modelMap['deviceID'] as String
              : null,
          expiration: modelMap['expiration'] as Timestamp,
          userPlatformDetails:
              modelMap['userPlatformDetails'] as Map<String, dynamic>,
          availableCloudStorageMB:
              double.parse(modelMap['availableCloudStorageMB'].toString()),
          token: modelMap['token'] as String,
          latestSendedFilesList: latestSendedFilesList,
          connectedUser: modelMap['connectedUser'] as Map<dynamic, dynamic>,
          username: modelMap['username'] as String,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void listenUserDataFromFirebase() {
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('users').doc(state.token);
    reference.snapshots().listen((querySnapshot) async {
      final userFirebaseData = querySnapshot.data()! as Map<dynamic, dynamic>;
      final connectedUser =
          userFirebaseData['connectedUser'] as Map<dynamic, dynamic>;
      if (connectedUser['token'] != '' &&
          connectedUser['userID'] != '' &&
          connectedUser['username'] != '' &&
          !BlocProvider.of<FirebaseSendFileBloc>(
            NavigationService.navigatorKey.currentContext!,
          ).ifConnectionExist()) {
        BlocProvider.of<FirebaseSendFileBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).setConnection(
          connectedUser['userID'] as String,
          state.deviceID,
        );
        await BlocProvider.of<FirebaseSendFileBloc>(
          NavigationService.navigatorKey.currentContext!,
        ).listenConnection();
        await Navigator.push(
          NavigationService.navigatorKey.currentContext!,
          MaterialPageRoute<dynamic>(
            builder: (context) => const ConnectionPage(),
          ),
        );
      }
      final connectionRequest = <Map<dynamic, dynamic>>[];
      final previousConnectionRequest = <Map<dynamic, dynamic>>[];
      for (final connectionData
          in userFirebaseData['connectionRequest'] as List<dynamic>) {
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
    List<Map<dynamic, dynamic>> previousConnectionRequest,
  ) {
    emit(state.copyWith(previousConnectionRequest: previousConnectionRequest));
  }

  String getDeviceID() {
    return state.deviceID;
  }

  String getUsername() {
    return state.username;
  }

  String getToken() {
    return state.token;
  }
}
