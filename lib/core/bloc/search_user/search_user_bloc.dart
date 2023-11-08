import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/search_user/search_user_model.dart';

class FirebaseSearchUserBloc extends Cubit<FirebaseSearchUserModel> {
  FirebaseSearchUserBloc()
      : super(
          FirebaseSearchUserModel(
            findUserName: '',
          ),
        );


  void getModel() {
    emit(state);
  }

  void setFindUsername(String username) {
    emit(state.copyWith(findUserName: username));
  }

  String getindUsername() {
    return state.findUserName;
  }

}
