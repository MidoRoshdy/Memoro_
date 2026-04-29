import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flows/doctor/pages/activity/doctor_activity_details_page.dart';
import '../../flows/doctor/pages/medicine/doctor_medicine_details_page.dart';
import '../../flows/shared/chat/chat_conversation_page.dart';
import '../router/app_router.dart';
import 'emergency_request_service.dart';

abstract final class NotificationRouteResolver {
  NotificationRouteResolver._();

  static Future<void> openFromPayload(Map<String, dynamic> payload) async {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    final type = (payload['type'] as String?)?.trim() ?? '';
    final pairId = (payload['pairId'] as String?)?.trim() ?? '';
    final entityId = (payload['entityId'] as String?)?.trim() ?? '';
    final data = _readData(payload);

    if (type == 'activity_assigned' ||
        type == 'activity_done' ||
        type == 'activity_reminder') {
      final doctorUid = (data['doctorUid'] as String?)?.trim() ?? '';
      final patientUid = (data['patientUid'] as String?)?.trim() ?? '';
      final patientName =
          (data['patientName'] as String?)?.trim().isNotEmpty == true
          ? (data['patientName'] as String).trim()
          : 'Patient';
      if (pairId.isNotEmpty &&
          entityId.isNotEmpty &&
          doctorUid.isNotEmpty &&
          patientUid.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DoctorActivityDetailsPage(
              activityDocId: pairId,
              activityItemId: entityId,
              doctorUid: doctorUid,
              patientUid: patientUid,
              patientName: patientName,
            ),
          ),
        );
        return;
      }
    }

    if (type == 'medication_reminder' ||
        type == 'medication_added' ||
        type == 'medication_taken') {
      if (pairId.isNotEmpty && entityId.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DoctorMedicineDetailsPage(
              medicineDocId: pairId,
              medicineItemId: entityId,
            ),
          ),
        );
        return;
      }
    }

    if (type == 'help_request') {
      final opened = await _openHelpRequestLocation(
        context: context,
        payload: payload,
        data: data,
        pairId: pairId,
      );
      if (opened) return;
      await Navigator.of(context).pushNamed(AppRouter.notifications);
      return;
    }

    if (type == 'help_request_resolved') {
      await Navigator.of(context).pushNamed(AppRouter.notifications);
      return;
    }

    if (type == 'chat_message') {
      final chatId = (data['chatId'] as String?)?.trim() ?? pairId;
      final currentUserId =
          (data['currentUserId'] as String?)?.trim() ??
          (FirebaseAuth.instance.currentUser?.uid ?? '');
      final title = (data['title'] as String?)?.trim().isNotEmpty == true
          ? (data['title'] as String).trim()
          : 'Chat';
      final avatarUrl = (data['avatarUrl'] as String?)?.trim() ?? '';
      if (chatId.isNotEmpty && currentUserId.isNotEmpty) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatConversationPage(
              chatId: chatId,
              currentUserId: currentUserId,
              title: title,
              avatarUrl: avatarUrl,
            ),
          ),
        );
        return;
      }
    }

    await Navigator.of(context).pushNamed(AppRouter.notifications);
  }

  static Map<String, dynamic> _readData(Map<String, dynamic> payload) {
    final rawData = payload['data'];
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is String && rawData.trim().isNotEmpty) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    final rawArgs = payload['argsJson'];
    if (rawArgs is String && rawArgs.trim().isNotEmpty) {
      final decoded = jsonDecode(rawArgs);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    return const <String, dynamic>{};
  }

  static Future<bool> _openHelpRequestLocation({
    required BuildContext context,
    required Map<String, dynamic> payload,
    required Map<String, dynamic> data,
    required String pairId,
  }) async {
    Uri? uri =
        _buildLocationUriFromMap(payload) ?? _buildLocationUriFromMap(data);

    if (uri == null && pairId.isNotEmpty) {
      try {
        final snap = await EmergencyRequestService.requestRef(pairId).get();
        uri = _buildLocationUriFromMap(
          snap.data() ?? const <String, dynamic>{},
        );
      } catch (_) {
        uri = null;
      }
    }

    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No location available for this SOS request'),
          ),
        );
      }
      return false;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open location map')),
        );
        return false;
      }
      return launched;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open location map')),
        );
      }
      return false;
    }
  }

  static Uri? _buildLocationUriFromMap(Map<String, dynamic> source) {
    final mapsUrl = (source['mapsUrl'] as String?)?.trim() ?? '';
    if (mapsUrl.isNotEmpty) {
      final parsed = Uri.tryParse(mapsUrl);
      if (parsed != null) return parsed;
    }
    final lat = _asDouble(source['latitude']);
    final lng = _asDouble(source['longitude']);
    if (lat != null && lng != null) {
      return Uri.parse('https://maps.google.com/?q=$lat,$lng');
    }
    return null;
  }

  static double? _asDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }
}
