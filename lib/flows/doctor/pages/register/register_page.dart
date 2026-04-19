import 'package:flutter/material.dart';

import '../../../pationt/pages/register/register_page.dart' as patient_auth;
import '../../../shared/auth/auth_flow_role.dart';

class DoctorRegisterPage extends StatelessWidget {
  const DoctorRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const patient_auth.RegisterPage(role: AuthFlowRole.doctor);
  }
}
