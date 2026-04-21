import 'package:flutter/material.dart';

class FamilyMemoryViewerPage extends StatelessWidget {
  const FamilyMemoryViewerPage({
    super.key,
    required this.imageUrl,
    this.title = 'Memory',
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined, color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
