import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});
  @override
  Widget build(BuildContext context) {
    final findIDController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<FirebaseSendFileBloc, FirebaseSendFileModel>(
        builder: (context, state) => Column(
          children: [
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
                  opacity:
                      state.status == FirebaseSendFileRequestEnum.connecting
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
                stateWidget(state.status, state.errorMessage),
                const SizedBox(),
              ],
            ),
          ],
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
