import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../editor/editor_bridge.dart';
import '../../providers/boards_provider.dart';
import '../../providers/me_provider.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

class PostEditorPage extends StatefulWidget {
  const PostEditorPage({super.key, this.boardSlug, this.postId});

  final String? boardSlug;
  final int? postId;

  bool get isEditing => postId != null;

  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _tagsController = TextEditingController();
  String? _selectedSlug;
  DateTime? _publishedAt;
  bool _isPinned = false;
  String _status = 'published';
  String _content = '';
  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<BoardsProvider>();
      await provider.load();
      if (widget.isEditing && widget.postId != null) {
        final detail = await context.read<PostsProvider>().fetchPostDetail(widget.postId!, force: true);
        if (detail != null) {
          _titleController.text = detail.title;
          _thumbnailController.text = detail.thumbnailUrl ?? '';
          _tagsController.text = detail.tags?.join(', ') ?? '';
          _isPinned = detail.isPinned;
          _status = detail.status;
          _publishedAt = detail.publishedAt;
          _content = detail.content;
          _selectedSlug = detail.board?.slug ?? widget.boardSlug;
        }
      }
      final availableBoards = provider.boards;
      _selectedSlug ??= widget.boardSlug ?? (availableBoards.isNotEmpty ? availableBoards.first.slug : null);
      setState(() => _initialized = true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _thumbnailController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boardsProvider = context.watch<BoardsProvider>();
    final selectedBoard = _selectedSlug != null ? boardsProvider.findBySlug(_selectedSlug!) : null;

    if (!_initialized) {
      return const AppScaffold(body: LoadingView(message: '편집기를 준비 중입니다...'));
    }

    if (_selectedSlug != null && selectedBoard == null && !widget.isEditing) {
      return AppScaffold(
        body: ErrorView(
          message: '게시판 정보를 불러오지 못했습니다.',
          onRetry: () => context.read<BoardsProvider>().load(force: true),
        ),
      );
    }

    final boards = boardsProvider.boards;

    return AppScaffold(
      title: widget.isEditing ? '글 수정' : '새 글 작성',
      selectedBoardSlug: _selectedSlug,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSlug ?? (boards.isNotEmpty ? boards.first.slug : null),
                decoration: const InputDecoration(labelText: '게시판 선택'),
                items: [
                  for (final board in boards)
                    DropdownMenuItem(
                      value: board.slug,
                      child: Text(board.name),
                    ),
                ],
                onChanged: widget.isEditing
                    ? null
                    : (value) {
                        setState(() => _selectedSlug = value);
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (value) => value == null || value.trim().isEmpty ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              _EditorField(
                initialValue: _content,
                onChanged: (value) => _content = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thumbnailController,
                decoration: const InputDecoration(labelText: '썸네일 URL (선택)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: '태그 (콤마로 구분)'),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
                title: const Text('상단 고정'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: '상태'),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('임시 저장')), 
                  DropdownMenuItem(value: 'published', child: Text('발행')), 
                  DropdownMenuItem(value: 'archived', child: Text('보관')),
                ],
                onChanged: (value) => setState(() => _status = value ?? 'published'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: '발행일 (선택)'),
                      child: Text(_publishedAt != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(_publishedAt!)
                          : '선택되지 않음'),
                    ),
                  ),
                  IconButton(
                    tooltip: '발행일 선택',
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _publishedAt ?? now,
                        firstDate: DateTime(now.year - 1),
                        lastDate: DateTime(now.year + 2),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_publishedAt ?? now),
                        );
                        if (time != null) {
                          setState(() {
                            _publishedAt = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  if (_publishedAt != null)
                    IconButton(
                      tooltip: '발행일 초기화',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _publishedAt = null),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(boardsProvider),
                  icon: _isSubmitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_isSubmitting ? '저장 중...' : '저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BoardsProvider boardsProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('본문을 입력하세요.')));
      return;
    }

    final meProvider = context.read<MeProvider>();
    final postsProvider = context.read<PostsProvider>();
    final user = meProvider.currentUser ?? meProvider.fallbackUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final slug = _selectedSlug ?? widget.boardSlug ??
        (boardsProvider.boards.isNotEmpty ? boardsProvider.boards.first.slug : null);
    if (slug == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('게시판을 선택하세요.')));
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    setState(() => _isSubmitting = true);

    try {
      if (widget.isEditing && widget.postId != null) {
        await postsProvider.updatePost(
          widget.postId!,
          title: _titleController.text,
          content: _content,
          status: _status,
          publishedAt: _publishedAt,
          isPinned: _isPinned,
          thumbnailUrl: _thumbnailController.text.isEmpty ? null : _thumbnailController.text,
          tags: tags,
        );
        if (mounted) {
          if (context.mounted) {
            context.go('/p/${widget.postId}');
          }
        }
      } else {
        final post = await postsProvider.createPost(
          slug: slug,
          authorId: user.id,
          title: _titleController.text,
          content: _content,
          status: _status,
          publishedAt: _publishedAt,
          isPinned: _isPinned,
          thumbnailUrl: _thumbnailController.text.isEmpty ? null : _thumbnailController.text,
          tags: tags,
          meProvider: meProvider,
        );
        if (mounted) {
          context.go('/p/${post.id}');
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장에 실패했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _EditorField extends StatelessWidget {
  const _EditorField({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: kIsWeb
            ? WebCKEditor(initialValue: initialValue, onChanged: onChanged)
            : MobileCKEditor(initialValue: initialValue, onChanged: onChanged),
      ),
    );
  }
}
