import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/board.dart';
import '../providers/boards_provider.dart';
import '../providers/me_provider.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.selectedRoute,
    this.selectedBoardSlug,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;
  final String? selectedRoute;
  final String? selectedBoardSlug;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final boardsProvider = context.watch<BoardsProvider>();
    final boards = boardsProvider.visibleBoards;
    final destinations = _buildDestinations(context, boards);
    final selectedIndex = _findSelectedIndex(destinations);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth <= 640;
        return Scaffold(
          appBar: AppBar(
            title: Text(title ?? '커뮤니티 보드'),
            actions: [
              IconButton(
                tooltip: '검색',
                onPressed: () => context.go('/search'),
                icon: const Icon(Icons.search),
              ),
              IconButton(
                tooltip: '알림',
                onPressed: () => context.go('/notifications'),
                icon: const Icon(Icons.notifications_outlined),
              ),
              _ProfileButton(),
            ],
          ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onDestinationSelected(context, destinations[index]),
                  destinations: [
                    for (final destination in destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        label: destination.label,
                        tooltip: destination.tooltip,
                      ),
                  ],
                )
              : null,
          body: Row(
            children: [
              if (!isCompact)
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onDestinationSelected(context, destinations[index]),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final destination in destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        label: Text(destination.label),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                  ],
                ),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }

  List<_NavigationDestination> _buildDestinations(BuildContext context, List<Board> boards) {
    final items = <_NavigationDestination>[
      const _NavigationDestination(
        label: '홈',
        route: '/',
        icon: Icons.home_outlined,
        tooltip: '홈으로 이동',
      ),
      for (final board in boards)
        _NavigationDestination(
          label: board.name,
          route: '/b/${board.slug}',
          icon: Icons.topic_outlined,
          tooltip: '${board.name} 게시판',
          boardSlug: board.slug,
        ),
      const _NavigationDestination(
        label: '프로필',
        route: '/me',
        icon: Icons.person_outline,
        tooltip: '내 프로필 보기',
      ),
    ];
    return items;
  }

  int _findSelectedIndex(List<_NavigationDestination> destinations) {
    final indexByBoard = selectedBoardSlug != null
        ? destinations.indexWhere((destination) => destination.boardSlug == selectedBoardSlug)
        : -1;
    if (indexByBoard != -1) {
      return indexByBoard;
    }
    final indexByRoute = selectedRoute != null
        ? destinations.indexWhere((destination) => destination.route == selectedRoute)
        : -1;
    return indexByRoute != -1 ? indexByRoute : 0;
  }

  void _onDestinationSelected(BuildContext context, _NavigationDestination destination) {
    if (destination.route != null) {
      context.go(destination.route!);
    }
  }
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.tooltip,
    this.boardSlug,
  });

  final String label;
  final String? route;
  final IconData icon;
  final String tooltip;
  final String? boardSlug;
}

class _ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final meProvider = context.watch<MeProvider>();
    final user = meProvider.currentUser ?? meProvider.fallbackUser;

    return Tooltip(
      message: '프로필 (점수 ${user?.score ?? 0})',
      child: IconButton(
        onPressed: () => context.go('/me'),
        icon: CircleAvatar(
          radius: 16,
          child: Text(user?.nickname.substring(0, 1) ?? '나'),
        ),
      ),
    );
  }
}
