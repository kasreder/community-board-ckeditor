import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap, this.isNewsStyle = false});

  final Post post;
  final VoidCallback? onTap;
  final bool isNewsStyle;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('yyyy.MM.dd HH:mm');
    final publishedAt = post.publishedAt ?? post.createdAt;
    final badgeColor = post.isOptimistic ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary;

    if (isNewsStyle) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 140,
            child: Row(
              children: [
                if (post.thumbnailUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(post.thumbnailUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12)),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Chip(
                              label: const Text('고정글'),
                              labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                              backgroundColor: badgeColor,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 16, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(width: 4),
                            Text('${post.viewCount}'),
                            const SizedBox(width: 16),
                            Text(dateFormatter.format(publishedAt)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      title: Text(
        post.title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 16, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text(post.author?.nickname ?? '익명'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye, size: 16, color: Theme.of(context).colorScheme.outline),
                const SizedBox(width: 4),
                Text('${post.viewCount}'),
              ],
            ),
            Text(dateFormatter.format(publishedAt)),
            if (post.commentCount > 0) Chip(label: Text('댓글 ${post.commentCount}개')),
            if (post.isPinned)
              Chip(
                label: const Text('고정글'),
                backgroundColor: badgeColor.withOpacity(0.2),
                side: BorderSide(color: badgeColor),
              ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
