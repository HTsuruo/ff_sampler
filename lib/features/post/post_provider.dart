import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nippo/core/const.dart';
import 'package:nippo/features/user/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'post.dart';

part 'post_provider.g.dart';

class _Converter {
  _Converter._();

  static Post from(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) =>
      Post.fromJson(snapshot.data()!);

  static Map<String, dynamic> to(
    Post post,
    SetOptions? options,
  ) =>
      post.toJson();
}

// REVIEW(htsuruo): ドキュメントIDが取得できるようにQueryDocumentSnapshotから返すProviderにしてみた。
// ただ、仮にデータソースをFirestoreからSupabaseやREST APIに差し替えたくなった場合は不都合が生じそう。
// List<Post>のデータモデルを返却する形にしておけば、差し替えは容易そうだがFirestoreを使う場合は割り切ったほうが良いのだろうか。
@riverpod
Stream<List<QueryDocumentSnapshot<Post>>> posts(PostsRef ref) {
  return FirebaseFirestore.instance
      .collectionGroup(Collection.posts)
      .withConverter<Post>(
        fromFirestore: _Converter.from,
        toFirestore: _Converter.to,
      )
      .orderBy(Field.createdAt, descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

// コレクショングループで取得する
@riverpod
Stream<QueryDocumentSnapshot<Post>?> post(
  PostRef ref,
  String? postId,
) {
  return FirebaseFirestore.instance
      .collectionGroup(Collection.posts)
      .withConverter<Post>(
        fromFirestore: _Converter.from,
        toFirestore: _Converter.to,
      )
      .where(Field.postId, isEqualTo: postId)
      .snapshots()
      .map((s) => s.docs.firstOrNull);
}

// ドキュメントで取得する
@riverpod
Stream<DocumentSnapshot<Post>?> userPost(
  UserPostRef ref,
  String? uid,
  String? postId,
) {
  return FirebaseFirestore.instance
      .collection(Collection.users)
      .doc(uid)
      .collection(Collection.posts)
      .doc(postId)
      .withConverter<Post>(
        fromFirestore: _Converter.from,
        toFirestore: _Converter.to,
      )
      .snapshots();
}

@riverpod
Stream<List<QueryDocumentSnapshot<Post>>> userPosts(
  UserPostsRef ref,
  String uid,
) {
  return FirebaseFirestore.instance
      .collection(Collection.users)
      .doc(uid)
      .collection(Collection.posts)
      .withConverter<Post>(
        fromFirestore: _Converter.from,
        toFirestore: _Converter.to,
      )
      .orderBy(Field.createdAt, descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.toList(),
      );
}

@riverpod
CollectionReference<Post> selfPostRef(SelfPostRefRef ref) {
  return ref
      .watch(userRefProvider)
      .collection(Collection.posts)
      .withConverter<Post>(
        fromFirestore: _Converter.from,
        toFirestore: _Converter.to,
      );
}