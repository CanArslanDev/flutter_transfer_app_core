import 'package:flutter/material.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/multi_2_bloc_builder.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Multi2BlocBuilder<UserBloc, UserModel, FirebaseCoreNetwokBloc,
            FirebaseCoreNetworkModel>(
          builder: (coreContext, coreState, networkState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('STATUS:'),
                Text('device id: ${coreState.deviceID}'),
                Text('expiration: ${coreState.expiration}'),
                Text(
                  '''availableCloudStorageMB: ${coreState.availableCloudStorageMB}''',
                ),
                Text('userPlatformDetails: ${coreState.userPlatformDetails}'),
                Text(
                  'defaultCloudStorageMB: ${networkState.defaultCloudStorageMB}',
                ),
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
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseCoreNetwork().initialize();
                  },
                  child: const Text('initalize core network'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
