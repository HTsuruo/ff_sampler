import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nippo/common/common.dart';
import 'package:nippo/features/post/post_provider.dart';
import 'package:nippo/logger.dart';

import 'post.dart';

class PostListView extends ConsumerWidget {
  const PostListView({super.key, this.uid});

  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = this.uid;
    // TODO(htsuruo): Providerを分けずにまとめても良いかも
    final snapshots = uid == null
        ? ref.watch(postsProvider).value
        : ref.watch(userPostsProvider(uid)).value;
    return snapshots == null
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshots.length,
            itemBuilder: (context, index) => _PostCard(snapshots[index]),
          );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard(this.postSnapshot);

  final QueryDocumentSnapshot<Post> postSnapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final post = postSnapshot.data();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          logger.info(postSnapshot.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      post.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(2),
                    Text(
                      // ServerTimestamp確定まで微妙にラグがあるため暫定的に空文字でごまかす
                      post.createdAt.date?.formatted ?? '',
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.navigate_next, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
