import 'package:flutter/material.dart';

import '../../../core/constants/dimensions.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: Dimensions.horizontalSpacingShort),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
  }
}
