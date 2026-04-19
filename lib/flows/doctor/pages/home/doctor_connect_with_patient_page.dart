import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/services/doctor_link_request_service.dart';
import '../../../../core/services/patient_lookup_service.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../pationt/widgets/primary_button.dart';

class DoctorConnectWithPatientPage extends StatefulWidget {
  const DoctorConnectWithPatientPage({super.key, this.onRequestSubmitted});

  /// Optional hook after a request is written; UI updates from Firestore stream.
  final VoidCallback? onRequestSubmitted;

  @override
  State<DoctorConnectWithPatientPage> createState() =>
      _DoctorConnectWithPatientPageState();
}

class _DoctorConnectWithPatientPageState
    extends State<DoctorConnectWithPatientPage> {
  final TextEditingController _codeController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final raw = _codeController.text.trim();
    if (raw.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.doctorPatientIdRequired)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final profile = await PatientLookupService.findByPublicPatientId(raw);
      if (!mounted) return;
      if (profile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.doctorPatientNotFound)));
        return;
      }
      try {
        await DoctorLinkRequestService.ensurePendingRequest(patient: profile);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.doctorLinkRequestFailed)));
        return;
      }
      if (!mounted) return;
      widget.onRequestSubmitted?.call();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      final message = e.code == 'permission-denied'
          ? l10n.firestorePermissionDenied
          : l10n.doctorPatientLookupError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.doctorPatientLookupError)));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: Dimensions.verticalSpacingLarge),
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Image.asset(
                AppAssets.caregiverConnectIcon,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingLarge),
          Text(
            l10n.doctorConnectTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingShort),
          Text(
            l10n.doctorConnectSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.35,
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingXL),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.doctorPatientIdLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingShort),
          TextField(
            controller: _codeController,
            enabled: !_submitting,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: theme.textTheme.bodyLarge,
            decoration: inputDecoration.copyWith(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.96),
              hintText: l10n.doctorPatientIdHint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSpacingMedium,
                vertical: Dimensions.verticalSpacingMedium,
              ),
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingLarge),
          PrimaryButton(
            label: l10n.doctorSubmitCodeButton,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: Dimensions.verticalSpacingLarge),
          Container(
            width: double.infinity,
            padding: appPadding,
            decoration: BoxDecoration(
              color: AppColorPalette.gold.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
              border: Border.all(
                color: AppColorPalette.brownOlive.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColorPalette.brownOlive,
                  size: 22,
                ),
                const SizedBox(width: Dimensions.verticalSpacingRegular),
                Expanded(
                  child: Text(
                    l10n.doctorConnectInfoBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.brownOlive,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: bottomNavigationBarPadding),
        ],
      ),
    );
  }
}
