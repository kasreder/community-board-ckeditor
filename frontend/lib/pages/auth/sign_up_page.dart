import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_scaffold.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '회원가입',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt, size: 64),
                  const SizedBox(height: 16),
                  const Text('회원가입은 관리자 콘솔에서 진행하세요.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/auth/sign-in'),
                    child: const Text('로그인 화면으로 이동'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
