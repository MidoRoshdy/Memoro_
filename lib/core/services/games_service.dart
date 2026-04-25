import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game_link_item.dart';

class GamesConfig {
  const GamesConfig({
    required this.showMemoryHub,
    required this.showImageMemoryTest,
    required this.showDailyRecallTest,
    required this.showQuickMath,
    required this.showOnlineSection,
    required this.showHumanBenchmark,
    required this.showHelpfulMemory,
    required this.showJigsaw,
    required this.showChess,
    required this.showSudoku,
    required this.showSimonSays,
  });

  final bool showMemoryHub;
  final bool showImageMemoryTest;
  final bool showDailyRecallTest;
  final bool showQuickMath;
  final bool showOnlineSection;
  final bool showHumanBenchmark;
  final bool showHelpfulMemory;
  final bool showJigsaw;
  final bool showChess;
  final bool showSudoku;
  final bool showSimonSays;

  factory GamesConfig.fromMap(Map<String, dynamic>? data) {
    return GamesConfig(
      showMemoryHub: (data?['showMemoryHub'] as bool?) ?? true,
      showImageMemoryTest: (data?['showImageMemoryTest'] as bool?) ?? true,
      showDailyRecallTest: (data?['showDailyRecallTest'] as bool?) ?? true,
      showQuickMath: (data?['showQuickMath'] as bool?) ?? true,
      showOnlineSection: (data?['showOnlineSection'] as bool?) ?? true,
      showHumanBenchmark: (data?['showHumanBenchmark'] as bool?) ?? true,
      showHelpfulMemory: (data?['showHelpfulMemory'] as bool?) ?? true,
      showJigsaw: (data?['showJigsaw'] as bool?) ?? true,
      showChess: (data?['showChess'] as bool?) ?? true,
      showSudoku: (data?['showSudoku'] as bool?) ?? true,
      showSimonSays: (data?['showSimonSays'] as bool?) ?? true,
    );
  }
}

abstract final class GamesService {
  GamesService._();

  static const String collectionName = 'games';
  static const String linksSubcollection = 'links';
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String buildGamesDocId(String uidA, String uidB) {
    final a = uidA.trim();
    final b = uidB.trim();
    if (a.isEmpty || b.isEmpty) {
      throw ArgumentError('Both user IDs are required.');
    }
    final sorted = <String>[a, b]..sort();
    return '${sorted.first}_${sorted.last}';
  }

  static DocumentReference<Map<String, dynamic>> gamesRef(String gamesDocId) {
    return _db.collection(collectionName).doc(gamesDocId);
  }

  static CollectionReference<Map<String, dynamic>> _linksRef(String gamesDocId) {
    return gamesRef(gamesDocId).collection(linksSubcollection);
  }

  static Future<void> ensureGamesDocument({
    required String gamesDocId,
    required String doctorUid,
    required String patientUid,
  }) async {
    final participants = <String>[doctorUid.trim(), patientUid.trim()]..sort();
    final ref = gamesRef(gamesDocId);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.set(<String, dynamic>{
        'gamesId': gamesDocId,
        'doctorUid': doctorUid.trim(),
        'patientUid': patientUid.trim(),
        'participantIds': participants,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }
    await ref.set(<String, dynamic>{
      'gamesId': gamesDocId,
      'doctorUid': doctorUid.trim(),
      'patientUid': patientUid.trim(),
      'participantIds': participants,
      'showMemoryHub': true,
      'showImageMemoryTest': true,
      'showDailyRecallTest': true,
      'showQuickMath': true,
      'showOnlineSection': true,
      'showHumanBenchmark': true,
      'showHelpfulMemory': true,
      'showJigsaw': true,
      'showChess': true,
      'showSudoku': true,
      'showSimonSays': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<GamesConfig> watchConfig(String gamesDocId) {
    return gamesRef(gamesDocId)
        .snapshots()
        .map((snap) => GamesConfig.fromMap(snap.data()));
  }

  static Stream<List<GameLinkItem>> watchLinks(String gamesDocId) {
    return _linksRef(gamesDocId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => GameLinkItem.fromFirestore(d.id, d.data())).toList(),
        );
  }

  static Future<void> updateConfig({
    required String gamesDocId,
    required String doctorUid,
    required String patientUid,
    bool? showMemoryHub,
    bool? showImageMemoryTest,
    bool? showDailyRecallTest,
    bool? showQuickMath,
    bool? showOnlineSection,
    bool? showHumanBenchmark,
    bool? showHelpfulMemory,
    bool? showJigsaw,
    bool? showChess,
    bool? showSudoku,
    bool? showSimonSays,
  }) async {
    await ensureGamesDocument(
      gamesDocId: gamesDocId,
      doctorUid: doctorUid,
      patientUid: patientUid,
    );
    await gamesRef(gamesDocId).set(<String, dynamic>{
      if (showMemoryHub != null) 'showMemoryHub': showMemoryHub,
      if (showImageMemoryTest != null) 'showImageMemoryTest': showImageMemoryTest,
      if (showDailyRecallTest != null) 'showDailyRecallTest': showDailyRecallTest,
      if (showQuickMath != null) 'showQuickMath': showQuickMath,
      if (showOnlineSection != null) 'showOnlineSection': showOnlineSection,
      if (showHumanBenchmark != null) 'showHumanBenchmark': showHumanBenchmark,
      if (showHelpfulMemory != null) 'showHelpfulMemory': showHelpfulMemory,
      if (showJigsaw != null) 'showJigsaw': showJigsaw,
      if (showChess != null) 'showChess': showChess,
      if (showSudoku != null) 'showSudoku': showSudoku,
      if (showSimonSays != null) 'showSimonSays': showSimonSays,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> addLink({
    required String gamesDocId,
    required String doctorUid,
    required String patientUid,
    required String title,
    required String url,
  }) async {
    await ensureGamesDocument(
      gamesDocId: gamesDocId,
      doctorUid: doctorUid,
      patientUid: patientUid,
    );
    await _linksRef(gamesDocId).add(<String, dynamic>{
      'title': title.trim(),
      'url': url.trim(),
      'isVisible': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await gamesRef(gamesDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> setLinkVisibility({
    required String gamesDocId,
    required String linkId,
    required bool isVisible,
  }) async {
    await _linksRef(gamesDocId).doc(linkId).set(<String, dynamic>{
      'isVisible': isVisible,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await gamesRef(gamesDocId).set(<String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
