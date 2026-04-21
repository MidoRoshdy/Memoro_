import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMemory {
  const FamilyMemory({
    required this.id,
    required this.familyDocId,
    required this.memberId,
    required this.imageUrl,
    required this.createdAt,
    this.caption = '',
    this.memberName = '',
    this.createdByUid = '',
    this.hiddenForPatient = false,
  });

  final String id;
  final String familyDocId;
  final String memberId;
  final String imageUrl;
  final String caption;
  final String memberName;
  final String createdByUid;
  final bool hiddenForPatient;
  final DateTime? createdAt;

  factory FamilyMemory.fromFirestore(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    }

    return FamilyMemory(
      id: id,
      familyDocId: (data['familyDocId'] as String?)?.trim() ?? '',
      memberId: (data['memberId'] as String?)?.trim() ?? '',
      imageUrl: (data['imageUrl'] as String?)?.trim() ?? '',
      caption: (data['caption'] as String?)?.trim() ?? '',
      memberName: (data['memberName'] as String?)?.trim() ?? '',
      createdByUid: (data['createdByUid'] as String?)?.trim() ?? '',
      hiddenForPatient: data['hiddenForPatient'] == true,
      createdAt: createdAt,
    );
  }
}
