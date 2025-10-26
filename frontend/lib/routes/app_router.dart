import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/admin/admin_boards_page.dart';
import '../pages/admin/admin_posts_page.dart';
import '../pages/auth/sign_in_page.dart';
import '../pages/auth/sign_up_page.dart';
import '../pages/board/board_list_page.dart';
import '../pages/home/home_page.dart';
import '../pages/notifications/notifications_page.dart';
import '../pages/post/post_detail_page.dart';
import '../pages/post/post_editor_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/search/search_page.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      ),
      GoRoute(
        path: '/b/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return MaterialPage(child: BoardListPage(slug: slug));
        },
      ),
      GoRoute(
        path: '/p/:id',
        pageBuilder: (context, state) {
          final postId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MaterialPage(child: PostDetailPage(postId: postId));
        },
      ),
      GoRoute(
        path: '/post/new',
        pageBuilder: (context, state) {
          final slug = state.uri.queryParameters['slug'];
          return MaterialPage(child: PostEditorPage(boardSlug: slug));
        },
      ),
      GoRoute(
        path: '/post/edit/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return MaterialPage(child: PostEditorPage(postId: id));
        },
      ),
      GoRoute(
        path: '/admin/boards',
        pageBuilder: (context, state) => const MaterialPage(child: AdminBoardsPage()),
      ),
      GoRoute(
        path: '/admin/posts',
        pageBuilder: (context, state) => const MaterialPage(child: AdminPostsPage()),
      ),
      GoRoute(
        path: '/auth/sign-in',
        pageBuilder: (context, state) => const MaterialPage(child: SignInPage()),
      ),
      GoRoute(
        path: '/auth/sign-up',
        pageBuilder: (context, state) => const MaterialPage(child: SignUpPage()),
      ),
      GoRoute(
        path: '/me',
        pageBuilder: (context, state) => const MaterialPage(child: ProfilePage()),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => const MaterialPage(child: SearchPage()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => const MaterialPage(child: NotificationsPage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다.')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}
