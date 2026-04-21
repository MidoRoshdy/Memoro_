import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    required this.isEmergencyContact,
    required this.createdAt,
    this.imageUrl = '',
    this.personalNote = '',
  });

  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isEmergencyContact;
  final String imageUrl;
  final String personalNote;
  final DateTime? createdAt;

  factory FamilyMember.fromFirestore(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime? createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    }

    return FamilyMember(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      phone: (data['phone'] as String?)?.trim() ?? '',
      relation: (data['relation'] as String?)?.trim() ?? '',
      isEmergencyContact: data['isEmergencyContact'] == true,
      imageUrl: (data['imageUrl'] as String?)?.trim() ?? '',
      personalNote: (data['personalNote'] as String?)?.trim() ?? '',
      createdAt: createdAt,
    );
  }
}
