import 'dart:convert';

class Board {
  Board({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.isPrivate,
    required this.isHidden,
    required this.orderNo,
    this.settings,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String slug;
  final String type;
  final bool isPrivate;
  final bool isHidden;
  final int orderNo;
  final Map<String, dynamic>? settings;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      type: json['type'] as String? ?? 'custom',
      isPrivate: (json['is_private'] as bool?) ?? false,
      isHidden: (json['is_hidden'] as bool?) ?? false,
      orderNo: json['order_no'] is int
          ? json['order_no'] as int
          : int.tryParse('${json['order_no']}') ?? 0,
      settings: _decodeSettings(json['settings']),
      createdBy: json['created_by'] as int?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'is_private': isPrivate,
      'is_hidden': isHidden,
      'order_no': orderNo,
      'settings': settings,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Board copyWith({
    int? id,
    String? name,
    String? slug,
    String? type,
    bool? isPrivate,
    bool? isHidden,
    int? orderNo,
    Map<String, dynamic>? settings,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      isPrivate: isPrivate ?? this.isPrivate,
      isHidden: isHidden ?? this.isHidden,
      orderNo: orderNo ?? this.orderNo,
      settings: settings ?? this.settings,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Map<String, dynamic>? _decodeSettings(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
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
