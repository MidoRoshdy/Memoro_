import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Result of requesting an OTP email — exposes how long the code is valid.
class PasswordResetOtpRequest {
  PasswordResetOtpRequest({required this.email, required this.expiresInSeconds});

  final String email;
  final int expiresInSeconds;
}

/// Email-based password reset using a 6-digit OTP delivered by Gmail SMTP
/// from the backend Cloud Functions.
abstract final class PasswordResetService {
  PasswordResetService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  /// Asks the backend to generate a one-time code and email it to [email].
  static Future<PasswordResetOtpRequest> sendOtp({
    required String email,
  }) async {
    final normalized = email.trim().toLowerCase();
    debugPrint('[PasswordResetService] requestEmailOtp start email=$normalized');

    try {
      final callable = _functions.httpsCallable('requestEmailOtp');
      final response = await callable.call<Map<dynamic, dynamic>>({
        'email': normalized,
      });
      final data = response.data;
      final ttl = (data['expiresInSeconds'] as num?)?.toInt() ?? 600;
      debugPrint(
        '[PasswordResetService] requestEmailOtp ok email=$normalized ttl=${ttl}s',
      );
      return PasswordResetOtpRequest(
        email: normalized,
        expiresInSeconds: ttl,
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '[PasswordResetService] requestEmailOtp failed: '
        'code=${e.code} message=${e.message}',
      );
      rethrow;
    }
  }

  /// Verifies [otp] for [email] and updates the password to [newPassword].
  /// Returns the role string ('caregiver', 'patient', or 'unknown').
  static Future<String> verifyOtpAndCommit({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final normalized = email.trim().toLowerCase();
    debugPrint(
      '[PasswordResetService] verifyEmailOtpAndResetPassword start '
      'email=$normalized otpLen=${otp.length}',
    );
    try {
      final callable = _functions.httpsCallable(
        'verifyEmailOtpAndResetPassword',
      );
      final response = await callable.call<Map<dynamic, dynamic>>({
        'email': normalized,
        'otp': otp.trim(),
        'newPassword': newPassword,
      });
      final data = response.data;
      final role = (data['role'] as String?)?.trim() ?? '';
      debugPrint(
        '[PasswordResetService] verifyEmailOtpAndResetPassword ok role=$role',
      );
      return role;
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
        '[PasswordResetService] verifyEmailOtpAndResetPassword failed: '
        'code=${e.code} message=${e.message}',
      );
      rethrow;
    }
  }
}
