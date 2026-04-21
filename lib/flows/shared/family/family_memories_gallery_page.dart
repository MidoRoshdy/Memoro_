import 'package:flutter/material.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/models/family_memory.dart';
import '../../../core/services/family_service.dart';
import '../../../core/theme/app_color_palette.dart';
import 'family_memory_viewer_page.dart';

class FamilyMemoriesGalleryPage extends StatelessWidget {
  const FamilyMemoriesGalleryPage({
    super.key,
    required this.familyDocId,
    required this.title,
    this.memberId,
    this.forPatient = false,
    this.canManage = false,
  });

  final String familyDocId;
  final String title;
  final String? memberId;
  final bool forPatient;
  final bool canManage;

  Stream<List<FamilyMemory>> _stream() {
    if (memberId != null && memberId!.trim().isNotEmpty) {
      return FamilyService.watchProfileMemories(
        familyDocId,
        memberId!,
        forPatient: forPatient,
      );
    }
    return FamilyService.watchFamilyMemories(
      familyDocId,
      limit: 300,
      forPatient: forPatient,
    );
  }

  Future<void> _onDelete(BuildContext context, FamilyMemory memory) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete memory?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    await FamilyService.deleteFamilyMemory(
      familyDocId: familyDocId,
      memoryId: memory.id,
    );
  }

  Future<void> _toggleHidden(FamilyMemory memory) async {
    await FamilyService.setFamilyMemoryHiddenForPatient(
      familyDocId: familyDocId,
      memoryId: memory.id,
      hiddenForPatient: !memory.hiddenForPatient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: StreamBuilder<List<FamilyMemory>>(
            stream: _stream(),
            builder: (context, snapshot) {
              final memories = snapshot.data ?? const <FamilyMemory>[];
              if (snapshot.connectionState == ConnectionState.waiting &&
                  memories.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (memories.isEmpty) {
                return const Center(child: Text('No memories found.'));
              }
              return GridView.builder(
                itemCount: memories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final memory = memories[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => FamilyMemoryViewerPage(
                                  imageUrl: memory.imageUrl,
                                  title: memory.memberName.isNotEmpty
                                      ? memory.memberName
                                      : 'Memory',
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            memory.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const DecoratedBox(
                              decoration: BoxDecoration(color: Colors.black12),
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        if (canManage && memberId == null)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'toggle') {
                                  await _toggleHidden(memory);
                                } else if (value == 'delete') {
                                  if (!context.mounted) return;
                                  await _onDelete(context, memory);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(
                                    memory.hiddenForPatient
                                        ? 'Show to patient'
                                        : 'Hide from patient',
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              color: Colors.white.withValues(alpha: 0.95),
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppColorPalette.white,
                              ),
                            ),
                          ),
                        if (memory.hiddenForPatient)
                          Positioned(
                            left: 6,
                            bottom: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Hidden from patient',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
