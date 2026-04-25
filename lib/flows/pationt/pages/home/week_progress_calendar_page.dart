import 'package:flutter/material.dart';

import '../../../../core/constants/dimensions.dart';
import '../../../../core/theme/app_color_palette.dart';

class WeekProgressDayData {
  const WeekProgressDayData({
    required this.date,
    required this.done,
    required this.total,
  });

  final DateTime date;
  final int done;
  final int total;
}

class WeekProgressCalendarPage extends StatelessWidget {
  const WeekProgressCalendarPage({
    super.key,
    required this.title,
    required this.days,
  });

  final String title;
  final List<WeekProgressDayData> days;

  static Color _colorForDay(WeekProgressDayData day, DateTime today) {
    final dayDate = DateTime(day.date.year, day.date.month, day.date.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    if (dayDate.isAfter(todayDate)) return const Color(0xFFF0F2F5);
    if (dayDate.isAtSameMomentAs(todayDate)) return AppColorPalette.blueSteel;
    if (day.total <= 0) return const Color(0xFFF0F2F5);
    final ratio = day.done / day.total;
    if (ratio < 0.5) return Colors.red;
    if (ratio < 0.75) return AppColorPalette.gold;
    return AppColorPalette.emerald;
  }

  static String _weekRange(BuildContext context, DateTime start, DateTime end) {
    final l = MaterialLocalizations.of(context);
    return '${l.formatShortDate(start)} - ${l.formatShortDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final weekStart = sorted.isEmpty ? DateTime.now() : sorted.first.date;
    final weekEnd = sorted.isEmpty ? DateTime.now() : sorted.last.date;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: appPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weekRange(context, weekStart, weekEnd),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Dimensions.verticalSpacingRegular),
            Expanded(
              child: ListView.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Dimensions.verticalSpacingShort),
                itemBuilder: (context, index) {
                  final day = sorted[index];
                  final color = _colorForDay(day, now);
                  final ratio = day.total <= 0 ? 0.0 : (day.done / day.total);
                  final dateText = MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(day.date);
                  return Container(
                    padding: const EdgeInsets.all(
                      Dimensions.verticalSpacingRegular,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: ratio >= 0.75
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(
                          width: Dimensions.horizontalSpacingRegular,
                        ),
                        Expanded(
                          child: Text(
                            dateText,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${(ratio * 100).round()}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColorPalette.blueSteel,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
