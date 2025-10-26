import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const PlaceholderHome(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다.')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}
