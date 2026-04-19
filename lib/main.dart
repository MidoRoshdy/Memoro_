import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'app.dart';
import 'core/localization/locale_controller.dart';
import 'firebase_options.dart';

/// Ensures native WebView implementations are registered before any WebView is built.
/// Without this, iOS can throw Pigeon `channel-error` exceptions (especially after hot restart).
void _registerWebViewPlatform() {
  if (kIsWeb) return;
  if (WebViewPlatform.instance != null) return;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      WebViewPlatform.instance = AndroidWebViewPlatform();
      return;
    case TargetPlatform.iOS:
      WebViewPlatform.instance = WebKitWebViewPlatform();
      return;
    default:
      return;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerWebViewPlatform();
  await LocaleController.loadSavedLocale();
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    final hasRealFirebaseConfig =
        options.apiKey != 'REPLACE_ME' && options.appId != 'REPLACE_ME';
    if (hasRealFirebaseConfig && Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    } else if (Firebase.apps.isNotEmpty) {
      debugPrint('Firebase already initialized, skipping duplicate init.');
    } else {
      debugPrint(
        'Firebase skipped: run flutterfire configure to generate real options.',
      );
    }
  } on FirebaseException catch (e) {
    debugPrint('Firebase init failed: ${e.code} ${e.message}');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const ProviderScope(child: MemoroApp()));
}
