import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippo/core/authentication/auth_provider.dart';
import 'package:nippo/core/const.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'user.dart';

part 'user_provider.g.dart';

@riverpod
DocumentReference<User> userRef(UserRefRef ref) {
  final firUser = ref.watch(firUserProvider).value;
  return FirebaseFirestore.instance
      .collection(Collection.users)
      .doc(firUser?.uid)
      .withConverter<User>(
        fromFirestore: (snapshot, _) => User.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );
}

@riverpod
Stream<DocumentSnapshot<User>> user(UserRef ref) =>
    ref.watch(userRefProvider).snapshots();