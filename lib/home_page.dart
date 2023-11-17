import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/core_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/receive_page.dart';
import 'package:flutter_fast_transfer_firebase_core/send_page.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/multi_2_bloc_builder.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/multi_3_bloc_builder.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/receive_top_bar.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final findIDController = TextEditingController();
    return Scaffold(
      floatingActionButton: const FloatingActionButton(
        onPressed: InAppNotifications.receiveTopBar,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Multi3BlocBuilder<UserBloc, UserModel, FirebaseCoreBloc,
            FirebaseCoreModel, FirebaseSendFileBloc, FirebaseSendFileModel>(
          builder: (coreContext, userState, coreState, sendState) {
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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (context) => const ReceivePage(),
                          ),
                        );
                      },
                      child: const Text('receive page'),
                    ),
                  ],
                ),
                TextField(
                  controller: findIDController,
                  decoration: const InputDecoration(
                    hintText: 'INPUT ID',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await BlocProvider.of<FirebaseSendFileBloc>(
                      context,
                    ).sendConnectRequest(findIDController.text);
                  },
                  child: const Text('send request'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedOpacity(
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(seconds: 1),
                      opacity: sendState.status ==
                              FirebaseSendFileRequestEnum.connecting
                          ? 1
                          : 0,
                      child: const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    stateWidget(sendState.status, sendState.errorMessage),
                    const SizedBox(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget stateWidget(FirebaseSendFileRequestEnum status, String errorMessage) {
    if (status != FirebaseSendFileRequestEnum.error) {
      return Text(convertEnumToString(status));
    } else {
      return Text(
        errorMessage,
        style: const TextStyle(color: Colors.red),
      );
    }
  }

  String convertEnumToString(FirebaseSendFileRequestEnum status) {
    if (status == FirebaseSendFileRequestEnum.sendedRequest) {
      return 'Sended request';
    }
    return '';
  }
}