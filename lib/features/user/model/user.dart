import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_converter_helper/json_converter_helper.dart';

part 'user.freezed.dart';
part 'user.g.dart';

const _serializable = JsonSerializable(
  converters: [
    ...firestoreJsonConverters,
    ...allJsonConverters,
  ],
);

@Collection<User>('users')
@Collection<Post>('users/*/posts')
@freezed
class User with _$User {
  @_serializable
  const factory User({
    @Id() required String id,
    required String name,
    required String email,
    required String? photoUrl,
    @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp updatedAt,
    @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

final usersRef = UserCollectionReference();

@freezed
class Post with _$Post {
  @_serializable
  factory Post({
    // コレクショングループで引くためにdocument IDが必要だが、フォーム登録時点では
    // ドキュメントIDが決まらないのでnullableにしておく。利用時には`late final`の非null版を利用すること。
    @Deprecated('Use late field `id` instead') @Id() String? nullableId,
    required String title,
    required String description,
    @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp updatedAt,
    @Default(UnionTimestamp.serverTimestamp()) UnionTimestamp createdAt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Post._();

  // ignore: deprecated_member_use_from_same_package
  late final String id = nullableId!;
}

final postsQuery =
    FirebaseFirestore.instance.collectionGroup('posts').withConverter(
          fromFirestore: (snap, _) => Post.fromJson(snap.data()!).copyWith(
            nullableId: snap.id,
          ),
          toFirestore: (post, _) => post.toJson(),
        );
