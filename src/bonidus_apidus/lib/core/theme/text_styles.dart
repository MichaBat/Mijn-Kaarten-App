import 'package:flutter/material.dart';
import 'package:bonidus_apidus/core/theme/colours.dart';

class TextStyles {
  TextStyles._();

  // Font families
  static const String _headerFont    = 'Noto Sans';
  static const String _primaryFont   = 'Inter';
  static const String _secondaryFont = 'Roboto';

  // Font sizes
  static const double h1        = 32;
  static const double h2        = 28;
  static const double h3        = 22;
  static const double text      = 16;
  static const double textSmall = 12;
  static const double caption   = 10;

  // Font weights
  static const FontWeight bold     = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular  = FontWeight.w400;

  // Header styles — Noto Sans
  static TextStyle get h1Style => TextStyle(
    fontFamily: _headerFont,
    fontSize: h1,
    fontWeight: bold,
    color: AppColours.textPrimary,
  );

  static TextStyle get h2Style => TextStyle(
    fontFamily: _headerFont,
    fontSize: h2,
    fontWeight: bold,
  );

  static TextStyle get h3Style => TextStyle(
    fontFamily: _headerFont,
    fontSize: h3,
    fontWeight: semiBold,
  );

  // Body styles — Inter
  static TextStyle get textStyle => TextStyle(
    fontFamily: _primaryFont,
    fontSize: text,
    fontWeight: regular,
  );

  static TextStyle get textSmallStyle => TextStyle(
    fontFamily: _primaryFont,
    fontSize: textSmall,
    fontWeight: regular,
  );

  // Caption — Roboto
  static TextStyle get captionStyle => TextStyle(
    fontFamily: _secondaryFont,
    fontSize: caption,
    fontWeight: regular,
  );
}