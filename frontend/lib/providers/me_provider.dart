import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api.dart';

enum MeStatus { idle, loading, success, failure }

class MeProvider extends ChangeNotifier {
  MeProvider(this._api);

  final ApiService _api;

  MeStatus status = MeStatus.idle;
  String? errorMessage;
  CurrentUser? currentUser;
  CurrentUser? fallbackUser = const CurrentUser(id: 1, nickname: '게스트', score: 0);

  Future<void> load() async {
    if (status == MeStatus.loading) {
      return;
    }

    status = MeStatus.loading;
    notifyListeners();

    try {
      final response = await _api.get<Map<String, dynamic>>('/api/me');
      if (response.data != null && response.data!['user'] != null) {
        currentUser = CurrentUser.fromJson(response.data!['user'] as Map<String, dynamic>);
      }
      status = MeStatus.success;
    } catch (error) {
      // API가 아직 준비되지 않았을 수 있으므로 graceful degrade
      errorMessage = error.toString();
      status = MeStatus.failure;
    } finally {
      notifyListeners();
    }
  }

  void applyScoreDelta(int delta) {
    if (currentUser != null) {
      currentUser = CurrentUser(
        id: currentUser!.id,
        nickname: currentUser!.nickname,
        score: currentUser!.score + delta,
        email: currentUser!.email,
        avatarUrl: currentUser!.avatarUrl,
      );
    } else if (fallbackUser != null) {
      fallbackUser = CurrentUser(
        id: fallbackUser!.id,
        nickname: fallbackUser!.nickname,
        score: fallbackUser!.score + delta,
        email: fallbackUser!.email,
        avatarUrl: fallbackUser!.avatarUrl,
      );
    }
    notifyListeners();
  }
}
