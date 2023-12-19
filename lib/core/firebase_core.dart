import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/connection_page.dart';
import 'package:flutter_fast_transfer_firebase_core/core/auth/auth_service.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntp/ntp.dart';

const storage = FlutterSecureStorage();

class FirebaseCore {
  final _firebase = FirebaseFirestore.instance;
  Future<void> initialize() async {
    FirebaseCoreSystem().setStatus(FirebaseCoreStatus.loading);
    await FirebaseCoreNetwork().initialize();
    await updateUserID();
    await updateUser();
    FirebaseAuthService().startListenUser();
    FirebaseCoreSystem().setStatus(FirebaseCoreStatus.stable);
  }

  Future<void> updateUserID() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final storageUserID = await storage.read(key: 'userID');
      if (storageUserID == null) {
        await FirebaseAuthService().createUserID();
      } else {
        await FirebaseAuthService().createUserID(lastUserID: storageUserID);
      }
    } else {
      throw Exception('Platform not supported');
    }
  }

  Future<void> updateUser() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await FirebaseAuthService().createUser();
    } else {
      throw Exception('Platform not supported');
    }
  }

  Future<Timestamp> getServerTimestamp({int? reduceDays}) async {
    if (reduceDays != null) {
      var date = await NTP.now();
      date = date.subtract(Duration(days: reduceDays));
      return Timestamp.fromDate(date);
    } else {
      return Timestamp.fromDate(await NTP.now());
    }
  }

  Future<bool> checkUserIDForIdsCollection(String dataName) async {
    final snapshot = await _firebase.collection('ids').doc(dataName).get();
    return snapshot.exists;
  }

  Future<void> updateDataIDCollection(String userID) async {
    final deviceToken = await FirebaseCoreSystem().getDeviceToken();
    final userPlatformDetails = await FirebaseCoreSystem().deviceDetailsAsMap();
    final expiration = await FirebaseCore().getServerTimestamp();
    final userData = <String, dynamic>{
      'token': deviceToken,
      'expiration': expiration,
      'userPlatformDetails': userPlatformDetails,
    };
    await _firebase.collection('ids').doc(userID).set(userData);
  }

  Future<void> setUserBlocDataUsersCollection(String id) async {
    final collectionuser = _firebase.collection('users').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    final deviceToken = await FirebaseCoreSystem().getDeviceToken();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(deviceToken)
          .update({
        'connectedUser': {
          'userID': '',
          'token': '',
          'username': '',
        },
      });
      BlocProvider.of<UserBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).setModel(
        doc,
      );
    } catch (e) {
      await FirebaseCore().updateDataUsersCollection(id);
    }
  }

  Future<void> updateDataUsersCollection(String userID) async {
    final deviceToken = await FirebaseCoreSystem().getDeviceToken();
    final userPlatformDetails = await FirebaseCoreSystem().deviceDetailsAsMap();
    final expiration = await FirebaseCore().getServerTimestamp();
    final connectionID = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getDeviceID();
    final userData = <String, dynamic>{
      'previousConnectionRequest': <Map<dynamic, dynamic>>{},
      'connectionRequest': <Map<dynamic, dynamic>>{},
      'latestConnections': <Map<dynamic, dynamic>>{},
      'connectedUser': {
        'userID': '',
        'token': '',
        'username': '',
      },
      'connectionID': connectionID,
      'username': 'User',
      'token': deviceToken,
      'expiration': expiration,
      'userPlatformDetails': userPlatformDetails,
      'availableCloudStorageMB': BlocProvider.of<FirebaseCoreBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).getDefaulStorageMB(),
    };
    await _firebase.collection('users').doc(userID).set(userData);
  }

  Future<void> acceptUserConnectionRequest(
    String connectionID,
    Map<dynamic, dynamic> connectionData,
  ) async {
    final userModel = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getModel();
    final connectedUserReceiver = {
      'token': userModel.token,
      'userID': userModel.deviceID,
      'username': userModel.username,
    };
    final connectedUserSender = {
      'token': connectionData['requestUserDeviceToken'] as String,
      'userID': connectionData['connectionID'] as String,
      'username': connectionData['username'] as String,
    };
    BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setConnection(
      userModel.deviceID,
      userModel.username,
      connectionData['connectionID'] as String,
      connectionData['username'] as String,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.token)
        .update({
      'connectedUser': connectedUserSender,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(connectionData['requestUserDeviceToken'] as String)
        .update({
      'connectedUser': connectedUserReceiver,
    });
    await BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setFirebaseConnectionsCollection();
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

  Future<void> refuseUserConnectionRequest(
    String connectionID,
    Map<dynamic, dynamic> connectionData,
  ) async {
    await FirebaseCoreSystem()
        .setUserRemoveConnectionRequestAndAddPreviousConnectionRequest(
      connectionID,
      connectionData,
    );
  }
}
