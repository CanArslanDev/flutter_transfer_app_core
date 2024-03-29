import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final deviceToken = await FirebaseCoreSystem().getDeviceToken();

          final collectionuser =
              FirebaseFirestore.instance.collection('users').doc(deviceToken);
          final docSnapshotuser = await collectionuser.get();
          final doc = docSnapshotuser.data();
          final connectionRequest = doc!['connectionRequest'] as List<dynamic>;
          // connectionRequest.add({
          //   'requestUserDeviceToken':
          //       'b83f937d71ef9c59b96a4d6777
          // 9e77bc11d604c6fbf58383ea642e85e7a49c4b',
          //   'connectionID': '583249',
          //   'username': 'User',
          // });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(deviceToken)
              .update({'connectionRequest': connectionRequest});
        },
      ),
      body: BlocBuilder<UserBloc, UserModel>(
        builder: (context, state) => Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Connection Request',
                style: TextStyle(fontSize: 20),
              ),
            ),
            for (final Map<dynamic, dynamic> state1 in state.connectionRequest)
              FutureBuilder(
                future: FirebaseCoreSystem().getUserUsernameFromUsersCollection(
                  state1['requestUserDeviceToken'] as String,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Card(
                      child: GestureDetector(
                        onTap: () async =>
                            FirebaseCore().acceptUserConnectionRequest(
                          state1['connectionID'] as String,
                          state1,
                        ),
                        child: SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 30,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.data!,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async => FirebaseCore()
                                        .refuseUserConnectionRequest(
                                      state1['connectionID'] as String,
                                      state1,
                                    ),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator.adaptive();
                  }
                },
              ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Previous Connection Request',
                style: TextStyle(fontSize: 20),
              ),
            ),
            for (final state1 in state.previousConnectionRequest)
              FutureBuilder(
                future: FirebaseCoreSystem().getUserUsernameFromUsersCollection(
                  state1['requestUserDeviceToken'] as String,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Card(
                      child: SizedBox(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 30,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    snapshot.data!,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator.adaptive();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
