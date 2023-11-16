import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        final deviceToken = await FirebaseCoreSystem().getDeviceToken();

        final collectionuser =
            FirebaseFirestore.instance.collection('users').doc(deviceToken);
        final docSnapshotuser = await collectionuser.get();
        final doc = docSnapshotuser.data();
        final connectionRequest = doc!['connectionRequest'] as List<dynamic>;
        connectionRequest.add({
          'requestUserDeviceToken':
              '17424f43da2b63f82faee98d00209a7d4823afab620ec64e0c2dded07ba2b0a3'
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(deviceToken)
            .update({'connectionRequest': connectionRequest});
      }),
      body: BlocBuilder<UserBloc, UserModel>(
        builder: (context, state) => Column(
          children: [
            for (final state1 in state.connectionRequest)
              Text(
                state1['requestUserDeviceToken'].toString(),
              ),
          ],
        ),
      ),
    );
  }
}
