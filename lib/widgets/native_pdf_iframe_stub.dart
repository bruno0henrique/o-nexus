import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms.
/// Displays a friendly fallback message when native web iframe is not available.
class NativePdfIframe extends StatelessWidget {
  final String url;
  const NativePdfIframe({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.document_scanner, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('Visualização nativa não disponível nesta plataforma',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
