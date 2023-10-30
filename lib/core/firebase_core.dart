import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/auth/auth_service.dart';
import 'package:flutter_fast_transfer_firebase_core/core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:ntp/ntp.dart';

const storage = FlutterSecureStorage();

class FirebaseCore {
  Future<void> initialize() async {
    await updateUserID();
    await updateUser();
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

  Future<void> updateDataIDCollection(String userID) async {
    final deviceToken = await FirebaseCoreSystem().getDeviceToken();
    final userPlatformDetails = await FirebaseCoreSystem().deviceDetailsAsMap();
    final expiration = await FirebaseCore().getServerTimestamp();
    final userData = <String, dynamic>{
      'token': deviceToken,
      'expiration': expiration,
      'userPlatformDetails': userPlatformDetails,
    };
    await FirebaseFirestore.instance
        .collection('ids')
        .doc(userID)
        .set(userData);
  }

  Future<void> setUserBlocDataUsersCollection(String id) async {
    final collectionuser =
        FirebaseFirestore.instance.collection('users').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    try {
      BlocProvider.of<UserBloc>(
        NavigationService.navigatorKey.currentContext!,
      ).setModel(
        null,
        doc!['expiration'] as Timestamp,
        doc['userPlatformDetails'] as Map<String, dynamic>,
        doc['availableCloudStorageMB'] as int,
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
      'token': deviceToken,
      'expiration': expiration,
      'userPlatformDetails': userPlatformDetails,
      'availableCloudStorageMB': 0,
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .set(userData);
  }
}
