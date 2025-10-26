import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/boards_provider.dart';
import 'providers/me_provider.dart';
import 'providers/posts_provider.dart';
import 'routes/app_router.dart';
import 'services/api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(CommunityBoardApp(apiService: apiService));
}

class CommunityBoardApp extends StatelessWidget {
  const CommunityBoardApp({super.key, required this.apiService});

  final ApiService apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => BoardsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => MeProvider(apiService)),
        ChangeNotifierProxyProvider<BoardsProvider, PostsProvider>(
          create: (context) => PostsProvider(apiService, context.read<BoardsProvider>()),
          update: (_, boardsProvider, previous) {
            final provider = previous ?? PostsProvider(apiService, boardsProvider);
            provider.updateBoardsProvider(boardsProvider);
            return provider;
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Community Board',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        routerConfig: createRouter(),
        supportedLocales: const [Locale('ko'), Locale('en')],
        locale: const Locale('ko'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
