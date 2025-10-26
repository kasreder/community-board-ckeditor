import 'package:flutter/material.dart';

import '../models/board.dart';
import '../services/api.dart';

enum LoadState { idle, loading, success, failure }

class BoardsProvider extends ChangeNotifier {
  BoardsProvider(this._api);

  final ApiService _api;

  LoadState state = LoadState.idle;
  String? errorMessage;
  DateTime? _lastFetchedAt;
  final List<Board> _boards = [];

  List<Board> get boards => List.unmodifiable(_boards);
  List<Board> get visibleBoards => _boards.where((board) => !board.isHidden).toList()
    ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

  Future<void> load({bool force = false}) async {
    if (!force && state == LoadState.loading) {
      return;
    }

    if (!force && _boards.isNotEmpty && _lastFetchedAt != null && DateTime.now().difference(_lastFetchedAt!) < const Duration(minutes: 5)) {
      return;
    }

    state = LoadState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.get<Map<String, dynamic>>('/api/boards');
      final data = response.data ?? {};
      final items = (data['boards'] as List<dynamic>? ?? [])
          .map((item) => Board.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orderNo.compareTo(b.orderNo));

      _boards
        ..clear()
        ..addAll(items);
      state = LoadState.success;
      _lastFetchedAt = DateTime.now();
    } catch (error) {
      state = LoadState.failure;
      errorMessage = error.toString();
    } finally {
      notifyListeners();
    }
  }

  Board? findBySlug(String slug) {
    try {
      return _boards.firstWhere((board) => board.slug == slug);
    } catch (_) {
      return null;
    }
  }

  Future<Board?> createBoard({
    required String name,
    required String slug,
    String type = 'custom',
    bool isPrivate = false,
    bool isHidden = false,
    int orderNo = 0,
    Map<String, dynamic>? settings,
  }) async {
    final payload = {
      'name': name,
      'slug': slug,
      'type': type,
      'is_private': isPrivate,
      'is_hidden': isHidden,
      'order_no': orderNo,
      'settings': settings,
    };

    try {
      final response = await _api.post<Map<String, dynamic>>('/api/boards', data: payload);
      final board = Board.fromJson(response.data!['board'] as Map<String, dynamic>);
      _boards.add(board);
      _boards.sort((a, b) => a.orderNo.compareTo(b.orderNo));
      notifyListeners();
      return board;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Board?> updateBoard(Board board, Map<String, dynamic> changes) async {
    try {
      final response = await _api.put<Map<String, dynamic>>('/api/boards/${board.id}', data: changes);
      final updated = Board.fromJson(response.data!['board'] as Map<String, dynamic>);
      final index = _boards.indexWhere((element) => element.id == board.id);
      if (index != -1) {
        _boards[index] = updated;
        _boards.sort((a, b) => a.orderNo.compareTo(b.orderNo));
        notifyListeners();
      }
      return updated;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBoard(int boardId) async {
    try {
      await _api.delete<void>('/api/boards/$boardId');
      _boards.removeWhere((board) => board.id == boardId);
      notifyListeners();
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }
}
