import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/board.dart';
import '../../providers/boards_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class AdminBoardsPage extends StatefulWidget {
  const AdminBoardsPage({super.key});

  @override
  State<AdminBoardsPage> createState() => _AdminBoardsPageState();
}

class _AdminBoardsPageState extends State<AdminBoardsPage> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardsProvider>().load(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardsProvider = context.watch<BoardsProvider>();
    final boards = boardsProvider.boards;

    return AppScaffold(
      title: '게시판 관리',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : () => _showBoardDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('게시판 추가'),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (boardsProvider.state == LoadState.loading && boards.isEmpty) {
                  return const LoadingView(message: '게시판 목록을 불러오는 중입니다...');
                }
                if (boardsProvider.state == LoadState.failure && boards.isEmpty) {
                  return ErrorView(
                    message: boardsProvider.errorMessage ?? '게시판 정보를 불러오지 못했습니다.',
                    onRetry: () => boardsProvider.load(force: true),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    return Card(
                      child: ListTile(
                        title: Text(board.name),
                        subtitle: Text('${board.slug} · ${board.type}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              tooltip: '수정',
                              icon: const Icon(Icons.edit),
                              onPressed: _isProcessing
                                  ? null
                                  : () => _showBoardDialog(context, board: board),
                            ),
                            IconButton(
                              tooltip: '삭제',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: _isProcessing
                                  ? null
                                  : () => _confirmDeleteBoard(context, board),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: boards.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBoardDialog(BuildContext context, {Board? board}) async {
    final nameController = TextEditingController(text: board?.name ?? '');
    final slugController = TextEditingController(text: board?.slug ?? '');
    final orderController = TextEditingController(text: (board?.orderNo ?? 0).toString());
    String type = board?.type ?? 'custom';
    bool isHidden = board?.isHidden ?? false;
    bool isPrivate = board?.isPrivate ?? false;

    final formKey = GlobalKey<FormState>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(board == null ? '게시판 추가' : '게시판 수정'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: '이름'),
                          validator: (value) => value == null || value.isEmpty ? '이름을 입력하세요.' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: slugController,
                          decoration: const InputDecoration(labelText: '슬러그'),
                          enabled: board == null,
                          validator: (value) => value == null || value.isEmpty ? '슬러그를 입력하세요.' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: type,
                          decoration: const InputDecoration(labelText: '유형'),
                          items: const [
                            DropdownMenuItem(value: 'news', child: Text('뉴스형')),
                            DropdownMenuItem(value: 'lab', child: Text('실험형')),
                            DropdownMenuItem(value: 'free', child: Text('자유형')),
                            DropdownMenuItem(value: 'custom', child: Text('기타')),
                          ],
                          onChanged: (value) => setDialogState(() => type = value ?? 'custom'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: orderController,
                          decoration: const InputDecoration(labelText: '정렬 순서'),
                          keyboardType: TextInputType.number,
                        ),
                        SwitchListTile(
                          title: const Text('숨김'),
                          value: isHidden,
                          onChanged: (value) => setDialogState(() => isHidden = value),
                        ),
                        SwitchListTile(
                          title: const Text('비공개'),
                          value: isPrivate,
                          onChanged: (value) => setDialogState(() => isPrivate = value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final provider = context.read<BoardsProvider>();
      final orderNo = int.tryParse(orderController.text) ?? 0;
      if (board == null) {
        await provider.createBoard(
          name: nameController.text,
          slug: slugController.text,
          type: type,
          orderNo: orderNo,
          isHidden: isHidden,
          isPrivate: isPrivate,
        );
      } else {
        await provider.updateBoard(board, {
          'name': nameController.text,
          'type': type,
          'order_no': orderNo,
          'is_hidden': isHidden,
          'is_private': isPrivate,
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $error')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmDeleteBoard(BuildContext context, Board board) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시판 삭제'),
          content: Text('정말로 "${board.name}" 게시판을 삭제하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await context.read<BoardsProvider>().deleteBoard(board.id);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $error')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
