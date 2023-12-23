import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/leave_connection.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_firebase.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_utils.dart';
import 'package:flutter_fast_transfer_firebase_core/core/storage/firebase_storage.dart';
import 'package:flutter_fast_transfer_firebase_core/services/file_picker_service.dart';
import 'package:flutter_fast_transfer_firebase_core/services/navigation_service.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () async {
              await FirebaseSendFileLeaveConnection()
                  .leaveConnectionAlertDialog(context);
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: '1',
          onPressed: () async {
            // await FirebaseFirestore.instance
            //     .collection('connections')
            //     .doc('536808-583249')
            //     .update({
            //   filesList.1.4: {'name': 'test'}
            // });
          },
        ),
        body: BlocBuilder<FirebaseSendFileBloc, FirebaseSendFileModel>(
          builder: (context, state) {
            return ListView(
              children: [
                Text('receiverID: ${state.receiverID}'),
                Text('senderID: ${state.senderID}'),
                Text('firebaseDocumentName: ${state.firebaseDocumentName}'),
                Text('filesCount: ${state.filesCount}'),
                Text('sendSpeed: ${state.sendSpeed}'),
                Text('filesListLength: ${state.filesList.length}'),
                Text('errorMessage: ${state.errorMessage}'),
                Text('status: ${state.status}'),
                Text('uploadingStatus: ${state.uploadingStatus}'),
                Text('fileTotalSpaceAsKB: ${state.fileTotalSpaceAsKB}'),
                Text('fileNowSpaceAsKB: ${state.fileNowSpaceAsKB}'),
                ElevatedButton(
                  onPressed: () async {
                    final fileList = await FilePickerService().pickFiles();
                    CoreFirebaseStorage().uploadFilesFromList(fileList);
                  },
                  child: const Text('choose file'),
                ),
                const Text('filesList'),
                for (final file in state.filesList.reversed) Text('''
                  name: ${file.name}
                  bytesTransferred: ${file.bytesTransferred}
                  totalBytes: ${file.totalBytes}
                  size: ${file.size}
                  downloadStatus: ${file.downloadStatus}
                  percentage: ${file.percentage}
                  url: ${file.url}
                  path: ${file.path}'''),
              ],
            );
          },
        ),
      ),
    );
  }
}
