import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/firebase_core/core_model.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/status_enum.dart';

class FirebaseCoreBloc extends Cubit<FirebaseCoreModel> {
  FirebaseCoreBloc()
      : super(
          FirebaseCoreModel(
            defaultCloudStorageMB: 0,
            status: FirebaseCoreStatus.uninitialized,
          ),
        );

  void setModel(
    Map<String, dynamic>? modelMap,
  ) {
    emit(
      state.copyWith(
        defaultCloudStorageMB:
            double.parse(modelMap!['defaultCloudStorageMB'].toString()),
      ),
    );
  }

  void getModel() {
    emit(state);
  }

  void setStatus(FirebaseCoreStatus status) {
    emit(state.copyWith(status: status));
  }

  FirebaseCoreStatus getStatus() {
    return state.status;
  }

  double getDefaulStorageMB() {
    return state.defaultCloudStorageMB;
  }
}
