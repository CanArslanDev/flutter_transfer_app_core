import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

class FirebaseCoreNetwork {
  Future<void> initialize() async {
    final collectionuser =
        FirebaseFirestore.instance.collection('settings').doc('settings');
    final docSnapshotuser = await collectionuser.get();
    final doc = docSnapshotuser.data();
    BlocProvider.of<FirebaseCoreNetwokBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setModel(
      doc,
    );
  }
}
