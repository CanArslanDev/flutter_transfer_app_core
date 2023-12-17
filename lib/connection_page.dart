import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/service/file_picker_service.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: BlocBuilder<FirebaseSendFileBloc, FirebaseSendFileModel>(
            builder: (context, state) {
          return Column(
            children: [
              Text('receiverID: ${state.receiverID}'),
              Text('senderID: ${state.senderID}'),
              Text('firebaseDocumentName: ${state.firebaseDocumentName}'),
              Text('filesCount: ${state.filesCount}'),
              Text('sendSpeed: ${state.sendSpeed}'),
              Text('filesList: ${state.filesList}'),
              Text('errorMessage: ${state.errorMessage}'),
              Text('status: ${state.status}'),
              Text('uploadingStatus: ${state.uploadingStatus}'),
              Text('fileTotalSpaceAsKB: ${state.fileTotalSpaceAsKB}'),
              Text('fileNowSpaceAsKB: ${state.fileNowSpaceAsKB}'),
              Text('userDetails: ${state.userDetails}'),
              ElevatedButton(
                onPressed: () async {
                  await FilePickerService().pickFiles();
                },
                child: const Text('choose file'),
              ),
            ],
          );
        }));
  }
}
