import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetVerification {
  PasswordResetVerification({
    required this.verificationId,
    required this.resendToken,
    required this.phoneNumber,
  });

  final String verificationId;
  final int? resendToken;
  final String phoneNumber;
}

abstract final class PasswordResetService {
  PasswordResetService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  /// Sends an SMS OTP to [phoneNumber] (E.164 format) and returns the
  /// verification id needed to confirm it.
  ///
  /// On Android the verification may auto-resolve before the user types the
  /// code; in that case [PhoneAuthCredential] is returned directly via
  /// [autoResolved].
  static Future<PasswordResetVerification> sendOtp({
    required String phoneNumber,
    int? resendToken,
    Duration timeout = const Duration(seconds: 60),
    void Function(PhoneAuthCredential credential)? autoResolved,
  }) async {
    final completer = Completer<PasswordResetVerification>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: resendToken,
      verificationCompleted: (credential) {
        autoResolved?.call(credential);
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (verificationId, forceResendingToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PasswordResetVerification(
              verificationId: verificationId,
              resendToken: forceResendingToken,
              phoneNumber: phoneNumber,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  /// Verifies [smsCode] for [verificationId] and signs in the temp phone
  /// session. Returns the signed-in [User] (which is a phone-only Auth user
  /// distinct from the user's real email account).
  static Future<User> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Could not verify the code, please try again.',
      );
    }
    return user;
  }

  /// Calls the backend `resetPasswordWithVerifiedPhone` callable to update the
  /// password of the email account whose profile holds the verified phone.
  ///
  /// The current Firebase user MUST be the temporary phone-auth session
  /// returned by [verifyOtp].
  static Future<String> commitNewPassword({
    required String newPassword,
  }) async {
    final callable = _functions.httpsCallable(
      'resetPasswordWithVerifiedPhone',
    );
    final response = await callable.call<Map<dynamic, dynamic>>({
      'newPassword': newPassword,
    });
    final data = response.data;
    final role = (data['role'] as String?)?.trim() ?? '';
    return role;
  }

  /// Best-effort sign-out of the temp phone session created by [verifyOtp].
  static Future<void> clearTempSession() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // ignore
    }
  }
}
