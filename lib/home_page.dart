import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/connection_page.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/core_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/firebase_core_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_model.dart';
import 'package:flutter_fast_transfer_firebase_core/receive_page.dart';
import 'package:flutter_fast_transfer_firebase_core/send_page.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';
import 'package:flutter_fast_transfer_firebase_core/utils/multi_3_bloc_builder.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    unawaited(FirebaseCore().initialize());
    final findIDController = TextEditingController();
    return Scaffold(
      // floatingActionButton: const FloatingActionButton(
      //   onPressed: InAppNotifications.receiveTopBar,
      // ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: '2',
            onPressed: () async {
              // final file = await HttpService().downloadFile(
              //     'https://firebasestorage.googleapis.com/v0/b/flutter-fast-transfer.appspot.com/o/files%2F115607-910721%2Fsender%2Ftest1Mb-1702883061.db?alt=media&token=6dd144cd-e2ae-4e35-9744-90fe06ac24ca',
              //     '1.db',);
              // print(file.path);
            },
          ),
          FloatingActionButton(
            heroTag: '3',
            onPressed: () async {
              // final connectedUserSender = {
              //   'token':
              //       '17424f43da2b63f82faee98d002
              // 09a7d4823afab620ec64e0c2dded07ba2b0a3',
              //   'userID': '536808',
              //   'username': 'User',
              // };
              BlocProvider.of<FirebaseSendFileBloc>(
                NavigationService.navigatorKey.currentContext!,
              ).setConnection(
                '583249',
                'User',
                '536808',
                'User',
              );
              await BlocProvider.of<FirebaseSendFileBloc>(
                NavigationService.navigatorKey.currentContext!,
              ).listenConnection();

              await Navigator.push(
                NavigationService.navigatorKey.currentContext!,
                MaterialPageRoute<dynamic>(
                  builder: (context) => const ConnectionPage(),
                ),
              );
            },
          ),
        ],
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
