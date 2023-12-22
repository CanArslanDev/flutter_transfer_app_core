import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/services/navigation_service.dart';
import 'package:flutter_udid/flutter_udid.dart';

class FirebaseCoreSystem {
  String createRandomUserID() {
    final random = Random();
    const min = 100000;
    const max = 999999;
    final value = min + random.nextInt((max + 1) - min);
    return value.toString();
  }

  int timestampDayCalculation(Timestamp timestamp1, Timestamp timestamp2) {
    final date1 = timestamp1.toDate();
    final date2 = timestamp2.toDate();
    final difference = date2.difference(date1);
    final daysBetween = difference.inDays;
    return daysBetween;
  }

  Future<Timestamp> getUserExpirationFromIDCollection(String id) async {
    final collectionuser = FirebaseFirestore.instance.collection('ids').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    try {
      if (doc!['expiration'] != null) {
        return doc['expiration'] as Timestamp;
      } else {
        return FirebaseCore().getServerTimestamp(reduceDays: 365);
      }
    } catch (e) {
      return FirebaseCore().getServerTimestamp(reduceDays: 365);
    }
  }

  Future<String> getUserUsernameFromUsersCollection(String id) async {
    final collectionuser =
        FirebaseFirestore.instance.collection('users').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    return doc!['username'] as String;
  }

  Future<bool> getUserFromUsersCollection(String id) async {
    try {
      final collectionuser =
          FirebaseFirestore.instance.collection('users').doc(id);
      final docSnapshotuser = await collectionuser.get();
      final doc = docSnapshotuser.data();
      if (doc!['token'] != null &&
          doc['expiration'] != null &&
          doc['connectionID'] != null &&
          doc['connectionRequest'] != null &&
          doc['previousConnectionRequest'] != null &&
          doc['availableCloudStorageKB'] != null &&
          doc['latestConnections'] != null &&
          doc['connectedUser'] != null &&
          doc['username'] != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> getUserTokenFromUsersCollection(String id) async {
    final collectionuser = FirebaseFirestore.instance.collection('ids').doc(id);
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    try {
      if (doc!['token'] != null) {
        return doc['token'] as String;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, String>> deviceDetailsAsMap() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final build = await deviceInfoPlugin.androidInfo;
      return {
        'id': build.id,
        'name': build.device,
        'version': build.version.toString(),
        'brand': build.brand,
        'model': build.model,
      };
    } else if (Platform.isIOS) {
      final build = await deviceInfoPlugin.iosInfo;
      return {
        'id': build.identifierForVendor ?? '',
        'name': build.name,
        'version': build.systemVersion,
        'brand': build.systemName,
        'model': build.model,
      };
    } else {
      return {};
    }
  }

  Future<String> getDeviceToken() async {
    return FlutterUdid.consistentUdid;
  }

  void setStatus(FirebaseCoreStatus status) {
    BlocProvider.of<FirebaseCoreBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setStatus(status);
  }

  String getCoreStatusAsString(FirebaseCoreStatus status) {
    if (status == FirebaseCoreStatus.stable) {
      return 'stable';
    } else if (status == FirebaseCoreStatus.loading) {
      return 'loading';
    } else {
      return 'error';
    }
  }

  Future<void> setUserRemoveConnectionRequestAndAddPreviousConnectionRequest(
    String connectionID,
    Map<dynamic, dynamic> connectionData,
  ) async {
    final connectionRequestList = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getConnectionRequest();
    final previousConnectionRequestList = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getPreviousConnectionRequest();
    final docID = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).getToken();
    connectionRequestList
        .removeWhere((map) => map['connectionID'] == connectionID);
    previousConnectionRequestList.add(connectionData);
    await FirebaseFirestore.instance.collection('users').doc(docID).update({
      'connectionRequest': connectionRequestList,
      'previousConnectionRequest': previousConnectionRequestList,
    });
  }
}
