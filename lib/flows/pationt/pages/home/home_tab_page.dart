import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/string_assets.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/theme/app_color_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../games/memory_test_hub_page.dart';
import '../../widgets/app_notifications_action.dart';

class HomeTabPage extends ConsumerWidget {
  const HomeTabPage({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  static String _greetingForNow(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGreetingGoodMorning;
    if (h < 18) return l10n.homeGreetingGoodAfternoon;
    return l10n.homeGreetingGoodEvening;
  }

  static Widget _buildHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required String name,
    required String imageUrl,
  }) {
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Colors.black87,
                )
              : null,
        ),
        const SizedBox(width: Dimensions.verticalSpacingRegular),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greetingForNow(l10n)}, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: Dimensions.verticalSpacingExtraShort),
              Text(
                date,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const AppNotificationsAction(),
      ],
    );
  }

  static Widget _buildReminderCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius + 6),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width:
                    Dimensions.verticalSpacingXL +
                    Dimensions.horizontalSpacingExtraShort,
                height:
                    Dimensions.verticalSpacingXL +
                    Dimensions.horizontalSpacingExtraShort,
                decoration: BoxDecoration(
                  color: AppColorPalette.blueSteel.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(
                    Dimensions.cardCornerRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    AppAssets.medcineicon,
                    fit: BoxFit.contain,
                    height: 10,
                    width: 10,
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.verticalSpacingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeMedicationReminderTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: Dimensions.verticalSpacingExtraShort,
                    ),
                    Text(
                      l10n.homeMedicationReminderSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorPalette.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '15',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColorPalette.blueSteel,
                    ),
                  ),
                  Text(
                    l10n.homeMinutesLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorPalette.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Dimensions.cardCornerRadius),
          SizedBox(
            width: double.infinity,
            height:
                Dimensions.verticalSpacingXL +
                Dimensions.horizontalSpacingRegular,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorPalette.blueSteel,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(containerRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColorPalette.blueSteel,
                    ),
                  ),
                  const SizedBox(width: Dimensions.verticalSpacingShort),
                  Text(
                    l10n.homeTakenButton,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _quickActionCard({
    required BuildContext context,
    required Widget icon,
    required Color iconBg,
    required String title,
    required String action,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
      child: Container(
        padding: const EdgeInsets.all(containerRadius),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(Dimensions.cardCornerRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(
                  Dimensions.cardCornerRadius,
                ),
              ),
              child: Center(child: icon),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Container(
              width: double.infinity,
              height:
                  Dimensions.verticalSpacingXL -
                  Dimensions.horizontalSpacingShort,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  Dimensions.verticalSpacingLarge - 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                action,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColorPalette.blueSteel,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProgressCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: appPadding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(
          Dimensions.verticalSpacingMedium - 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeThisWeekProgressTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.show_chart_rounded,
                color: AppColorPalette.purpleDeep,
              ),
            ],
          ),
          const SizedBox(height: Dimensions.verticalSpacingRegular),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.homeWeekdayMon),
              Text(l10n.homeWeekdayTue),
              Text(l10n.homeWeekdayWed),
              Text(l10n.homeWeekdayThu),
              Text(l10n.homeWeekdayFri),
              Text(l10n.homeWeekdaySat),
              Text(l10n.homeWeekdaySun),
              Text(l10n.homeWeekdayMon),
            ],
          ),
          const SizedBox(height: containerRadius),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (i) {
              if (i == 0) {
                return const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                );
              }
              if (i == 1) {
                return const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF91CCF0),
                );
              }
              return const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF0F2F5),
              );
            }),
          ),
          const SizedBox(height: containerRadius),
          Text(
            l10n.homeAdherenceMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColorPalette.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHomeContent({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserProfile profile,
    required ValueChanged<int>? onSelectTab,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            context: context,
            l10n: l10n,
            name: profile.name,
            imageUrl: profile.imageUrl,
          ),
          const SizedBox(height: Dimensions.verticalSpacingMedium),
          _buildReminderCard(context, l10n),
          const SizedBox(height: Dimensions.cardCornerRadius),
          SizedBox(
            height: 350,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: Dimensions.verticalSpacingRegular,
              crossAxisSpacing: Dimensions.verticalSpacingRegular,
              childAspectRatio: 1.08,
              children: [
                _quickActionCard(
                  context: context,
                  icon: Image.asset(
                    AppAssets.medcineicon,
                    fit: BoxFit.contain,
                    width: 24,
                    height: 24,
                  ),
                  iconBg: AppColorPalette.blueSteel.withValues(alpha: 0.16),
                  title: l10n.tabMedicine,
                  action: l10n.quickActionViewAll,
                  onTap: () => onSelectTab?.call(3),
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.directions_walk_rounded,
                    color: AppColorPalette.brownOlive,
                  ),
                  iconBg: AppColorPalette.gold.withValues(alpha: 0.5),
                  title: l10n.quickActionActivity,
                  action: l10n.quickActionStart,
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.extension_rounded,
                    color: AppColorPalette.purpleDeep,
                  ),
                  iconBg: AppColorPalette.purpleLight.withValues(alpha: 0.26),
                  title: l10n.quickActionMemoryTest,
                  action: l10n.quickActionStart,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MemoryTestHubPage(),
                      ),
                    );
                  },
                ),
                _quickActionCard(
                  context: context,
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                    color: AppColorPalette.redDark,
                  ),
                  iconBg: AppColorPalette.peachPink.withValues(alpha: 0.6),
                  title: l10n.quickActionFamily,
                  action: l10n.quickActionViewAll,
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRouter.family),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.cardCornerRadius),
          _buildProgressCard(context, l10n),
          const SizedBox(height: bottomNavigationBarPadding),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(currentUserProfileProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(appHorizontalPadding),
        child: profileState.when(
          data: (profile) {
            final resolved =
                profile ??
                UserProfile(
                  uid: '',
                  name: l10n.guestUser,
                  email: '',
                  imageUrl: '',
                  patientId: '',
                );
            return _buildHomeContent(
              context: context,
              l10n: l10n,
              profile: resolved,
              onSelectTab: onSelectTab,
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => _buildHomeContent(
            context: context,
            l10n: l10n,
            profile: UserProfile(
              uid: '',
              name: l10n.guestUser,
              email: '',
              imageUrl: '',
              patientId: '',
            ),
            onSelectTab: onSelectTab,
          ),
        ),
      ),
    );
  }
}
