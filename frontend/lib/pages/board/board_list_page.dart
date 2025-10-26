import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/board.dart';
import '../../providers/boards_provider.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/post_card.dart';

class BoardListPage extends StatefulWidget {
  const BoardListPage({super.key, required this.slug});

  final String slug;

  @override
  State<BoardListPage> createState() => _BoardListPageState();
}

class _BoardListPageState extends State<BoardListPage> {
  String _sort = 'latest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardsProvider>().load();
      context.read<PostsProvider>().loadBoardPosts(widget.slug, sort: _sort);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BoardsProvider, PostsProvider>(
      builder: (context, boardsProvider, postsProvider, _) {
        final board = boardsProvider.findBySlug(widget.slug);

        if (board == null) {
          if (boardsProvider.state == LoadState.loading) {
            return const AppScaffold(selectedBoardSlug: null, body: LoadingView());
          }
          return AppScaffold(
            body: ErrorView(
              message: '해당 게시판을 찾을 수 없습니다.',
              onRetry: () => boardsProvider.load(force: true),
            ),
          );
        }

        final listState = postsProvider.getBoardState(widget.slug);

        return AppScaffold(
          selectedBoardSlug: widget.slug,
          title: board.name,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/post/new?slug=${widget.slug}'),
            icon: const Icon(Icons.edit),
            label: const Text('글쓰기'),
          ),
          body: RefreshIndicator(
            onRefresh: () => postsProvider.loadBoardPosts(widget.slug, sort: _sort, force: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _BoardHeader(board: board, sort: _sort, onSortChanged: _onSortChanged),
                const SizedBox(height: 16),
                if (listState.status == PostListStatus.loading && listState.items.isEmpty)
                  const LoadingView(message: '게시글을 불러오는 중입니다...')
                else if (listState.status == PostListStatus.failure && listState.items.isEmpty)
                  ErrorView(
                    message: listState.errorMessage ?? '게시글을 불러오지 못했습니다.',
                    onRetry: () => postsProvider.loadBoardPosts(widget.slug, sort: _sort, force: true),
                  )
                else if (listState.items.isEmpty)
                  EmptyView(
                    message: '첫 글을 작성해 보세요!',
                    actionLabel: '글쓰기',
                    onAction: () => context.go('/post/new?slug=${widget.slug}'),
                  )
                else
                  ...[
                    for (final post in listState.items)
                      PostCard(
                        post: post,
                        isNewsStyle: board.type == 'news',
                        onTap: () => context.go('/p/${post.id}'),
                      ),
                    if (listState.status == PostListStatus.refreshing)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSortChanged(String sort) {
    if (_sort == sort) {
      return;
    }
    setState(() => _sort = sort);
    context.read<PostsProvider>().loadBoardPosts(widget.slug, sort: sort, force: true);
  }
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({required this.board, required this.sort, required this.onSortChanged});

  final Board board;
  final String sort;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(board.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('정렬', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'latest', label: Text('최신순'), icon: Icon(Icons.schedule)),
                ButtonSegment(value: 'popular', label: Text('인기순'), icon: Icon(Icons.trending_up)),
                ButtonSegment(value: 'commented', label: Text('댓글순'), icon: Icon(Icons.forum_outlined)),
              ],
              selected: <String>{sort},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  onSortChanged(selection.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
