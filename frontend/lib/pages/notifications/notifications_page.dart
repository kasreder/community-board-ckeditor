import 'package:flutter/material.dart';

import '../../widgets/app_scaffold.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '알림',
      selectedRoute: '/notifications',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_off_outlined, size: 64),
            SizedBox(height: 16),
            Text('알림 기능은 추후 구현 예정입니다.'),
          ],
        ),
      ),
    );
  }
}
