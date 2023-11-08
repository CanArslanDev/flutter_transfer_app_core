import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/auth/auth_service.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/network/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntp/ntp.dart';

const storage = FlutterSecureStorage();

class FirebaseCore {
  final _firebase=FirebaseFirestore.instance;
  Future<void> initialize() async {
    FirebaseCoreSystem().setStatus(FirebaseCoreStatus.loading);
    await FirebaseCoreNetwork().initialize();
    await updateUserID();
    await updateUser();
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
    await _firebase
        .collection('ids')
        .doc(userID)
        .set(userData);
  }

  Future<void> setUserBlocDataUsersCollection(String id) async {
    final collectionuser =
        _firebase.collection('users').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    try {
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
    final userData = <String, dynamic>{
      'username': 'User',
      'token': deviceToken,
      'expiration': expiration,
      'userPlatformDetails': userPlatformDetails,
      'availableCloudStorageMB': BlocProvider.of<FirebaseCoreBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).getDefaulStorageMB(),
    };
    await _firebase
        .collection('users')
        .doc(userID)
        .set(userData);
  }
}
