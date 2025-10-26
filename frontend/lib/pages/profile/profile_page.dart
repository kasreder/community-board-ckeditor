import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/me_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/loading_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeProvider>(
      builder: (context, meProvider, _) {
        final user = meProvider.currentUser ?? meProvider.fallbackUser;
        if (meProvider.status == MeStatus.loading && user == null) {
          return const AppScaffold(selectedRoute: '/me', body: LoadingView());
        }

        return AppScaffold(
          selectedRoute: '/me',
          title: '내 프로필',
          body: Center(
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 32, child: Text(user?.nickname.substring(0, 1) ?? '?')),
                    const SizedBox(height: 16),
                    Text(user?.nickname ?? '사용자', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(user?.email ?? '이메일 정보 없음'),
                    const SizedBox(height: 16),
                    Chip(label: Text('점수 ${user?.score ?? 0}')), 
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
