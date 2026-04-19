import 'package:flutter/material.dart';

import '../../../pationt/pages/login/login_page.dart' as patient_auth;
import '../../../shared/auth/auth_flow_role.dart';

class DoctorLoginPage extends StatelessWidget {
  const DoctorLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const patient_auth.LoginPage(role: AuthFlowRole.doctor);
  }
}
