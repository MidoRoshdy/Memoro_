import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';

enum FamilyRelationLabel { daughter, wife, grandson }

extension FamilyRelationLabelX on FamilyRelationLabel {
  String localize(AppLocalizations l10n) => switch (this) {
    FamilyRelationLabel.daughter => l10n.relationDaughter,
    FamilyRelationLabel.wife => l10n.relationWife,
    FamilyRelationLabel.grandson => l10n.relationGrandson,
  };
}

class FamilyMemberData {
  const FamilyMemberData({
    required this.name,
    required this.relation,
    required this.color,
    this.online = false,
  });

  final String name;
  final FamilyRelationLabel relation;
  final Color color;
  final bool online;
}

class FamilyMemberPage extends StatelessWidget {
  const FamilyMemberPage({required this.member, super.key});

  final FamilyMemberData member;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: appPadding,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      l10n.familyMemberDetailTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: member.color,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 56,
                      ),
                    ),
                  ),
                  if (member.online)
                    const Positioned(
                      right: 10,
                      bottom: 10,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: AppColorPalette.emerald,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Text(
                member.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                member.relation.localize(l10n),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              const SizedBox(height: Dimensions.verticalSpacingLarge),
              const SizedBox(height: Dimensions.verticalSpacingLarge),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 30),
                  label: Text(
                    l10n.callMember(member.name),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorPalette.blueSteel,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 30),
                  label: Text(
                    l10n.familySendMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColorPalette.blueSteel,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColorPalette.blueSteel,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                l10n.familyMemberEncouragement(member.name),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColorPalette.grey),
              ),
              const SizedBox(height: Dimensions.verticalSpacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}
