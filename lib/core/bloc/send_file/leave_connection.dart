import 'package:flutter_bloc/flutter_bloc.dart';
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
    await user.updateFirebaseConnectedUser({
      'token': '',
      'userID': '',
      'username': '',
    });
    sendFileBloc.setModel(FirebaseSendFileUtils().getDefaultModel());
    await sendFileBloc.getSendFileFirebase().disposeListenConnection();
  }
}
