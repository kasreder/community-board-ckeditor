import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api);

  final ApiService _api;

  CurrentUser? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  CurrentUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;

  Map<String, String> get authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> login(String email, String password) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data ?? {};
      _token = data['token'] as String?;
      if (data['user'] != null) {
        _currentUser = CurrentUser.fromJson(data['user'] as Map<String, dynamic>);
      }
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  void updateProfile(CurrentUser user) {
    _currentUser = user;
    notifyListeners();
  }
}
