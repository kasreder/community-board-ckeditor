import 'dart:math';

import 'package:flutter/material.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/api.dart';
import 'boards_provider.dart';
import 'me_provider.dart';

enum PostListStatus { idle, loading, refreshing, success, failure }

enum PostDetailStatus { idle, loading, success, failure }

class PostListState {
  PostListState({
    this.status = PostListStatus.idle,
    this.errorMessage,
    this.items = const [],
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
    this.sort = 'latest',
  });

  final PostListStatus status;
  final String? errorMessage;
  final List<Post> items;
  final int page;
  final int pageSize;
  final int total;
  final String sort;

  PostListState copyWith({
    PostListStatus? status,
    String? errorMessage,
    List<Post>? items,
    int? page,
    int? pageSize,
    int? total,
    String? sort,
  }) {
    return PostListState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      sort: sort ?? this.sort,
    );
  }
}

class PostDetailState {
  PostDetailState({this.status = PostDetailStatus.idle, this.errorMessage, this.post});

  final PostDetailStatus status;
  final String? errorMessage;
  final Post? post;

  PostDetailState copyWith({
    PostDetailStatus? status,
    String? errorMessage,
    Post? post,
  }) {
    return PostDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      post: post ?? this.post,
    );
  }
}

class PostsProvider extends ChangeNotifier {
  PostsProvider(this._api, BoardsProvider boardsProvider) : _boardsProvider = boardsProvider;

  final ApiService _api;
  BoardsProvider _boardsProvider;

  final Map<String, PostListState> _boardStates = {};
  final Map<int, PostDetailState> _detailStates = {};

  void updateBoardsProvider(BoardsProvider provider) {
    _boardsProvider = provider;
  }

  PostListState getBoardState(String slug) {
    return _boardStates[slug] ?? PostListState();
  }

  PostDetailState getDetailState(int postId) {
    return _detailStates[postId] ?? PostDetailState();
  }

  Future<void> loadBoardPosts(
    String slug, {
    int page = 1,
    int limit = 10,
    String sort = 'latest',
    bool force = false,
  }) async {
    final current = _boardStates[slug];
    if (!force && current != null && current.status == PostListStatus.loading) {
      return;
    }

    _boardStates[slug] = (current ?? PostListState()).copyWith(
      status: current == null || force ? PostListStatus.loading : PostListStatus.refreshing,
      errorMessage: null,
      sort: sort,
    );
    notifyListeners();

    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/api/boards/$slug/posts',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sort': sort,
        },
      );

      final data = response.data ?? {};
      final List<Post> items = (data['items'] as List<dynamic>? ?? [])
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
      final int total = data['total'] is int
          ? data['total'] as int
          : int.tryParse('${data['total']}') ?? items.length;

      _boardStates[slug] = PostListState(
        status: PostListStatus.success,
        items: items,
        total: total,
        page: data['page'] is int ? data['page'] as int : page,
        pageSize: data['pageSize'] is int ? data['pageSize'] as int : limit,
        sort: sort,
      );
    } catch (error) {
      _boardStates[slug] = (current ?? PostListState()).copyWith(
        status: PostListStatus.failure,
        errorMessage: error.toString(),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<Post?> fetchPostDetail(int postId, {bool force = false}) async {
    final current = _detailStates[postId];
    if (!force && current != null && current.status == PostDetailStatus.loading) {
      return current.post;
    }

    _detailStates[postId] = (current ?? PostDetailState()).copyWith(
      status: PostDetailStatus.loading,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final response = await _api.get<Map<String, dynamic>>('/api/posts/$postId');
      final post = Post.fromJson(response.data!['post'] as Map<String, dynamic>);

      _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: post);
      _updateListItem(post);
      notifyListeners();
      return post;
    } catch (error) {
      _detailStates[postId] = PostDetailState(status: PostDetailStatus.failure, errorMessage: error.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<Post> createPost({
    required String slug,
    required int authorId,
    required String title,
    required String content,
    String status = 'published',
    DateTime? publishedAt,
    bool isPinned = false,
    String? thumbnailUrl,
    List<String>? tags,
    MeProvider? meProvider,
  }) async {
    final board = _boardsProvider.findBySlug(slug);
    final tempPost = Post(
      id: -Random().nextInt(1 << 31),
      boardId: board?.id ?? 0,
      authorId: authorId,
      title: title,
      content: content,
      status: status,
      isPinned: isPinned,
      viewCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      board: board,
      author: meProvider?.currentUser ?? meProvider?.fallbackUser,
      thumbnailUrl: thumbnailUrl,
      tags: tags,
      publishedAt: publishedAt,
      commentCount: 0,
      isOptimistic: true,
    );

    final listState = getBoardState(slug);
    if (listState.items.isNotEmpty) {
      _boardStates[slug] = listState.copyWith(
        items: [tempPost, ...listState.items],
      );
    } else {
      _boardStates[slug] = listState.copyWith(items: [tempPost]);
    }
    notifyListeners();

    meProvider?.applyScoreDelta(10);

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/boards/$slug/posts',
        data: {
          'author_id': authorId,
          'title': title,
          'content': content,
          'status': status,
          'published_at': publishedAt?.toIso8601String(),
          'is_pinned': isPinned,
          'thumbnail_url': thumbnailUrl,
          'tags': tags,
        },
      );

      final post = Post.fromJson(response.data!['post'] as Map<String, dynamic>);
      _replaceTempPost(slug, tempPost.id, post);
      _detailStates[post.id] = PostDetailState(status: PostDetailStatus.success, post: post);
      notifyListeners();
      return post;
    } catch (error) {
      _removePost(slug, tempPost.id);
      meProvider?.applyScoreDelta(-10);
      notifyListeners();
      rethrow;
    }
  }

  Future<Post> updatePost(
    int postId, {
    required String title,
    required String content,
    String status = 'published',
    DateTime? publishedAt,
    bool isPinned = false,
    String? thumbnailUrl,
    List<String>? tags,
  }) async {
    final previous = _detailStates[postId]?.post;

    if (previous != null) {
      final optimistic = previous.copyWith(
        title: title,
        content: content,
        status: status,
        publishedAt: publishedAt,
        isPinned: isPinned,
        thumbnailUrl: thumbnailUrl,
        tags: tags,
        isOptimistic: true,
      );
      _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: optimistic);
      _updateListItem(optimistic);
      notifyListeners();
    }

    try {
      final response = await _api.put<Map<String, dynamic>>(
        '/api/posts/$postId',
        data: {
          'title': title,
          'content': content,
          'status': status,
          'published_at': publishedAt?.toIso8601String(),
          'is_pinned': isPinned,
          'thumbnail_url': thumbnailUrl,
          'tags': tags,
        },
      );

      final post = Post.fromJson(response.data!['post'] as Map<String, dynamic>);
      _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: post);
      _updateListItem(post);
      notifyListeners();
      return post;
    } catch (error) {
      if (previous != null) {
        _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: previous);
        _updateListItem(previous);
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<Comment> addComment(
    int postId, {
    required int authorId,
    required String content,
    MeProvider? meProvider,
  }) async {
    final current = _detailStates[postId]?.post;
    if (current == null) {
      await fetchPostDetail(postId, force: true);
    }
    final target = _detailStates[postId]?.post;
    if (target == null) {
      throw StateError('Post $postId not found');
    }

    final optimisticComment = Comment(
      id: -Random().nextInt(1 << 31),
      postId: postId,
      author: meProvider?.currentUser ?? meProvider?.fallbackUser ?? target.author!,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updatedComments = [...?target.comments, optimisticComment];
    final optimisticPost = target.copyWith(
      comments: updatedComments,
      commentCount: updatedComments.length,
    );
    _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: optimisticPost);
    _updateListItem(optimisticPost);
    meProvider?.applyScoreDelta(1);
    notifyListeners();

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/posts/$postId/comments',
        data: {'author_id': authorId, 'content': content},
      );
      final comment = Comment.fromJson(response.data!['comment'] as Map<String, dynamic>);
      final mergedComments = [
        ...updatedComments.where((item) => item.id > 0),
        comment,
      ];
      final postWithServerComment = optimisticPost.copyWith(
        comments: mergedComments,
        commentCount: mergedComments.length,
      );
      _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: postWithServerComment);
      _updateListItem(postWithServerComment);
      notifyListeners();
      return comment;
    } catch (error) {
      meProvider?.applyScoreDelta(-1);
      _detailStates[postId] = PostDetailState(status: PostDetailStatus.success, post: target);
      _updateListItem(target);
      notifyListeners();
      rethrow;
    }
  }

  void _replaceTempPost(String slug, int tempId, Post replacement) {
    final current = getBoardState(slug);
    final replaced = current.items
        .map((post) => post.id == tempId ? replacement : post)
        .toList();
    _boardStates[slug] = current.copyWith(items: replaced);
  }

  void _removePost(String slug, int targetId) {
    final current = getBoardState(slug);
    final filtered = current.items.where((post) => post.id != targetId).toList();
    _boardStates[slug] = current.copyWith(items: filtered);
  }

  void _updateListItem(Post post) {
    if (post.board?.slug != null) {
      final slug = post.board!.slug;
      final current = getBoardState(slug);
      if (current.items.isEmpty) {
        return;
      }
      final updated = current.items
          .map((item) => item.id == post.id ? post : item)
          .toList();
      _boardStates[slug] = current.copyWith(items: updated);
    }
  }
}
