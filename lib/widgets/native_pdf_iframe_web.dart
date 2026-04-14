// Web implementation: creates an html.IFrameElement and registers a view factory
// to render it via HtmlElementView.
// This file is only compiled on web (conditional export in native_pdf_iframe.dart).
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class NativePdfIframe extends StatefulWidget {
  final String url;
  const NativePdfIframe({super.key, required this.url});

  @override
  State<NativePdfIframe> createState() => _NativePdfIframeState();
}

class _NativePdfIframeState extends State<NativePdfIframe> {
  late final String _viewId;
  late final html.IFrameElement _iframe;
  bool _loaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Unique view id per widget instance to avoid registerViewFactory collisions
    _viewId = 'native-pdf-iframe-${DateTime.now().millisecondsSinceEpoch}-${widget.hashCode}';

    _iframe = html.IFrameElement()
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..setAttribute('sandbox', 'allow-same-origin allow-scripts allow-forms allow-popups')
      ..src = widget.url;

    // Listen for load/error to update internal state and hide spinner
    _iframe.onLoad.listen((_) {
      if (mounted) {
        setState(() {
          _loaded = true;
          _hasError = false;
        });
      }
    });
    _iframe.onError.listen((_) {
      if (mounted) {
        setState(() {
          _loaded = false;
          _hasError = true;
        });
      }
    });

    // Register the view factory with the unique id
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _iframe);
  }

  @override
  void didUpdateWidget(covariant NativePdfIframe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _iframe.src = widget.url;
    }
  }

  @override
  void dispose() {
    try {
      _iframe.src = 'about:blank';
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(child: HtmlElementView(viewType: _viewId)),
        if (!_loaded && !_hasError)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Carregando documento...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        if (_hasError)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image_outlined, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text('Não foi possível carregar o documento.', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => html.window.open(widget.url, '_blank'),
                    child: const Text('Abrir no navegador'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
