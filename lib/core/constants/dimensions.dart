import 'package:flutter/material.dart';

import '../theme/app_color_palette.dart';

class Dimensions {
  const Dimensions._();

  static const double verticalSpacingExtraShort = 4;
  static const double verticalSpacingShort = 8;
  static const double verticalSpacingRegular = 12;
  static const double verticalSpacingMedium = 18;
  static const double verticalSpacingLarge = 24;
  static const double verticalSpacingXL = 40;
  static const double verticalSpacingXXL = 75;

  static const double horizontalSpacingExtraShort = 4;
  static const double horizontalSpacingShort = 6;
  static const double horizontalSpacingRegular = 10;
  static const double horizontalSpacingMedium = 16;
  static const double horizontalSpacingLarge = 28;

  /// Larger material cards (game tiles, home card) — distinct from [containerRadius].
  static const double cardCornerRadius = 14;
}

const double appHorizontalPadding = 16;
const double appVerticalPadding = 16;

const EdgeInsets appPadding = EdgeInsets.symmetric(
  horizontal: appHorizontalPadding,
  vertical: appVerticalPadding,
);

const double bottomNavigationBarPadding = 90;
const double loadingWidgetSize = 60;

const SizedBox extraShortVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingExtraShort,
);
const SizedBox shortVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingShort,
);
const SizedBox mediumVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingRegular,
);
const SizedBox longVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingMedium,
);
const SizedBox veryLongVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingLarge,
);
const SizedBox extraLongVerticalSpace = SizedBox(
  height: Dimensions.verticalSpacingXL,
);
const SizedBox rowSpace = SizedBox(
  width: Dimensions.horizontalSpacingExtraShort,
);
const SizedBox wideRowSpace = SizedBox(
  width: Dimensions.horizontalSpacingMedium,
);

const double containerRadius = 10;

const BorderRadius appBorderRadius = BorderRadius.all(
  Radius.circular(containerRadius),
);

const OutlineInputBorder focusedBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 1, color: AppColorPalette.blueBright),
  borderRadius: appBorderRadius,
);

const OutlineInputBorder disabledBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 1, color: AppColorPalette.outlineMuted),
  borderRadius: appBorderRadius,
);

const OutlineInputBorder errorBorder = OutlineInputBorder(
  borderSide: BorderSide(width: 1, color: AppColorPalette.redBright),
  borderRadius: appBorderRadius,
);

const InputDecoration inputDecoration = InputDecoration(
  focusedBorder: focusedBorder,
  disabledBorder: disabledBorder,
  enabledBorder: disabledBorder,
  errorBorder: errorBorder,
);

const BoxDecoration roundedContainerDecoration = BoxDecoration(
  color: AppColorPalette.white,
  border: Border.fromBorderSide(
    BorderSide(color: AppColorPalette.outlineSoft, width: 1),
  ),
  borderRadius: BorderRadius.all(Radius.circular(containerRadius)),
);
