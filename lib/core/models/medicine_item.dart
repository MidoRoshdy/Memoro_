import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineItem {
  const MedicineItem({
    required this.id,
    required this.name,
    required this.dosage,
    required this.intakeType,
    required this.doseAmount,
    required this.doseUnit,
    required this.scheduledTime,
    required this.scheduledTimes,
    required this.frequency,
    required this.daysTotal,
    required this.caregiverInstructions,
    required this.status,
    required this.lastDoseAt,
    required this.lastDoseVerifiedBy,
    required this.createdByUid,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String dosage;
  final String intakeType;
  final int doseAmount;
  final String doseUnit;
  final String scheduledTime;
  final List<String> scheduledTimes;
  final String frequency;
  final int daysTotal;
  final String caregiverInstructions;
  final String status;
  final DateTime? lastDoseAt;
  final String lastDoseVerifiedBy;
  final String createdByUid;
  final DateTime? createdAt;

  bool get isTaken {
    if (status != 'taken') return false;
    final doseAt = lastDoseAt;
    if (doseAt == null) return false;
    final localDoseAt = doseAt.toLocal();
    final now = DateTime.now();
    return now.year == localDoseAt.year &&
        now.month == localDoseAt.month &&
        now.day == localDoseAt.day;
  }

  bool get isMissed => status == 'missed';
  bool get isUpcoming => status == 'upcoming';
  String get primaryTime =>
      scheduledTimes.isNotEmpty ? scheduledTimes.first : scheduledTime;
  String get secondaryTime =>
      scheduledTimes.length > 1 ? scheduledTimes[1] : '';
  String get thirdTime => scheduledTimes.length > 2 ? scheduledTimes[2] : '';
  String get formattedDose =>
      doseAmount > 0 && doseUnit.isNotEmpty ? '$doseAmount $doseUnit' : dosage;

  factory MedicineItem.fromFirestore(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    final rawLastDoseAt = data['lastDoseAt'];
    DateTime? createdAt;
    DateTime? lastDoseAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    }
    if (rawLastDoseAt is Timestamp) {
      lastDoseAt = rawLastDoseAt.toDate();
    } else if (rawLastDoseAt is DateTime) {
      lastDoseAt = rawLastDoseAt;
    }

    final rawTimes = data['scheduledTimes'];
    final times = rawTimes is List
        ? rawTimes
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    final fallbackTime = (data['scheduledTime'] as String?)?.trim() ?? '';
    if (times.isEmpty && fallbackTime.isNotEmpty) {
      times.add(fallbackTime);
    }

    return MedicineItem(
      id: id,
      name: (data['name'] as String?)?.trim() ?? '',
      dosage: (data['dosage'] as String?)?.trim() ?? '',
      intakeType: (data['intakeType'] as String?)?.trim() ?? 'Tablet',
      doseAmount: (data['doseAmount'] as num?)?.toInt() ?? 1,
      doseUnit: (data['doseUnit'] as String?)?.trim() ?? 'tablet',
      scheduledTime: fallbackTime,
      scheduledTimes: times,
      frequency: (data['frequency'] as String?)?.trim() ?? '',
      daysTotal: (data['daysTotal'] as num?)?.toInt() ?? 30,
      caregiverInstructions:
          (data['caregiverInstructions'] as String?)?.trim() ?? '',
      status: (data['status'] as String?)?.trim().toLowerCase() ?? 'upcoming',
      lastDoseAt: lastDoseAt,
      lastDoseVerifiedBy: (data['lastDoseVerifiedBy'] as String?)?.trim() ?? '',
      createdByUid: (data['createdByUid'] as String?)?.trim() ?? '',
      createdAt: createdAt,
    );
  }
}
