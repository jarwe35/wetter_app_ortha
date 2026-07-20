import 'package:flutter/material.dart';

import 'ortha_colors.dart';

abstract final class OrthaTextStyles {
  static const TextStyle cardTitle = TextStyle(
    color: OrthaColors.primaryText,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle statusTitle = TextStyle(
    color: OrthaColors.primaryText,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static const TextStyle informationLabel = TextStyle(
    color: OrthaColors.primaryText,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle informationValue = TextStyle(
    color: OrthaColors.primaryText,
    fontSize: 15,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    color: OrthaColors.primaryText,
    fontSize: 15,
    height: 1.4,
  );

  static const TextStyle secondaryBody = TextStyle(
    color: OrthaColors.secondaryText,
    fontSize: 14,
    height: 1.4,
  );
}
