import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/connection_page.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/latest_connections_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/services/navigation_service.dart';

class UserBloc extends Cubit<UserModel> {
  UserBloc()
      : super(
          UserModel(
            deviceID: '',
            userPlatformDetails: {},
            expiration: Timestamp.now(),
            availableCloudStorageKB: 0,
            token: '',
            connectionRequest: [],
            previousConnectionRequest: [],
            latestConnections: [],
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
      final latestConnections = <Map<dynamic, dynamic>>[];
      for (final latestConnectionsData
          in modelMap!['latestConnections'] as List<dynamic>) {
        latestConnections.add(latestConnectionsData as Map<dynamic, dynamic>);
      }
      emit(
        state.copyWith(
          deviceID: (modelMap['deviceID'] != null)
              ? modelMap['deviceID'] as String
              : null,
          expiration: modelMap['expiration'] as Timestamp,
          userPlatformDetails:
              modelMap['userPlatformDetails'] as Map<String, dynamic>,
          availableCloudStorageKB:
              double.parse(modelMap['availableCloudStorageKB'].toString()),
          token: modelMap['token'] as String,
          latestConnections:
              convertLatestConnectionsListFromMap(latestConnections),
          connectedUser: modelMap['connectedUser'] as Map<dynamic, dynamic>,
          username: modelMap['username'] as String,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void listUnionLatestConnectionsInState(
    UserLatestConnectionsModel latestConnectionsModel,
  ) {
    final newLatestConnections = state.latestConnections;
    final index = state.latestConnections.indexWhere(
      (item) =>
          item.senderUsename == latestConnectionsModel.senderUsename &&
          item.senderID == latestConnectionsModel.senderID &&
          item.receiverID == latestConnectionsModel.receiverID &&
          item.receiverUsername == latestConnectionsModel.receiverUsername &&
          item.dateTime == latestConnectionsModel.dateTime,
    );
    if (index != -1) {
      newLatestConnections[index] = latestConnectionsModel;
    } else {
      newLatestConnections.add(latestConnectionsModel);
    }
    emit(state.copyWith(latestConnections: newLatestConnections));
  }

  Future<void> sendFirebaseLatestConnectionsList() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(state.token)
        .update({
      'latestConnections':
          convertLatestConnectionsListToMap(state.latestConnections),
    });
  }

  List<UserLatestConnectionsModel> convertLatestConnectionsListFromMap(
    List<dynamic> latestConnectionsList,
  ) {
    final latestConnections = <UserLatestConnectionsModel>[];
    for (final latestConnectionsData in latestConnectionsList) {
      latestConnections.add(
        userLatestConnectionsModelFromMap(
          latestConnectionsData as Map<dynamic, dynamic>,
        ),
      );
    }
    return latestConnections;
  }

  List<Map<dynamic, dynamic>> convertLatestConnectionsListToMap(
    List<UserLatestConnectionsModel> latestConnectionsList,
  ) {
    final latestConnections = <Map<dynamic, dynamic>>[];
    for (final latestConnectionsData in latestConnectionsList) {
      latestConnections.add(latestConnectionsData.toMap());
    }
    return latestConnections;
  }

  Future<void> setLatestConnectionsListAndSendFirebase(
    UserLatestConnectionsModel latestConnectionsModel,
  ) async {
    state.latestConnections.add(latestConnectionsModel);
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('users').doc(state.token);
    await reference.update({
      'latestConnections':
          convertLatestConnectionsListToMap(state.latestConnections),
    });
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
          connectedUser['username'] as String,
          state.deviceID,
          state.username,
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
      emit(
        state.copyWith(
          connectedUser: connectedUser,
          latestConnections: convertLatestConnectionsListFromMap(
            userFirebaseData['latestConnections'] as List<dynamic>,
          ),
          connectionRequest: convertConnectionRequestListToMap(
            userFirebaseData['connectionRequest'] as List<dynamic>,
          ),
          previousConnectionRequest: convertPreviousConnectionRequestListToMap(
            userFirebaseData['previousConnectionRequest'] as List<dynamic>,
          ),
        ),
      );
    });
  }

  Future<void> updateFirebaseConnectedUser(
    Map<String, String> connectedUser,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(state.token)
        .update({
      'connectedUser': connectedUser,
    });
  }

  Future<void> decreaseUserCloudStorageAndSendFirebase(
    double fileSizeKB,
  ) async {
    final newAvailableCloudStorageKB = state.availableCloudStorageKB -
        double.parse(fileSizeKB.toStringAsFixed(0));

    emit(
      state.copyWith(
        availableCloudStorageKB: newAvailableCloudStorageKB,
      ),
    );
    final DocumentReference reference =
        FirebaseFirestore.instance.collection('users').doc(state.token);
    await reference.update({
      'availableCloudStorageKB': state.availableCloudStorageKB,
    });
  }

  List<Map<dynamic, dynamic>> convertConnectionRequestListToMap(
    List<dynamic> connectionRequestList,
  ) {
    final connectionRequest = <Map<dynamic, dynamic>>[];
    for (final connectionRequestData in connectionRequestList) {
      connectionRequest.add(connectionRequestData as Map<dynamic, dynamic>);
    }
    return connectionRequest;
  }

  List<Map<dynamic, dynamic>> convertPreviousConnectionRequestListToMap(
    List<dynamic> previousConnectionRequestList,
  ) {
    final previousConnectionRequest = <Map<dynamic, dynamic>>[];
    for (final previousConnectionRequestData in previousConnectionRequestList) {
      previousConnectionRequest
          .add(previousConnectionRequestData as Map<dynamic, dynamic>);
    }
    return previousConnectionRequest;
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
