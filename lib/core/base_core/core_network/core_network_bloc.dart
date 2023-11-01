import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/base_core/core_network/core_network_model.dart';

class FirebaseCoreNetwokBloc extends Cubit<FirebaseCoreNetworkModel> {
  FirebaseCoreNetwokBloc()
      : super(
          FirebaseCoreNetworkModel(
            defaultCloudStorageMB: 0,
          ),
        );

  void setModel(
    Map<String, dynamic>? modelMap,
  ) {
    emit(
      state.copyWith(
        defaultCloudStorageMB: modelMap!['defaultCloudStorageMB'] as int,
      ),
    );
  }

  void getModel() {
    emit(state);
  }
}
