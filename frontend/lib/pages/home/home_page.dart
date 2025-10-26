import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/boards_provider.dart';
import '../../providers/me_provider.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> _requestedBoards = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardsProvider>().load();
      context.read<MeProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      selectedRoute: '/',
      body: Consumer2<BoardsProvider, PostsProvider>(
        builder: (context, boardsProvider, postsProvider, _) {
          final boardsState = boardsProvider.state;

          if (boardsState == LoadState.loading && boardsProvider.boards.isEmpty) {
            return const LoadingView(message: '게시판 정보를 불러오는 중입니다...');
          }

          if (boardsState == LoadState.failure && boardsProvider.boards.isEmpty) {
            return ErrorView(
              message: boardsProvider.errorMessage ?? '게시판 정보를 불러오지 못했습니다.',
              onRetry: () => boardsProvider.load(force: true),
            );
          }

          if (boardsProvider.boards.isEmpty) {
            return const EmptyView(message: '등록된 게시판이 없습니다.');
          }

          return RefreshIndicator(
            onRefresh: () async {
              await boardsProvider.load(force: true);
              for (final board in boardsProvider.boards) {
                await postsProvider.loadBoardPosts(board.slug, limit: 5, force: true);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: boardsProvider.boards.length,
              itemBuilder: (context, index) {
                final board = boardsProvider.boards[index];
                _ensureBoardPosts(board.slug);
                final listState = postsProvider.getBoardState(board.slug);

                Widget content;
                if (listState.status == PostListStatus.loading && listState.items.isEmpty) {
                  content = const LoadingView();
                } else if (listState.status == PostListStatus.failure && listState.items.isEmpty) {
                  content = ErrorView(
                    message: listState.errorMessage ?? '게시글을 불러오지 못했습니다.',
                    onRetry: () => postsProvider.loadBoardPosts(board.slug, limit: 5, force: true),
                  );
                } else if (listState.items.isEmpty) {
                  content = EmptyView(
                    message: '아직 글이 없습니다. 첫 글을 작성해 보세요!',
                    actionLabel: '글쓰기',
                    onAction: () => context.go('/post/new?slug=${board.slug}'),
                  );
                } else {
                  content = Column(
                    children: [
                      for (final post in listState.items.take(5))
                        PostCard(
                          post: post,
                          isNewsStyle: board.type == 'news',
                          onTap: () => context.go('/p/${post.id}'),
                        ),
                    ],
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              board.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () => context.go('/b/${board.slug}'),
                              child: const Text('더보기'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        content,
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _ensureBoardPosts(String slug) {
    if (_requestedBoards.add(slug)) {
      context.read<PostsProvider>().loadBoardPosts(slug, limit: 5);
    }
  }
}
