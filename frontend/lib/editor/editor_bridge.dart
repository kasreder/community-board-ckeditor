import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:html' as html show IFrameElement, window;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef EditorChanged = void Function(String value);

class WebCKEditor extends StatefulWidget {
  const WebCKEditor({super.key, required this.initialValue, required this.onChanged});

  final String initialValue;
  final EditorChanged onChanged;

  @override
  State<WebCKEditor> createState() => _WebCKEditorState();
}

class _WebCKEditorState extends State<WebCKEditor> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'ckeditor-${DateTime.now().millisecondsSinceEpoch}';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'assets/editor/index.html'
        ..style.border = '0';

      html.window.addEventListener('message', (event) {
        final dynamic data = event is html.MessageEvent ? event.data : null;
        if (data is Map && data['type'] == 'ckeditor.change') {
          widget.onChanged(data['payload'] as String);
        }
      });

      iframe.onLoad.listen((_) {
        iframe.contentWindow?.postMessage({
          'type': 'ckeditor.setData',
          'payload': widget.initialValue,
        }, '*');
      });

      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

class MobileCKEditor extends StatefulWidget {
  const MobileCKEditor({super.key, required this.initialValue, required this.onChanged});

  final String initialValue;
  final EditorChanged onChanged;

  @override
  State<MobileCKEditor> createState() => _MobileCKEditorState();
}

class _MobileCKEditorState extends State<MobileCKEditor> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('MobileCKEditor는 모바일 플랫폼에서만 동작합니다.'));
    }

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri('about:blank')),
      initialSettings: InAppWebViewSettings(
        allowsInlineMediaPlayback: true,
        javaScriptEnabled: true,
      ),
      onWebViewCreated: (controller) async {
        _controller = controller;
        controller.addJavaScriptHandler(
          handlerName: 'editorChange',
          callback: (arguments) {
            if (arguments.isNotEmpty) {
              widget.onChanged(arguments.first as String);
            }
            return null;
          },
        );
        await controller.loadFile(assetFilePath: 'assets/editor/index.html');
      },
      onLoadStop: (controller, _) async {
        final encoded = jsonEncode(widget.initialValue);
        await controller.evaluateJavascript(
          source: 'window.dispatchEvent(new MessageEvent(\'message\', { data: { type: \'ckeditor.setData\', payload: $encoded } }));',
        );
      },
    );
  }
}

class EditorApi {
  const EditorApi(this.controller);
  final InAppWebViewController controller;

  Future<void> setHtml(String html) async {
    final encoded = jsonEncode(html);
    await controller.evaluateJavascript(
      source: 'window.dispatchEvent(new MessageEvent(\'message\', { data: { type: \'ckeditor.setData\', payload: $encoded } }));',
    );
  }
}
