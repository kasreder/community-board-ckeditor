import 'board.dart';
import 'comment.dart';
import 'user.dart';

class Post {
  Post({
    required this.id,
    required this.boardId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.status,
    required this.isPinned,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.board,
    this.author,
    this.thumbnailUrl,
    this.tags,
    this.publishedAt,
    this.commentCount = 0,
    this.comments,
    this.isOptimistic = false,
  });

  final int id;
  final int boardId;
  final int authorId;
  final String title;
  final String content;
  final String status;
  final bool isPinned;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Board? board;
  final UserSummary? author;
  final String? thumbnailUrl;
  final List<String>? tags;
  final DateTime? publishedAt;
  final int commentCount;
  final List<Comment>? comments;
  final bool isOptimistic;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      boardId: json['board_id'] as int,
      authorId: json['author_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      status: json['status'] as String? ?? 'published',
      isPinned: (json['is_pinned'] as bool?) ?? false,
      viewCount: json['view_count'] is int
          ? json['view_count'] as int
          : int.tryParse('${json['view_count']}') ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      board: json['board'] != null
          ? Board.fromJson(json['board'] as Map<String, dynamic>)
          : null,
      author: json['author'] != null
          ? UserSummary.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      tags: _mapTags(json['tags']),
      publishedAt: _parseDate(json['published_at']),
      commentCount: json['comment_count'] is int
          ? json['comment_count'] as int
          : int.tryParse('${json['comment_count']}') ??
              (json['comments'] is List ? (json['comments'] as List).length : 0),
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
              .map((item) => Comment.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'board_id': boardId,
      'author_id': authorId,
      'title': title,
      'content': content,
      'status': status,
      'is_pinned': isPinned,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'board': board?.toJson(),
      'author': author?.toJson(),
      'thumbnail_url': thumbnailUrl,
      'tags': tags,
      'published_at': publishedAt?.toIso8601String(),
      'comment_count': commentCount,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
    };
  }

  Post copyWith({
    int? id,
    int? boardId,
    int? authorId,
    String? title,
    String? content,
    String? status,
    bool? isPinned,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Board? board,
    UserSummary? author,
    String? thumbnailUrl,
    List<String>? tags,
    DateTime? publishedAt,
    int? commentCount,
    List<Comment>? comments,
    bool? isOptimistic,
  }) {
    return Post(
      id: id ?? this.id,
      boardId: boardId ?? this.boardId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      status: status ?? this.status,
      isPinned: isPinned ?? this.isPinned,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      board: board ?? this.board,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      publishedAt: publishedAt ?? this.publishedAt,
      commentCount: commentCount ?? this.commentCount,
      comments: comments ?? this.comments,
      isOptimistic: isOptimistic ?? this.isOptimistic,
    );
  }

  static List<String>? _mapTags(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }

    return raw.toString().split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
