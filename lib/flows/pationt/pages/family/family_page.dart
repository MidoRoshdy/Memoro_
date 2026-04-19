import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import 'family_member_page.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  static const List<FamilyMemberData> _members = [
    FamilyMemberData(
      name: 'Maria',
      relation: FamilyRelationLabel.daughter,
      color: Color(0xFFE46A63),
      online: true,
    ),
    FamilyMemberData(
      name: 'Sarah',
      relation: FamilyRelationLabel.wife,
      color: Color(0xFFB66A5B),
      online: true,
    ),
    FamilyMemberData(
      name: 'John',
      relation: FamilyRelationLabel.grandson,
      color: Color(0xFF80664C),
      online: false,
    ),
  ];

  Widget _memberCard(
    BuildContext context,
    AppLocalizations l10n,
    FamilyMemberData member,
  ) {
    return Container(
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: member.color,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: member.online
                        ? AppColorPalette.emerald
                        : AppColorPalette.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Text(
            member.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColorPalette.blueSteel,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            member.relation.localize(l10n),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColorPalette.grey),
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FamilyMemberPage(member: member),
                  ),
                );
              },
              icon: const Icon(Icons.call, size: 16),
              label: Text(
                l10n.callMember(member.name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
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
          const SizedBox(height: Dimensions.verticalSpacingShort),
        ],
      ),
    );
  }

  Widget _memoriesSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColorPalette.white.withValues(alpha: 0.90),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColorPalette.blueSteel,
                ),
              ),
              const SizedBox(width: Dimensions.horizontalSpacingShort),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.memoriesHeadingPrimary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (l10n.memoriesHeadingSecondary.isNotEmpty)
                      Text(
                        l10n.memoriesHeadingSecondary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    l10n.memoriesViewPrimary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.blueSteel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.memoriesViewSecondary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.blueSteel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward, color: AppColorPalette.blueSteel),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9FD9D4), Color(0xFF8BC6EF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
            ),
            padding: const EdgeInsets.all(Dimensions.horizontalSpacingRegular),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                l10n.memoryAlbumCaption,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B260D),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.horizontalSpacingShort),
                  Expanded(
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A874A),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.verticalSpacingShort),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C6D5E),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.horizontalSpacingShort),
                  Expanded(
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 30),
                          Text(
                            l10n.memoriesAddNewMemory,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

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
                      l10n.familyScreenTitle,
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
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.horizontalSpacingRegular,
                  vertical: Dimensions.verticalSpacingRegular,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColorPalette.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.group_outlined,
                        color: AppColorPalette.blueSteel,
                      ),
                    ),

                    const SizedBox(width: Dimensions.horizontalSpacingRegular),
                    Text(
                      l10n.familyWhoCalling,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingRegular),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final member in _members) ...[
                      _memberCard(context, l10n, member),
                      const SizedBox(height: Dimensions.verticalSpacingRegular),
                    ],
                    _memoriesSection(context, l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
