import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/enums/send_file_request_enum.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_firebase.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/send_file/send_file_utils.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/services/navigation_service.dart';

class FirebaseSendFileLeaveConnection {
  Future<void> leaveCurrentConnection() async {
    final sendFileBloc = BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    );
    final user = BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    );
    if (sendFileBloc.openedLeaveAlertDialog == true) {
      Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
      Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    } else {
      Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
    }
    await user.updateFirebaseConnectedUser({
      'token': '',
      'userID': '',
      'username': '',
    });
    final defaultModel = FirebaseSendFileUtils().getDefaultModel()
      ..firebaseDocumentName = sendFileBloc.state.firebaseDocumentName;
    sendFileBloc.setModel(defaultModel);
    await sendFileBloc
        .getSendFileFirebase()
        .updateFirebaseConnectionsCollection(defaultModel);

    await sendFileBloc.getSendFileFirebase().disposeListenConnection();
  }

  Future<void> leaveConnectionAlertDialog(BuildContext context) async {
    final sendFileBloc = BlocProvider.of<FirebaseSendFileBloc>(
      NavigationService.navigatorKey.currentContext!,
    )..openedLeaveAlertDialog = true;
    return showDialog<Object>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkmak İster Misiniz?'),
          content: const Text('Emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sendFileBloc.openedLeaveAlertDialog = false;
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                sendFileBloc.openedLeaveAlertDialog = false;
                await BlocProvider.of<FirebaseSendFileBloc>(
                  context,
                ).leaveConnection();
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    ).then((value) {
      sendFileBloc.openedLeaveAlertDialog = false;
    });
  }
}
