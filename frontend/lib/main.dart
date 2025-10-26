import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'editor/editor_bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CommunityBoardApp());
}

class CommunityBoardApp extends StatelessWidget {
  const CommunityBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProviderScope(
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
        supportedLocales: const [Locale('en'), Locale('ko')],
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

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Board'),
        actions: [
          if (auth.currentUser != null)
            IconButton(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Row(
            children: [
              if (isWide)
                const Expanded(
                  flex: 1,
                  child: _BoardSidebar(),
                ),
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      Text(
                        'CKEditor 5 통합 예시',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '이 화면은 Flutter와 CKEditor 5가 통신하는 방법을 보여줍니다. 실제 데이터 연동은 providers/auth_provider.dart와 services를 확장하여 구현하세요.',
                      ),
                      SizedBox(height: 24),
                      CKEditorPanel(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BoardSidebar extends StatelessWidget {
  const _BoardSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('게시판 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('공지사항 (notice)'),
          Text('자유게시판 (free)'),
          Text('기술게시판 (tech)'),
          Text('사진게시판 (photo)'),
        ],
      ),
    );
  }
}

class CKEditorPanel extends StatefulWidget {
  const CKEditorPanel({super.key});

  @override
  State<CKEditorPanel> createState() => _CKEditorPanelState();
}

class _CKEditorPanelState extends State<CKEditorPanel> {
  String _content = '<p>안녕하세요! CKEditor 5 입니다.</p>';

  void _onChanged(String value) {
    setState(() => _content = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: kIsWeb
              ? WebCKEditor(
                  initialValue: _content,
                  onChanged: _onChanged,
                )
              : MobileCKEditor(
                  initialValue: _content,
                  onChanged: _onChanged,
                ),
        ),
        const SizedBox(height: 16),
        const Text('현재 HTML 미리보기'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_content),
        ),
      ],
    );
  }
}
