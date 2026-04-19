import 'package:flutter/material.dart';

/// App-wide palette. Hex values from design (duplicates merged).
class AppColorPalette {
  AppColorPalette._();

  static const Color blueSteel = Color(0xFF4397BA);
  static const Color blueBright = Color(0xFF2563EB);
  static const Color gold = Color(0xFFF9C477);
  static const Color brownOlive = Color(0xFF7E5713);
  static const Color purpleDeep = Color(0xFF8333C6);
  static const Color purpleLight = Color(0xFFB96CFD);
  static const Color peachPink = Color(0xFFFFDAD6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color redDark = Color(0xFFBA1A1A);
  static const Color redBright = Color(0xFFE51E1E);
  static const Color tealDark = Color(0xFF006482);
  static const Color emerald = Color(0xFF10B981);
  static const Color mint = Color(0xFFC3EFDD);
  static const Color blueSky = Color(0xFF60A5FA);
  static const Color violet = Color(0xFF9333EA);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFD9D9D9);

  /// Auth screens: link text (not used for primary actions / fills).
  static const Color authLink = Color(0xFF0F766E);

  /// Idle / disabled text-field outline.
  static const Color outlineMuted = Color(0xFFBDBDBD);

  /// Light card outline (hairline on white).
  static const Color outlineSoft = Color(0x33000000);

  /// First occurrence order from the spec (unique only).
  static const List<Color> ordered = [
    blueSteel,
    blueBright,
    gold,
    brownOlive,
    purpleDeep,
    purpleLight,
    peachPink,
    redDark,
    redBright,
    tealDark,
    emerald,
    mint,
    blueSky,
    violet,
  ];
}
