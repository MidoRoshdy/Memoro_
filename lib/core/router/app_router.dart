import 'package:flutter/material.dart';

import '../../flows/doctor/pages/forgot_password/forgot_password_page.dart';
import '../../flows/doctor/pages/home/home_page.dart';
import '../../flows/doctor/pages/login/login_page.dart';
import '../../flows/doctor/pages/register/register_page.dart';
import '../../flows/pationt/pages/choose_flow/choose_flow_page.dart';
import '../../flows/pationt/pages/forgot_password/forgot_password_page.dart';
import '../../flows/pationt/pages/family/family_page.dart';
import '../../flows/pationt/pages/home/home_page.dart';
import '../../flows/pationt/pages/login/login_page.dart';
import '../../flows/pationt/pages/notification/notification_page.dart';
import '../../flows/pationt/pages/register/register_page.dart';
import '../../flows/pationt/pages/settings/settings_page.dart';
import '../../flows/pationt/pages/sos/sos_page.dart';
import '../../flows/pationt/pages/sos_settings/sos_settings_page.dart';
import '../../flows/pationt/pages/splash/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String chooseFlow = '/choose-flow';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String doctorLogin = '/doctor/login';
  static const String doctorRegister = '/doctor/register';
  static const String doctorForgotPassword = '/doctor/forgot-password';
  static const String doctorHome = '/doctor/home';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String family = '/family';
  static const String sos = '/sos';
  static const String settings = '/settings';
  static const String sosSettings = '/sos-settings';

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    chooseFlow: (_) => const ChooseFlowPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    doctorLogin: (_) => const DoctorLoginPage(),
    doctorRegister: (_) => const DoctorRegisterPage(),
    doctorForgotPassword: (_) => const DoctorForgotPasswordPage(),
    doctorHome: (_) => const DoctorHomePage(),
    home: (_) => const HomePage(),
    notifications: (_) => const NotificationPage(),
    family: (_) => const FamilyPage(),
    sos: (_) => const SosPage(),
    settings: (_) => const SettingsPage(),
    sosSettings: (_) => const SosSettingsPage(),
  };
}
