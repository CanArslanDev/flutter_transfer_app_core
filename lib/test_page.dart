import 'package:flutter/material.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/network/core_network_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/network/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/send_page.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/multi_2_bloc_builder.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/receive_top_bar.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const FloatingActionButton(
        onPressed: InAppNotifications.receiveTopBar,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Multi2BlocBuilder<UserBloc, UserModel, FirebaseCoreBloc,
            FirebaseCoreModel>(
          builder: (coreContext, userState, coreState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('status ${coreState.status}'),
                Text('device id: ${userState.deviceID}'),
                Text('expiration: ${userState.expiration}'),
                Text(
                  '''availableCloudStorageMB: ${userState.availableCloudStorageMB}''',
                ),
                Text('userPlatformDetails: ${userState.userPlatformDetails}'),
                Text(
                  '''defaultCloudStorageMB: ${coreState.defaultCloudStorageMB}''',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => const SendPage(),
                          ),
                        );
                      },
                      child: const Text('send page'),
                    ),
                    ElevatedButton(
                      onPressed: () async {},
                      child: const Text('receive page'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
