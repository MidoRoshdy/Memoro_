import 'package:flutter/material.dart';

import '../../../pationt/pages/forgot_password/forgot_password_page.dart'
    as patient_auth;
import '../../../shared/auth/auth_flow_role.dart';

class DoctorForgotPasswordPage extends StatelessWidget {
  const DoctorForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const patient_auth.ForgotPasswordPage(role: AuthFlowRole.doctor);
  }
}
