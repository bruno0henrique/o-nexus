import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nexus_engine/widgets/native_pdf_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nexus_engine/theme/app_theme.dart';

class StoreInspectionScreen extends StatefulWidget {
  final String contractName;
  final String pdfUrl;
  final VoidCallback? onBack;

  const StoreInspectionScreen({
    super.key,
    required this.contractName,
    required this.pdfUrl,
    this.onBack,
  });

  @override
  State<StoreInspectionScreen> createState() => _StoreInspectionScreenState();
}

class _StoreInspectionScreenState extends State<StoreInspectionScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void didUpdateWidget(StoreInspectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfUrl != widget.pdfUrl) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
  }

  Future<void> _openExternal({bool download = false}) async {
    final uri = Uri.parse(widget.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: download
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o PDF.'),
            backgroundColor: AppTheme.criticalRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(),
        const Divider(height: 1, color: AppTheme.accentGray),
        Expanded(child: _buildPdfArea()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppTheme.darkerPanel,
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryTeal, size: 20),
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
            tooltip: 'Voltar à lista',
          ),
          const SizedBox(width: 6),
          const Icon(Icons.description_outlined, color: AppTheme.primaryTeal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.contractName,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Download
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textWhite,
              side: const BorderSide(color: AppTheme.accentGray),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              textStyle: const TextStyle(fontSize: 12),
            ),
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Download'),
            onPressed: () => _openExternal(download: true),
          ),
          const SizedBox(width: 8),
          // Visualizar Maior
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal20,
              foregroundColor: AppTheme.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              elevation: 0,
            ),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Visualizar Maior'),
            onPressed: () => _openExternal(download: false),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfArea() {
    final url = widget.pdfUrl.trim();

    // Empty state — nenhum PDF anexado
    if (url.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.document_scanner,
              color: AppTheme.textGray.withValues(alpha: 0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum contrato digital anexado',
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anexe um PDF ao registrar ou editar a loja.',
              style: TextStyle(color: AppTheme.textGray, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Use native iframe on web for browser's PDF engine
    if (kIsWeb) {
      var iframeUrl = url;
      if (!iframeUrl.contains('#')) {
        iframeUrl = '$iframeUrl#toolbar=0&view=FitH';
      } else {
        iframeUrl = '$iframeUrl&toolbar=0&view=FitH';
      }
      return NativePdfIframe(url: iframeUrl);
    }

    // Fallback for mobile/desktop: use SfPdfViewer with loading/error overlays
    return Stack(
      children: [
        SfPdfViewer.network(
          url,
          onDocumentLoaded: (_) => setState(() {
            _isLoading = false;
            _hasError = false;
          }),
          onDocumentLoadFailed: (_) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
        if (_isLoading)
          Container(
            color: AppTheme.background,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryTeal),
                  SizedBox(height: 16),
                  Text('Carregando documento...',
                      style: TextStyle(color: AppTheme.textGray, fontSize: 13)),
                ],
              ),
            ),
          ),
        if (_hasError && !_isLoading)
          Container(
            color: AppTheme.background,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image_outlined,
                      color: AppTheme.criticalRed, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Não foi possível carregar o documento.',
                    style: TextStyle(color: AppTheme.textWhite, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Abrir no navegador'),
                    onPressed: () => _openExternal(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
