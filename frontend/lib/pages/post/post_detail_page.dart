import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/comment.dart';
import '../../providers/me_provider.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().fetchPostDetail(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsProvider = context.watch<PostsProvider>();
    final detailState = postsProvider.getDetailState(widget.postId);
    final post = detailState.post;

    return AppScaffold(
      selectedBoardSlug: post?.board?.slug,
      title: post?.title ?? '게시글 상세',
      body: Builder(
        builder: (context) {
          if (detailState.status == PostDetailStatus.loading && post == null) {
            return const LoadingView(message: '게시글을 불러오는 중입니다...');
          }

          if (detailState.status == PostDetailStatus.failure) {
            return ErrorView(
              message: detailState.errorMessage ?? '게시글을 불러오지 못했습니다.',
              onRetry: () => context.read<PostsProvider>().fetchPostDetail(widget.postId, force: true),
            );
          }

          if (post == null) {
            return const EmptyView(message: '게시글을 찾을 수 없습니다.');
          }

          final dateFormatter = DateFormat('yyyy년 MM월 dd일 HH:mm');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(label: Text(post.board?.name ?? '게시판')),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        const SizedBox(width: 4),
                        Text(post.author?.nickname ?? '익명'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.remove_red_eye, size: 18),
                        const SizedBox(width: 4),
                        Text('${post.viewCount}'),
                      ],
                    ),
                    Text(dateFormatter.format(post.publishedAt ?? post.createdAt)),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(post.content),
                  ),
                ),
                const SizedBox(height: 32),
                _CommentsSection(
                  comments: post.comments ?? const [],
                  controller: _commentController,
                  onSubmit: _handleSubmitComment,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmitComment(String content) async {
    if (content.trim().isEmpty) {
      return;
    }
    final meProvider = context.read<MeProvider>();
    final postsProvider = context.read<PostsProvider>();
    final user = meProvider.currentUser ?? meProvider.fallbackUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await postsProvider.addComment(
        widget.postId,
        authorId: user.id,
        content: content,
        meProvider: meProvider,
      );
      _commentController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성에 실패했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({
    required this.comments,
    required this.controller,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final List<Comment> comments;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('댓글 ${comments.length}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          const EmptyView(message: '첫 댓글을 남겨보세요!')
        else
          ...[
            for (final comment in comments)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(comment.author.nickname.substring(0, 1))),
                  title: Text(comment.author.nickname),
                  subtitle: Text(comment.content),
                  trailing: Text(DateFormat('MM.dd HH:mm').format(comment.createdAt)),
                ),
              ),
          ],
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              maxLines: 4,
              minLines: 2,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () {
                        onSubmit(controller.text);
                      },
                icon: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(isSubmitting ? '작성 중...' : '댓글 작성'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
