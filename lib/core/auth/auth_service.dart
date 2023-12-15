import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_system.dart';
import 'package:flutter_fast_transfer_firebase_core/core/firebase_core.dart';
import 'package:flutter_fast_transfer_firebase_core/core/user/user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/service/navigation_service.dart';

class FirebaseAuthService {
  Future<bool> createUser() async {
    final deviceToken = await FirebaseCoreSystem().getDeviceToken();
    if (await FirebaseCoreSystem().getUserFromUsersCollection(deviceToken)) {
      await FirebaseCore().setUserBlocDataUsersCollection(deviceToken);
    } else {
      await FirebaseCore().updateDataUsersCollection(deviceToken);
      await FirebaseCore().setUserBlocDataUsersCollection(deviceToken);
    }
    return true;
  }

  void startListenUser() {
    BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).listenUserDataFromFirebase();
  }

  Future<bool> createUserID({String? lastUserID}) async {
    var lastUserIDVoid = lastUserID;
    var foundedUser = false;
    while (foundedUser != true) {
      String randomUserID;
      if (lastUserIDVoid != null) {
        randomUserID = lastUserIDVoid;
      } else {
        randomUserID = FirebaseCoreSystem().createRandomUserID();
      }
      final userExpiration = await FirebaseCoreSystem()
          .getUserExpirationFromIDCollection(randomUserID);
      final networkExpiration = await FirebaseCore().getServerTimestamp();
      final interval = FirebaseCoreSystem()
          .timestampDayCalculation(userExpiration, networkExpiration);
      if (lastUserIDVoid != null) {
        final userToken = await FirebaseCoreSystem()
            .getUserTokenFromUsersCollection(randomUserID);
        final deviceToken = await FirebaseCoreSystem().getDeviceToken();
        if (userToken == deviceToken) {
          await setUser(randomUserID);
          foundedUser = true;
        }
      } else {
        if (interval >= 30) {
          await setUser(randomUserID);
          foundedUser = true;
        }
      }
      if (lastUserIDVoid != null) {
        lastUserIDVoid = null;
      }
    }
    return true;
  }

  Future<void> setUser(String userID) async {
    await storage.write(key: 'userID', value: userID);

    BlocProvider.of<UserBloc>(
      NavigationService.navigatorKey.currentContext!,
    ).setID(userID);
    await FirebaseCore().updateDataIDCollection(userID);
  }
}
