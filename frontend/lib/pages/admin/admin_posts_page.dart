import 'package:flutter/material.dart';

import '../../widgets/app_scaffold.dart';

class AdminPostsPage extends StatelessWidget {
  const AdminPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '게시글 관리',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.build_circle_outlined, size: 64),
            SizedBox(height: 16),
            Text('게시글 일괄 작업 페이지는 추후 구현 예정입니다.'),
          ],
        ),
      ),
    );
  }
}
