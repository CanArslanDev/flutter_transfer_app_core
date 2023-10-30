import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: BlocBuilder<UserBloc, UserModel>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('device id: ${state.deviceID}'),
                Text('expiration: ${state.expiration}'),
                Text(
                    'availableCloudStorageMB: ${state.availableCloudStorageMB}'),
                Text('userPlatformDetails: ${state.userPlatformDetails}'),
                ElevatedButton(
                  onPressed: () {
                    FirebaseCore().initialize();
                  },
                  child: const Text('Initialize Core'),
                ),
                ElevatedButton(
                  onPressed: () {
                    debugPrint(FirebaseCoreSystem().createRandomUserID());
                  },
                  child: const Text('create user id (print)'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
