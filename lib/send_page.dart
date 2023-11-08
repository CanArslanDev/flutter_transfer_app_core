import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/search_user/search_user_bloc.dart';
import 'package:flutter_fast_transfer_firebase_core/core/bloc/search_user/search_user_model.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
        body: BlocBuilder<FirebaseSearchUserBloc,FirebaseSearchUserModel>(builder: ( context,  state) =>Column(
          children: [
            TextField(
              onChanged: (value) {
                context.read<FirebaseSearchUserBloc>().setFindUsername(value);
              },
            ),
            StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('users').where('username', isGreaterThanOrEqualTo: state.findUserName).snapshots(),
  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return Text('Hata: ${snapshot.error}');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.data!.docs.isEmpty || state.findUserName.isEmpty) {
      return Text('Kullanıcı bulunamadı');
    }

    // Kullanıcıyı bulduğunuzda burada işlemler yapabilirsiniz
    String value=snapshot.data!.docs[0]['username'] as String;
    print(value);
    return Text(value);
  },
)

          ],
        )),
    );
  }
}