import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email, required this.role, this.avatarUrl});

  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AuthProvider extends InheritedWidget {
  const AuthProvider({required this.state, required super.child, super.key});

  final _AuthState state;

  static _AuthState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null, 'AuthProvider not found');
    return provider!.state;
  }

  @override
  bool updateShouldNotify(covariant AuthProvider oldWidget) => oldWidget.state != state;
}

class AuthProviderScope extends StatefulWidget {
  const AuthProviderScope({required this.child, super.key});

  final Widget child;

  @override
  State<AuthProviderScope> createState() => _AuthProviderScopeState();
}

class _AuthProviderScopeState extends State<AuthProviderScope> {
  final _authState = _AuthState();

  @override
  Widget build(BuildContext context) {
    return AuthProvider(state: _authState, child: widget.child);
  }
}

class _AuthState {
  AuthUser? currentUser;
  String? _token;

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:4000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('로그인 실패: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    currentUser = AuthUser.fromJson(data['user'] as Map<String, dynamic>);
    _token = data['token'] as String;
  }

  Future<void> logout() async {
    currentUser = null;
    _token = null;
  }

  Map<String, String> get authHeaders => {
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
